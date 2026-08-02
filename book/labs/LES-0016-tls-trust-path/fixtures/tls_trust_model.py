#!/usr/bin/env python3
"""Deterministic public-metadata model for LES-0016.

This program opens no socket, reads no certificate or key, changes no trust,
and uses no system clock. Values are synthetic evidence for reasoning practice.
"""

from __future__ import annotations

import sys
from collections import OrderedDict
from typing import Dict, Iterable, Mapping


CASES = ("guided", "independent")
VIEWS = ("handshake", "certificate", "trust", "rotation", "ownership")


def emit(fields: Mapping[str, object]) -> None:
    for key, value in fields.items():
        if isinstance(value, bool):
            rendered = "true" if value else "false"
        else:
            rendered = str(value)
        print(f"{key}={rendered}")


def baseline() -> Mapping[str, object]:
    return OrderedDict(
        [
            ("record", "baseline"),
            ("case", "healthy"),
            ("operation", "create_payment_authorization"),
            ("operation_success", True),
            ("tls_version", "TLSv1.3"),
            ("selected_alpn", "h2"),
            ("presented_certificates", 2),
            ("path_result", "accepted"),
            ("hostname_match", True),
            ("time_valid", True),
            ("purpose_valid", True),
            ("endpoint_deployment_percent", 100),
            ("trust_adoption_percent", 100),
            ("fresh_handshake_success_percent", 100),
            ("application_correctness", "verified"),
        ]
    )


def inputs(case: str) -> Mapping[str, object]:
    common = [
        ("record", "inputs"),
        ("case", case),
        ("operation", "create_payment_authorization"),
        ("operation_success", False),
        ("client_role", "checkout_worker"),
        ("server_role", "payments_edge"),
        ("transport_endpoint", "192.0.2.44:443"),
        ("reference_identity", "payments.service.internal"),
        ("sni", "payments.service.internal"),
        ("client_auth_required", False),
        ("client_clock_epoch", 1785668400),
        ("failure_phase", "tls_certificate_validation"),
    ]
    if case == "guided":
        return OrderedDict(
            common
            + [
                ("endpoint_cohort", "edge_generation_1842"),
                ("client_cohort", "clean_runtime_A"),
                ("first_error", "certificate_verify_failed"),
            ]
        )
    return OrderedDict(
        common
        + [
            ("endpoint_cohort", "edge_generation_1911"),
            ("client_cohort", "runtime_generation_31"),
            ("first_error", "unknown_ca"),
        ]
    )


def handshake(case: str) -> Mapping[str, object]:
    alert = "certificate_unknown" if case == "guided" else "unknown_ca"
    return OrderedDict(
        [
            ("record", "observation"),
            ("case", case),
            ("view", "handshake"),
            ("tcp_connected", True),
            ("client_hello_sent", True),
            ("sni_route_selected", True),
            ("server_hello_received", True),
            ("selected_tls_version", "TLSv1.3"),
            ("selected_cipher", "TLS_AES_256_GCM_SHA384"),
            ("selected_alpn", "h2"),
            ("certificate_message_received", True),
            ("finished_received", False),
            ("tls_alert", alert),
            ("application_bytes_sent", False),
        ]
    )


def certificate(case: str) -> Mapping[str, object]:
    if case == "guided":
        issuer = "Payments_Intermediate_2026"
        certificates = 1
        intermediate = False
        leaf_generation = "1842"
    else:
        issuer = "Payments_Intermediate_B"
        certificates = 2
        intermediate = True
        leaf_generation = "1911"
    return OrderedDict(
        [
            ("record", "observation"),
            ("case", case),
            ("view", "certificate"),
            ("leaf_generation", leaf_generation),
            ("leaf_san_dns", "payments.service.internal"),
            ("leaf_issuer", issuer),
            ("leaf_eku", "serverAuth"),
            ("leaf_not_before_epoch", 1785063600),
            ("leaf_not_after_epoch", 1793444400),
            ("leaf_seconds_remaining", 7776000),
            ("presented_certificates", certificates),
            ("intermediate_presented", intermediate),
            ("private_key_material", "not_present_in_model"),
        ]
    )


