from __future__ import annotations

import ast
import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class StaticLabContracts(unittest.TestCase):
    def read(self, relative: str) -> str:
        return (ROOT / relative).read_text(encoding="utf-8")

    def test_python_sources_parse(self) -> None:
        for path in sorted(ROOT.rglob("*.py")):
            ast.parse(path.read_text(encoding="utf-8"), filename=str(path))

    def test_artifact_locks_are_explicitly_incomplete(self) -> None:
        lock = json.loads(self.read("artifacts.lock.json"))
        self.assertEqual(lock["lesson"], "LES-0027")
        self.assertEqual(lock["platform"], "linux/amd64")
        self.assertEqual(
            lock["images"]["python"]["repository"], "docker.io/library/python"
        )
        self.assertEqual(
            lock["images"]["collector"]["repository"],
            "docker.io/otel/opentelemetry-collector-contrib",
        )
        self.assertIn("RECORD_REAL_", self.read("artifacts.lock.json"))
        requirements = self.read("requirements.lock")
        self.assertIn("RECORD_REAL_", requirements)
        records = [line for line in requirements.splitlines() if line and not line.startswith("#")]
        self.assertGreaterEqual(len(records), 12)
        self.assertTrue(all("==" in line and "--hash=sha256:" in line for line in records))

    def test_compose_has_five_bounded_services(self) -> None:
        compose = self.read("compose.yaml")
        for service in ("service-a", "service-b", "agent-a", "agent-b", "gateway"):
            self.assertRegex(compose, rf"(?m)^  {re.escape(service)}:$")
        self.assertIn('cap_drop: ["ALL"]', compose)
        self.assertIn('security_opt: ["no-new-privileges:true"]', compose)
        self.assertIn("read_only: true", compose)
        self.assertIn("pull_policy: never", compose)
        self.assertIn("internal: true", compose)
        self.assertGreaterEqual(compose.count('"127.0.0.1:'), 4)
        self.assertNotIn("network_mode: host", compose)
        self.assertNotIn("privileged: true", compose)
        self.assertNotIn("docker.sock", compose)
        self.assertNotIn("/var/run", compose)
        self.assertIn("--no-index --no-deps", compose)
        self.assertIn("--require-hashes", compose)

    def test_collector_topology_is_bounded(self) -> None:
        agent_a = self.read("config/agent-a.yaml")
        agent_b = self.read("config/agent-b.yaml")
        gateway = self.read("config/gateway.yaml")
        for agent, role in ((agent_a, "agent-a"), (agent_b, "agent-b")):
            self.assertIn("endpoint: gateway:4317", agent)
            self.assertIn("sending_queue:", agent)
            self.assertIn("queue_size: 256", agent)
            self.assertIn("retry_on_failure:", agent)
            self.assertIn("max_elapsed_time: 10s", agent)
            self.assertIn(f"value: {role}", agent)
            self.assertIn("memory_limiter", agent)
        self.assertIn("exporters:\n  debug:", gateway)
        self.assertIn("verbosity: detailed", gateway)
        self.assertIn("value: gateway", gateway)
        self.assertNotIn("prometheusremotewrite", gateway.lower())

    def test_services_encode_propagation_and_sampling(self) -> None:
        common = self.read("services/telemetry.py")
        service_a = self.read("services/service_a.py")
        service_b = self.read("services/service_b.py")
        self.assertIn("ParentBased(root=TraceIdRatioBased(ratio))", common)
        self.assertIn("DeterministicLabIdGenerator", common)
        self.assertIn("propagate.inject", common)
        self.assertIn("propagate.extract", common)
        self.assertIn('mode == "propagate"', service_a)
        self.assertIn("inject_trace_context(carrier)", service_a)
        self.assertIn("extract_trace_context(carrier)", service_b)
        self.assertIn("joined_context", service_a)

    def test_controller_fails_closed_and_uses_exact_ownership(self) -> None:
        controller = self.read("lab_controller.py")
        for token in (
            "artifact-lock-incomplete-record-reviewed-digests-first",
            '"--pull",\n                "never"',
            "com.reliability-atlas.owner-token",
            "stateIdentity",
            "rootIdentity",
            "operation.lock",
            "runtime-container-safety-contract-mismatch",
            "runtime-non-loopback-port-binding",
            "runtime-writable-bind-mount",
            "atomic_deletion_claimed=false",
            "backend_ingest_proven=false",
            "production_behavior_proven=false",
        ):
            self.assertIn(token, controller)
        self.assertIn('["docker", "container", "rm", container_id]', controller)
        self.assertNotIn("docker system prune", controller)
        self.assertNotIn("network_mode=host", controller)

    def test_readme_labels_commands_and_claim_limits(self) -> None:
        readme = self.read("README.md")
        for label in ("[READ-ONLY]", "[MUTATING]", "[DESTRUCTIVE]"):
            self.assertIn(label, readme)
        for command in (
            "bash lab.sh doctor",
            "bash lab.sh model",
            "bash lab.sh prepare --allow-network-downloads",
            "bash lab.sh setup",
            "bash lab.sh run baseline",
            "bash lab.sh run broken-context",
            "bash lab.sh recover-context",
            "bash lab.sh interrupt-gateway",
            "bash lab.sh compare-sampling",
            "bash lab.sh verify-operation",
            "bash lab.sh cleanup --expect-token TOKEN_FROM_SETUP_OR_STATUS",
        ):
            self.assertIn(command, readme)
        self.assertIn("opentelemetry_executed=false", readme)
        self.assertIn("backend_ingest_proven=false", readme)
        self.assertIn("not a canonical learner lab", readme)


if __name__ == "__main__":
    unittest.main(verbosity=2)
