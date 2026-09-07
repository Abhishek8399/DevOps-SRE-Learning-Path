from __future__ import annotations

import ast
import json
import unittest

import assistantctl


EXPECTED_RESULTS = {
    "prompt-injection": "blocked",
    "sensitive-value": "blocked",
    "cross-tenant": "blocked",
    "unsupported-claim": "blocked",
    "citation-mismatch": "blocked",
    "corpus-drift": "blocked",
    "unknown-tool": "blocked",
    "unauthorized-scope": "blocked",
    "approval-invalid": "blocked",
    "ambiguous-outcome": "ambiguous",
    "answer-leakage": "blocked",
    "clock-skew": "fallback",
    "release-drift": "blocked",
    "audit-tamper": "blocked",
    "budget-exceeded": "fallback",
    "kill-switch": "fallback",
}


class ContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.assertFalse(assistantctl.RUNTIME.exists())
        self.assertFalse(assistantctl.RUNTIME.is_symlink())

    def tearDown(self) -> None:
        if assistantctl.RUNTIME.exists():
            assistantctl.cleanup()

    def test_contracts_validate_and_cross_link(self) -> None:
        contracts = assistantctl.load_contracts()
        self.assertEqual(len(contracts["telemetry.json"]["events"]), 4)
        self.assertEqual(len(contracts["runbooks.json"]["documents"]), 3)
        self.assertEqual(len(contracts["evaluations.json"]["cases"]), 16)
        self.assertEqual(
            contracts["release.json"]["policy"], contracts["policy.json"]["id"]
        )

    def test_check_is_read_only_and_declares_no_external_authority(self) -> None:
        result = assistantctl.check()
        self.assertEqual(result["authority"], "local-fixture-only")
        self.assertEqual(result["network"], "none")
        self.assertEqual(result["model"], "none")
        self.assertFalse(assistantctl.RUNTIME.exists())

    def test_duplicate_json_keys_fail_closed(self) -> None:
        with self.assertRaises(assistantctl.DuplicateKeyError):
            json.loads(
                '{"id":"one","id":"two"}',
                object_pairs_hook=assistantctl._object_no_duplicates,
            )

    def test_sensitive_shaped_values_fail_before_processing(self) -> None:
        for value in (
            "password=not-allowed",
            "Bearer abcdefghijklmnop",
            "person@example.invalid",
            "192.0.2.10",
            "-----BEGIN PRIVATE KEY-----",
        ):
            with self.subTest(value=value):
                with self.assertRaises(assistantctl.GuardError):
                    assistantctl.reject_sensitive({"value": value})

    def test_authorized_retrieval_excludes_other_tenant_and_retired_document(self) -> None:
        contracts = assistantctl.load_contracts()
        fragments = assistantctl.authorized_fragments(
            contracts, tenant="tenant-a", service="checkout"
        )
        ids = {item["fragmentId"] for item in fragments}
        self.assertEqual(
            ids,
            {"frag-check-dependency", "frag-check-signals", "frag-rollback-gate"},
        )
        self.assertNotIn("frag-tenant-b-only", ids)
        self.assertNotIn("frag-stale", ids)

    def test_baseline_is_grounded_abstaining_and_read_only(self) -> None:
        assistantctl.initialize()
        result = assistantctl.run_baseline()
        self.assertEqual(result["baseline"], "pass")
        self.assertEqual(len(result["verifiedClaims"]), 4)
        self.assertEqual(result["readOnlyEffect"]["state"], "completed")
        self.assertEqual(len(result["abstentions"]), 2)
        self.assertLessEqual(
            result["workUnits"],
            assistantctl.load_contracts()["policy.json"]["maxWorkUnits"],
        )

    def test_unsupported_claim_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        events = assistantctl.sanitize_events(
            contracts["telemetry.json"]["events"]
        )
        fragments = assistantctl.authorized_fragments(
            contracts, tenant="tenant-a", service="checkout"
        )
        support = assistantctl.evidence_support(
            contracts["incident.json"], events, fragments
        )
        candidate = assistantctl.baseline_candidate(contracts, events)
        candidate["claims"][0]["statement"] = "Invented root cause."
        with self.assertRaisesRegex(assistantctl.GuardError, "unsupported"):
            assistantctl.verify_candidate(
                candidate,
                support,
                contracts["release.json"]["id"],
                contracts["policy.json"],
            )

    def test_citation_mismatch_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        events = assistantctl.sanitize_events(
            contracts["telemetry.json"]["events"]
        )
        fragments = assistantctl.authorized_fragments(
            contracts, tenant="tenant-a", service="checkout"
        )
        support = assistantctl.evidence_support(
            contracts["incident.json"], events, fragments
        )
        candidate = assistantctl.baseline_candidate(contracts, events)
        candidate["claims"][0]["evidenceIds"] = ["evt-latency"]
        with self.assertRaisesRegex(assistantctl.GuardError, "citation"):
            assistantctl.verify_candidate(
                candidate,
                support,
                contracts["release.json"]["id"],
                contracts["policy.json"],
            )

    def test_unknown_tool_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        proposal = assistantctl.proposal_for(contracts, "run-arbitrary-shell")
        with self.assertRaisesRegex(assistantctl.GuardError, "not allowlisted"):
            assistantctl.authorize_proposal(proposal, contracts)

    def test_unauthorized_tenant_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        proposal = assistantctl.proposal_for(
            contracts, "inspect-synthetic-evidence", tenant="tenant-b"
        )
        with self.assertRaisesRegex(assistantctl.GuardError, "not authorized"):
            assistantctl.authorize_proposal(proposal, contracts)

    def test_command_path_or_url_shaped_argument_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        proposal = assistantctl.proposal_for(
            contracts, "inspect-synthetic-evidence"
        )
        proposal["arguments"]["window"] = "/tmp/unsafe"
        with self.assertRaisesRegex(assistantctl.GuardError, "open-ended"):
            assistantctl.authorize_proposal(proposal, contracts)

    def test_mutation_without_approval_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        proposal = assistantctl.proposal_for(
            contracts, "set-synthetic-traffic-shape"
        )
        with self.assertRaisesRegex(assistantctl.GuardError, "requires"):
            assistantctl.execute_synthetic(proposal, contracts, None)

    def test_expired_approval_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        proposal = assistantctl.proposal_for(
            contracts, "set-synthetic-traffic-shape"
        )
        approval = assistantctl.make_approval(proposal, contracts)
        with self.assertRaisesRegex(assistantctl.GuardError, "expired"):
            assistantctl.validate_approval(
                approval, proposal, contracts, now_tick=1000
            )

    def test_replayed_approval_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        proposal = assistantctl.proposal_for(
            contracts, "set-synthetic-traffic-shape"
        )
        approval = assistantctl.make_approval(proposal, contracts)
        approval["used"] = True
        with self.assertRaisesRegex(assistantctl.GuardError, "already used"):
            assistantctl.validate_approval(approval, proposal, contracts)

    def test_all_scenarios_return_declared_safe_results(self) -> None:
        assistantctl.initialize()
        assistantctl.run_baseline()
        actual = {
            name: assistantctl.run_scenario(name)["result"]
            for name in assistantctl.SCENARIOS
        }
        self.assertEqual(actual, EXPECTED_RESULTS)

    def test_audit_chain_verifies_after_baseline(self) -> None:
        assistantctl.initialize()
        assistantctl.run_baseline()
        rows = assistantctl.verify_audit()
        self.assertEqual([row["sequence"] for row in rows], [1, 2])
        self.assertEqual(rows[1]["previousHash"], rows[0]["hash"])

    def test_audit_tampering_is_rejected(self) -> None:
        assistantctl.initialize()
        rows = assistantctl.verify_audit()
        copied = json.loads(assistantctl.canonical_json(rows))
        copied[0]["details"]["projectId"] = "different-project"
        with self.assertRaisesRegex(assistantctl.GuardError, "hash mismatch"):
            assistantctl.verify_audit(copied)

    def test_evaluation_identity_leak_is_rejected(self) -> None:
        contracts = assistantctl.load_contracts()
        copied = json.loads(
            assistantctl.canonical_json(contracts["runbooks.json"])
        )
        copied["documents"][0]["fragments"][0]["text"] += " eval-cap005-v1"
        with self.assertRaisesRegex(assistantctl.GuardError, "leaked"):
            assistantctl.reject_evaluation_leak(
                copied, contracts["evaluations.json"]
            )

    def test_harness_imports_no_infrastructure_or_model_clients(self) -> None:
        tree = ast.parse(
            (assistantctl.ROOT / "assistantctl.py").read_text(encoding="utf-8")
        )
        imported: set[str] = set()
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                imported.update(alias.name.split(".")[0] for alias in node.names)
            elif isinstance(node, ast.ImportFrom) and node.module:
                imported.add(node.module.split(".")[0])
        self.assertTrue(
            imported.isdisjoint(
                {
                    "subprocess", "socket", "urllib", "http", "requests",
                    "openai", "anthropic", "kubernetes", "docker",
                }
            )
        )

    def test_all_fixture_values_pass_sensitive_data_guard(self) -> None:
        for name, value in assistantctl.load_contracts().items():
            with self.subTest(name=name):
                assistantctl.reject_sensitive(value, name)

    def test_cleanup_refuses_unknown_runtime_artifact(self) -> None:
        assistantctl.initialize()
        unknown = assistantctl.RUNTIME / "unexpected.txt"
        unknown.write_text("owned by this test", encoding="utf-8")
        try:
            with self.assertRaisesRegex(assistantctl.GuardError, "unknown"):
                assistantctl.cleanup()
        finally:
            unknown.unlink()
        assistantctl.cleanup()

    def test_descriptor_tampering_blocks_mutation_and_cleanup(self) -> None:
        assistantctl.initialize()
        original = assistantctl.DESCRIPTOR.read_text(encoding="utf-8")
        descriptor = json.loads(original)
        descriptor["projectId"] = "different-project"
        assistantctl.DESCRIPTOR.write_text(
            json.dumps(descriptor, sort_keys=True), encoding="utf-8"
        )
        try:
            with self.assertRaisesRegex(assistantctl.GuardError, "descriptor"):
                assistantctl.run_baseline()
            with self.assertRaisesRegex(assistantctl.GuardError, "descriptor"):
                assistantctl.cleanup()
        finally:
            assistantctl.DESCRIPTOR.write_text(original, encoding="utf-8")
        assistantctl.cleanup()


if __name__ == "__main__":
    unittest.main()
