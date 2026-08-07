import copy
import inspect
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import cloudctl


class ContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.topology, cls.workloads = cloudctl.load_inputs()

    def test_fixture_validates_and_has_three_distinct_domains(self):
        cloudctl.validate_topology(copy.deepcopy(self.topology))
        self.assertEqual(3, len(self.topology["racks"]))
        self.assertEqual(
            3, len({rack["powerDomain"] for rack in self.topology["racks"]})
        )
        self.assertEqual(
            3, len({rack["networkDomain"] for rack in self.topology["racks"]})
        )

    def test_baseline_is_deterministic_and_rack_aware(self):
        first = cloudctl.build_baseline(self.topology, self.workloads)
        second = cloudctl.build_baseline(self.topology, self.workloads)
        self.assertEqual(
            cloudctl.canonical_json(first), cloudctl.canonical_json(second)
        )
        checkout = [
            row for row in first["allocations"]
            if row["workloadId"] == "checkout-api"
        ]
        self.assertEqual(2, len({row["rack"] for row in checkout}))
        self.assertTrue(first["capacity"]["computeReservePass"])
        self.assertTrue(first["capacity"]["storageReservePass"])

    def test_underlay_mtu_contract_fails_closed(self):
        topology = copy.deepcopy(self.topology)
        topology["network"]["underlayMtu"] = 1549
        with self.assertRaisesRegex(cloudctl.GuardError, "underlay MTU"):
            cloudctl.validate_topology(topology)

    def test_duplicate_failure_domains_fail_closed(self):
        topology = copy.deepcopy(self.topology)
        topology["racks"][2]["powerDomain"] = "pdu-a"
        with self.assertRaisesRegex(cloudctl.GuardError, "distinct power"):
            cloudctl.validate_topology(topology)

    def test_storage_protection_must_match_rack_contract(self):
        topology = copy.deepcopy(self.topology)
        topology["storage"]["failureDomain"] = "host"
        with self.assertRaisesRegex(cloudctl.GuardError, "rack failure"):
            cloudctl.validate_topology(topology)

    def test_unsigned_image_is_rejected_before_placement(self):
        workloads = copy.deepcopy(self.workloads)
        workloads["workloads"][0]["imageTrust"] = "unsigned"
        with self.assertRaisesRegex(cloudctl.GuardError, "image-trust"):
            cloudctl.build_baseline(self.topology, workloads)

    def test_quota_violation_is_rejected(self):
        workloads = copy.deepcopy(self.workloads)
        workloads["workloads"][0]["vcpusEach"] = 24
        with self.assertRaisesRegex(cloudctl.GuardError, "vCPU quota"):
            cloudctl.build_baseline(self.topology, workloads)

    def test_unknown_workload_key_is_rejected(self):
        workloads = copy.deepcopy(self.workloads)
        workloads["workloads"][0]["surprise"] = True
        with self.assertRaisesRegex(cloudctl.GuardError, "unknown"):
            cloudctl.validate_workloads(workloads, self.topology)

    def test_forbidden_endpoint_shaped_field_is_rejected(self):
        topology = copy.deepcopy(self.topology)
        topology["endpoint"] = "not-allowed"
        with self.assertRaisesRegex(cloudctl.GuardError, "keys mismatch"):
            cloudctl.validate_topology(topology)

    def test_all_scenarios_return_declared_safe_decision_states(self):
        baseline = cloudctl.build_baseline(self.topology, self.workloads)
        expected = {
            "compute-host-loss": "degraded",
            "rack-loss": "degraded",
            "placement-generation-conflict": "blocked",
            "gateway-failure": "degraded",
            "mtu-mismatch": "unavailable",
            "ceph-osd-down": "degraded",
            "ceph-near-full": "blocked",
            "migration-incompatible": "blocked",
            "upgrade-boundary": "blocked",
            "restore-divergence": "blocked",
            "bmc-ambiguous": "blocked",
            "policy-violation": "blocked",
        }
        self.assertEqual(set(cloudctl.SCENARIOS), set(expected))
        for name, expected_result in expected.items():
            with self.subTest(name=name):
                result = cloudctl.evaluate_scenario(
                    name, self.topology, self.workloads, baseline
                )
                self.assertEqual(expected_result, result["result"])
                self.assertTrue(result["evidence"])
                self.assertTrue(result["recovery"])
                self.assertGreater(len(result["proves"]), 20)
                self.assertGreater(len(result["doesNotProve"]), 20)

    def test_generation_conflict_never_writes_allocation(self):
        baseline = cloudctl.build_baseline(self.topology, self.workloads)
        result = cloudctl.evaluate_scenario(
            "placement-generation-conflict",
            self.topology,
            self.workloads,
            baseline,
        )
        self.assertEqual("blocked", result["result"])
        self.assertIn("allocation_written=false", result["evidence"])

    def test_migration_checks_cpu_and_machine_baselines(self):
        baseline = cloudctl.build_baseline(self.topology, self.workloads)
        result = cloudctl.evaluate_scenario(
            "migration-incompatible", self.topology, self.workloads, baseline
        )
        self.assertEqual("blocked", result["result"])
        self.assertIn("migration_started=false", result["evidence"])

    def test_restore_divergence_blocks_promotion(self):
        baseline = cloudctl.build_baseline(self.topology, self.workloads)
        result = cloudctl.evaluate_scenario(
            "restore-divergence", self.topology, self.workloads, baseline
        )
        self.assertIn("promotion=false", result["evidence"])

    def test_simulator_has_no_infrastructure_or_process_client_imports(self):
        source = inspect.getsource(cloudctl)
        for forbidden in (
            "import subprocess",
            "from subprocess",
            "import socket",
            "import requests",
            "import libvirt",
            "import openstack",
            "import paramiko",
        ):
            self.assertNotIn(forbidden, source)

    def test_fixture_contains_no_endpoint_or_credential_shaped_keys(self):
        for document in (self.topology, self.workloads):
            serialized = json.dumps(document)
            for key in cloudctl.FORBIDDEN_INPUT_KEYS:
                self.assertNotIn(f'"{key}"', serialized)

    def test_cleanup_refuses_an_unknown_runtime_file(self):
        with tempfile.TemporaryDirectory() as temporary:
            runtime = Path(temporary) / ".runtime"
            receipts = runtime / "receipts"
            with patch.multiple(
                cloudctl,
                RUNTIME=runtime,
                DESCRIPTOR=runtime / "descriptor.json",
                STATE_PATH=runtime / "baseline.json",
                DOSSIER_PATH=runtime / "design-dossier.md",
                RECEIPTS=receipts,
            ):
                cloudctl.initialize()
                unexpected = runtime / "foreign.txt"
                unexpected.write_text("not owned", encoding="utf-8")
                with self.assertRaisesRegex(cloudctl.GuardError, "unknown file"):
                    cloudctl.cleanup()
                self.assertTrue(unexpected.exists())
                unexpected.unlink()
                self.assertEqual("absent", cloudctl.cleanup()["runtime"])

    def test_descriptor_tampering_blocks_mutation_and_cleanup(self):
        with tempfile.TemporaryDirectory() as temporary:
            runtime = Path(temporary) / ".runtime"
            receipts = runtime / "receipts"
            descriptor = runtime / "descriptor.json"
            with patch.multiple(
                cloudctl,
                RUNTIME=runtime,
                DESCRIPTOR=descriptor,
                STATE_PATH=runtime / "baseline.json",
                DOSSIER_PATH=runtime / "design-dossier.md",
                RECEIPTS=receipts,
            ):
                cloudctl.initialize()
                value = json.loads(descriptor.read_text(encoding="utf-8"))
                value["projectId"] = "different-project"
                descriptor.write_text(json.dumps(value), encoding="utf-8")
                with self.assertRaisesRegex(cloudctl.GuardError, "descriptor"):
                    cloudctl.run_baseline()
                with self.assertRaisesRegex(cloudctl.GuardError, "descriptor"):
                    cloudctl.cleanup()
                self.assertTrue(runtime.exists())


if __name__ == "__main__":
    unittest.main()