def trust(case: str) -> Mapping[str, object]:
    if case == "guided":
        generation = "root_A"
        old_anchor = True
        new_anchor = False
        error = "unable_to_get_local_issuer"
    else:
        generation = "root_A_only"
        old_anchor = True
        new_anchor = False
        error = "untrusted_issuer_generation_B"
    return OrderedDict(
        [
            ("record", "observation"),
            ("case", case),
            ("view", "trust"),
            ("trust_bundle_generation", generation),
            ("old_anchor_present", old_anchor),
            ("new_anchor_present", new_anchor),
            ("path_result", "rejected"),
            ("path_error", error),
            ("hostname_match", True),
            ("time_valid", True),
            ("purpose_valid", True),
            ("revocation_policy", "not_modeled"),
        ]
    )


def rotation(case: str) -> Mapping[str, object]:
    if case == "guided":
        presenter = "leaf_1842_intermediate_2026"
        trust_adoption = 100
        old_available = True
        connection_reuse = 91
    else:
        presenter = "leaf_1911_hierarchy_B"
        trust_adoption = 68
        old_available = True
        connection_reuse = 74
    return OrderedDict(
        [
            ("record", "observation"),
            ("case", case),
            ("view", "rotation"),
            ("presenter_generation", presenter),
            ("endpoint_deployment_percent", 100),
            ("trust_adoption_percent", trust_adoption),
            ("old_credential_rollback_available", old_available),
            ("existing_connection_success_percent", connection_reuse),
            ("fresh_handshake_success_percent", trust_adoption if case == "independent" else 62),
        ]
    )


def ownership(case: str) -> Mapping[str, object]:
    reload_policy = "atomic_bundle_reload" if case == "guided" else "process_start_only"
    return OrderedDict(
        [
            ("record", "observation"),
            ("case", case),
            ("view", "ownership"),
            ("tls_termination_owner", "edge_platform"),
            ("certificate_source_owner", "certificate_platform"),
            ("served_chain_owner", "edge_platform"),
            ("client_trust_owner", "runtime_platform"),
            ("clock_owner", "host_platform"),
            ("authorization_owner", "payments_service"),
            ("reload_policy", reload_policy),
            ("active_reload_generation", "1842" if case == "guided" else "31"),
        ]
    )


def recover(case: str) -> Mapping[str, object]:
    action = (
        "activate_reviewed_leaf_plus_intermediate_bundle"
        if case == "guided"
        else "restore_compatibility_and_complete_dual_trust_gate"
    )
    return OrderedDict(
        [
            ("record", "recovery"),
            ("case", case),
            ("action", action),
            ("change_scope", "modeled_owner_cohort"),
            ("rollback_preserved", True),
            ("configuration_result", "completed"),
        ]
    )


def verification(case: str) -> Mapping[str, object]:
    return OrderedDict(
        [
            ("record", "verification"),
            ("case", case),
            ("fresh_handshake_success", True),
            ("path_result", "accepted"),
            ("hostname_match", True),
            ("time_valid", True),
            ("purpose_valid", True),
            ("client_auth_expectation_met", True),
            ("selected_alpn", "h2"),
            ("application_correctness", "verified"),
            ("endpoint_coverage_percent", 100),
            ("verifier_coverage_percent", 100),
            ("verification_scope", "deterministic_model_only"),
        ]
    )


def view(case: str, name: str) -> Mapping[str, object]:
    functions = {
        "handshake": handshake,
        "certificate": certificate,
        "trust": trust,
        "rotation": rotation,
        "ownership": ownership,
    }
    return functions[name](case)


def usage() -> int:
    print(
        "usage: tls_trust_model.py baseline | inputs CASE | view CASE VIEW | recover CASE | verify CASE",
        file=sys.stderr,
    )
    return 2


def main(arguments: Iterable[str]) -> int:
    args = list(arguments)
    if args == ["baseline"]:
        emit(baseline())
        return 0
    if len(args) == 2 and args[0] in ("inputs", "recover", "verify"):
        case = args[1]
        if case not in CASES:
            return usage()
        result = {"inputs": inputs, "recover": recover, "verify": verification}[args[0]](case)
        emit(result)
        return 0
    if len(args) == 3 and args[0] == "view":
        case, name = args[1], args[2]
        if case not in CASES or name not in VIEWS:
            return usage()
        emit(view(case, name))
        return 0
    return usage()


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
