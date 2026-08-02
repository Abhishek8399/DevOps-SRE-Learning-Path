#!/usr/bin/env python3
"""Deterministic, offline teaching model for LES-0022.

The model never opens a socket, installs a package, or invokes another process.
It turns small in-memory source, dependency, context, cache, artifact, SBOM, and
provenance records into evidence that the Bash controller can guard and verify.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import time
from collections.abc import Iterable, Mapping


SOURCE_DATE_EPOCH = 1_704_067_200
SOURCE_BYTES = b'print("reliability-atlas")\n'
LOCKED_DEPENDENCY = b"parser-kit|2.4.0|stable-parser\n"
DRIFTED_DEPENDENCY = b"parser-kit|2.4.1|changed-parser\n"
TOOLCHAIN_ID = "python-stdlib-model/1"
SOURCE_REVISION = "src-" + hashlib.sha256(SOURCE_BYTES).hexdigest()[:16]


def sha256(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def canonical_json(value: object) -> bytes:
    return (
        json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)
        + "\n"
    ).encode("utf-8")


LOCK_RECORD = {
    "schemaVersion": 1,
    "dependencies": [
        {
            "name": "parser-kit",
            "version": "2.4.0",
            "sha256": sha256(LOCKED_DEPENDENCY),
        }
    ],
}
LOCK_BYTES = canonical_json(LOCK_RECORD)


def dependency_version(value: bytes) -> str:
    if value == LOCKED_DEPENDENCY:
        return "2.4.0"
    if value == DRIFTED_DEPENDENCY:
        return "2.4.1"
    return "unknown"


def framed_digest(entries: Mapping[str, bytes], *, ordered: bool = True) -> str:
    """Hash names, lengths, and bytes so concatenation cannot be ambiguous."""

    digest = hashlib.sha256()
    names: Iterable[str] = sorted(entries) if ordered else entries.keys()
    for name in names:
        encoded_name = name.encode("utf-8")
        value = entries[name]
        digest.update(len(encoded_name).to_bytes(8, "big"))
        digest.update(encoded_name)
        digest.update(len(value).to_bytes(8, "big"))
        digest.update(value)
    return digest.hexdigest()


def build_context(
    dependency: bytes = LOCKED_DEPENDENCY,
    *,
    include_debug_note: bool = False,
) -> dict[str, bytes]:
    entries = {
        "src/app.py": SOURCE_BYTES,
        "deps.lock.json": LOCK_BYTES,
        "vendor/parser-kit.pkg": dependency,
    }
    if include_debug_note:
        entries["notes/debug.txt"] = b"local-only note\n"
    return entries


def normalized_artifact(dependency: bytes = LOCKED_DEPENDENCY) -> bytes:
    context = build_context(dependency)
    payload = {
        "schemaVersion": 1,
        "application": "reliability-atlas-demo",
        "sourceRevision": SOURCE_REVISION,
        "sourceSha256": sha256(SOURCE_BYTES),
        "lockSha256": sha256(LOCK_BYTES),
        "dependency": {
            "name": "parser-kit",
            "version": dependency_version(dependency),
            "sha256": sha256(dependency),
        },
        "contextSha256": framed_digest(context),
        "toolchain": TOOLCHAIN_ID,
        "sourceDateEpoch": SOURCE_DATE_EPOCH,
        "timezone": "UTC",
        "locale": "C.UTF-8",
        "buildPath": "/workspace",
        "inputOrder": sorted(context),
    }
    return canonical_json(payload)


def volatile_artifact(run_label: str, input_order: list[str]) -> bytes:
    context = build_context()
    wall_clock_ns = time.time_ns()
    workspace_hash = sha256(os.getcwd().encode("utf-8"))
    payload = {
        "schemaVersion": 1,
        "application": "reliability-atlas-demo",
        "sourceRevision": SOURCE_REVISION,
        "sourceSha256": sha256(SOURCE_BYTES),
        "lockSha256": sha256(LOCK_BYTES),
        "dependencySha256": sha256(LOCKED_DEPENDENCY),
        "contextStreamSha256": framed_digest(
            {name: context[name] for name in input_order}, ordered=False
        ),
        "toolchain": TOOLCHAIN_ID,
        "runLabel": run_label,
        "builtAtNanoseconds": wall_clock_ns,
        "workspacePathSha256": workspace_hash,
        "inputOrder": input_order,
    }
    return canonical_json(payload)


def sbom_for(artifact: bytes, dependency: bytes) -> dict[str, object]:
    return {
        "bomFormat": "CycloneDX",
        "specVersion": "1.5",
        "version": 1,
        "metadata": {
            "component": {
                "type": "application",
                "name": "reliability-atlas-demo",
                "hashes": [{"alg": "SHA-256", "content": sha256(artifact)}],
            }
        },
        "components": [
            {
                "type": "library",
                "name": "parser-kit",
                "version": dependency_version(dependency),
                "hashes": [{"alg": "SHA-256", "content": sha256(dependency)}],
            }
        ],
    }


def provenance_for(artifact: bytes, dependency: bytes) -> dict[str, object]:
    return {
        "_type": "https://in-toto.io/Statement/v1",
        "subject": [
            {
                "name": "reliability-atlas-demo.json",
                "digest": {"sha256": sha256(artifact)},
            }
        ],
        "predicateType": "https://slsa.dev/provenance/v1",
        "predicate": {
            "buildDefinition": {
                "buildType": "https://example.invalid/reliability-atlas/local-model/v1",
                "externalParameters": {
                    "sourceRevision": SOURCE_REVISION,
                    "sourceDateEpoch": SOURCE_DATE_EPOCH,
                },
                "resolvedDependencies": [
                    {"uri": "local:source", "digest": {"sha256": sha256(SOURCE_BYTES)}},
                    {"uri": "local:lock", "digest": {"sha256": sha256(LOCK_BYTES)}},
                    {"uri": "local:parser-kit", "digest": {"sha256": sha256(dependency)}},
                ],
            },
            "runDetails": {
                "builder": {"id": "local:LES-0022-model"},
                "metadata": {"invocationId": "build-417"},
            },
        },
    }


def emit(pairs: Iterable[tuple[str, object]]) -> None:
    for key, value in pairs:
        if isinstance(value, bool):
            rendered = "true" if value else "false"
        elif isinstance(value, (dict, list)):
            rendered = canonical_json(value).decode("utf-8").strip()
        else:
            rendered = str(value)
        if "\n" in rendered or "\r" in rendered:
            raise ValueError(f"multiline value refused for {key}")
        print(f"{key}={rendered}")


def baseline() -> None:
    first = normalized_artifact()
    second = normalized_artifact()
    sbom = sbom_for(first, LOCKED_DEPENDENCY)
    provenance = provenance_for(first, LOCKED_DEPENDENCY)
    emit(
        [
            ("record", "baseline"),
            ("source_revision", SOURCE_REVISION),
            ("source_sha256", sha256(SOURCE_BYTES)),
            ("lock_sha256", sha256(LOCK_BYTES)),
            ("locked_dependency_sha256", sha256(LOCKED_DEPENDENCY)),
            ("context_sha256", framed_digest(build_context())),
            ("toolchain_id", TOOLCHAIN_ID),
            ("source_date_epoch", SOURCE_DATE_EPOCH),
            ("timezone", "UTC"),
            ("locale", "C.UTF-8"),
            ("path_policy", "normalized-/workspace"),
            ("file_order", "sorted-by-path"),
            ("artifact_sha256", sha256(first)),
            ("repeat_artifact_sha256", sha256(second)),
            ("byte_identical", first == second),
            ("sbom_subject_sha256", sbom["metadata"]["component"]["hashes"][0]["content"]),
            ("provenance_subject_sha256", provenance["subject"][0]["digest"]["sha256"]),
            ("consumer_readback", "valid"),
            ("network_calls", 0),
        ]
    )


def register_case(name: str) -> None:
    emit(
        [
            ("record", "case_registration"),
            ("case", name),
            ("logical_operation_id", "build-417"),
            ("answer_key", "not-provided"),
        ]
    )


def independent_scenario() -> None:
    emit(
        [
            ("record", "scenario_input"),
            ("case", "independent"),
            ("logical_operation_id", "build-417"),
            ("source_revision", SOURCE_REVISION),
            ("declared_dependency", "parser-kit==2.4.0"),
            ("lock_integrity_sha256", sha256(LOCKED_DEPENDENCY)),
            ("workspace_dependency_sha256", sha256(DRIFTED_DEPENDENCY)),
            ("cache_key_fields", "source_sha256"),
            ("cache_entry", "present"),
            ("context_entry_count", 4),
            ("source_date_epoch", SOURCE_DATE_EPOCH),
            ("requested_builds", 2),
            ("network_policy", "none"),
        ]
    )


def guided_observation(view: str) -> None:
    order_a = ["src/app.py", "deps.lock.json", "vendor/parser-kit.pkg"]
    order_b = ["vendor/parser-kit.pkg", "src/app.py", "deps.lock.json"]
    naive_a = volatile_artifact("run-a", order_a)
    naive_b = volatile_artifact("run-b", order_b)
    stable_a = normalized_artifact()
    stable_b = normalized_artifact()
    common = [("record", "observation"), ("case", "guided"), ("view", view)]
    views: dict[str, list[tuple[str, object]]] = {
        "inputs": [
            ("declared_source_equal", True),
            ("declared_lock_equal", True),
            ("declared_toolchain_equal", True),
            ("volatile_clock_embedded", True),
            ("volatile_workspace_path_embedded", True),
        ],
        "dependencies": [
            ("lock_version", "2.4.0"),
            ("resolved_version", "2.4.0"),
            ("lock_integrity_match", True),
            ("transitive_set_complete", True),
        ],
        "context": [
            ("semantic_entries_equal", True),
            ("run_a_order", ",".join(order_a)),
            ("run_b_order", ",".join(order_b)),
            ("run_a_stream_sha256", framed_digest({name: build_context()[name] for name in order_a}, ordered=False)),
            ("run_b_stream_sha256", framed_digest({name: build_context()[name] for name in order_b}, ordered=False)),
            ("stable_context_sha256", framed_digest(build_context())),
        ],
        "cache": [
            ("cache_key_fields", "source,lock,dependency,context,toolchain,flags"),
            ("cache_key_complete", True),
            ("cache_decision", "safe-to-reuse-only-after-input-match"),
            ("cache_is_evidence_of_reuse_not-correctness", True),
        ],
        "artifact": [
            ("run_a_artifact_sha256", sha256(naive_a)),
            ("run_b_artifact_sha256", sha256(naive_b)),
            ("naive_byte_identical", naive_a == naive_b),
            ("normalized_a_sha256", sha256(stable_a)),
            ("normalized_b_sha256", sha256(stable_b)),
            ("normalized_byte_identical", stable_a == stable_b),
            ("first_failed_boundary", "volatile-metadata-and-input-order"),
        ],
        "supplychain": [
            ("sbom_subject_matches_artifact", True),
            ("sbom_dependency_matches_lock", True),
            ("provenance_subject_matches_artifact", True),
            ("provenance_materials_match_inputs", True),
            ("attestation_signature", "none-local-model"),
        ],
    }
    emit(common + views[view])


def independent_observation(view: str) -> None:
    cached_artifact = normalized_artifact(LOCKED_DEPENDENCY)
    unlocked_artifact = normalized_artifact(DRIFTED_DEPENDENCY)
    context_with_drift = build_context(DRIFTED_DEPENDENCY, include_debug_note=True)
    sbom = sbom_for(cached_artifact, LOCKED_DEPENDENCY)
    provenance = provenance_for(cached_artifact, LOCKED_DEPENDENCY)
    common = [("record", "observation"), ("case", "independent"), ("view", view)]
    views: dict[str, list[tuple[str, object]]] = {
        "inputs": [
            ("source_sha256", sha256(SOURCE_BYTES)),
            ("lock_sha256", sha256(LOCK_BYTES)),
            ("workspace_dependency_sha256", sha256(DRIFTED_DEPENDENCY)),
            ("expected_dependency_sha256", sha256(LOCKED_DEPENDENCY)),
            ("input_set_valid", False),
        ],
        "dependencies": [
            ("declared_version", "2.4.0"),
            ("workspace_version", "2.4.1"),
            ("integrity_match", False),
            ("lockfile_modified", False),
            ("installation_policy", "fail-closed-before-build"),
        ],
        "context": [
            ("allowed_entry_count", 3),
            ("observed_entry_count", 4),
            ("unexpected_entry", "notes/debug.txt"),
            ("context_policy_match", False),
            ("observed_context_sha256", framed_digest(context_with_drift)),
        ],
        "cache": [
            ("cache_key_fields", "source_sha256"),
            ("lock_digest_in_key", False),
            ("dependency_digest_in_key", False),
            ("context_digest_in_key", False),
            ("toolchain_digest_in_key", False),
            ("cache_result", "hit"),
            ("served_dependency_version", "2.4.0"),
            ("cache_hit_validates_current_inputs", False),
        ],
        "artifact": [
            ("candidate_source", "stale-cache-entry"),
            ("candidate_artifact_sha256", sha256(cached_artifact)),
            ("expected_artifact_sha256", sha256(normalized_artifact())),
            ("candidate_hash_matches_expected", True),
            ("fresh_unlocked_artifact_sha256", sha256(unlocked_artifact)),
            ("promotion_allowed", False),
            ("reason", "current-input-integrity-not-proven"),
        ],
        "supplychain": [
            ("sbom_component_version", sbom["components"][0]["version"]),
            ("sbom_subject_matches_candidate", True),
            ("provenance_subject_matches_candidate", True),
            ("provenance_dependency_material", provenance["predicate"]["buildDefinition"]["resolvedDependencies"][2]["digest"]["sha256"]),
            ("workspace_dependency_matches_provenance", False),
            ("attestation_signature", "none-local-model"),
            ("verification_decision", "reject"),
        ],
    }
    emit(common + views[view])


def recover(case: str) -> None:
    stable_a = normalized_artifact()
    stable_b = normalized_artifact()
    common = [("record", "recovery"), ("case", case)]
    if case == "guided":
        details = [
            ("action", "remove-volatile-fields-normalize-path-sort-inputs"),
            ("source_date_epoch", SOURCE_DATE_EPOCH),
            ("rebuild_count", 2),
            ("artifact_a_sha256", sha256(stable_a)),
            ("artifact_b_sha256", sha256(stable_b)),
            ("byte_identical", stable_a == stable_b),
            ("operation_success", True),
        ]
    else:
        details = [
            ("action", "quarantine-cache-refuse-drift-restore-reviewed-bytes"),
            ("restored_dependency_sha256", sha256(LOCKED_DEPENDENCY)),
            ("cache_key_fields", "source,lock,dependency,context,toolchain,flags"),
            ("cache_entry_reused", False),
            ("rebuild_count", 2),
            ("artifact_a_sha256", sha256(stable_a)),
            ("artifact_b_sha256", sha256(stable_b)),
            ("byte_identical", stable_a == stable_b),
            ("promotion_attempts", 1),
            ("additional_build_requests", 1),
            ("operation_success", True),
        ]
    emit(common + details)


def verify(case: str) -> None:
    artifact = normalized_artifact()
    sbom = sbom_for(artifact, LOCKED_DEPENDENCY)
    provenance = provenance_for(artifact, LOCKED_DEPENDENCY)
    emit(
        [
            ("record", "verification"),
            ("case", case),
            ("operation_success", True),
            ("rebuild_count", 2),
            ("byte_identical", True),
            ("artifact_sha256", sha256(artifact)),
            ("lock_integrity", "valid"),
            ("context_allowlist", "valid"),
            ("cache_key_complete", True),
            ("sbom_subject_matches_artifact", sbom["metadata"]["component"]["hashes"][0]["content"] == sha256(artifact)),
            ("provenance_subject_matches_artifact", provenance["subject"][0]["digest"]["sha256"] == sha256(artifact)),
            ("provenance_verification_scope", "structural-only-unsigned-local-model"),
            ("duplicate_promotions", 0),
            ("consumer_readback", "valid"),
            ("network_calls", 0),
        ]
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description="offline LES-0022 build model")
    subparsers = result.add_subparsers(dest="command", required=True)
    subparsers.add_parser("baseline")
    case_parser = subparsers.add_parser("case")
    case_parser.add_argument("--name", required=True, choices=("guided", "independent"))
    subparsers.add_parser("scenario")
    observe_parser = subparsers.add_parser("observe")
    observe_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    observe_parser.add_argument(
        "--view",
        required=True,
        choices=("inputs", "dependencies", "context", "cache", "artifact", "supplychain"),
    )
    recover_parser = subparsers.add_parser("recover")
    recover_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    return result


def main() -> None:
    args = parser().parse_args()
    if args.command == "baseline":
        baseline()
    elif args.command == "case":
        register_case(args.name)
    elif args.command == "scenario":
        independent_scenario()
    elif args.command == "observe":
        if args.case == "guided":
            guided_observation(args.view)
        else:
            independent_observation(args.view)
    elif args.command == "recover":
        recover(args.case)
    elif args.command == "verify":
        verify(args.case)


if __name__ == "__main__":
    main()
