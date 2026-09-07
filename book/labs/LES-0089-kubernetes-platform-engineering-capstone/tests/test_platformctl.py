from __future__ import annotations

import copy
import json
import unittest
from pathlib import Path

import platformctl


ROOT = Path(__file__).resolve().parents[1]


class PlatformContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.request = json.loads((ROOT / "requests/payments-api.json").read_text())

    def test_valid_request_is_accepted(self) -> None:
        self.assertEqual(platformctl.validate(self.request)["metadata"]["name"], "payments-api")

    def test_unknown_field_is_rejected(self) -> None:
        candidate = copy.deepcopy(self.request)
        candidate["spec"]["privileged"] = True
        with self.assertRaisesRegex(platformctl.ContractError, "unknown"):
            platformctl.validate(candidate)

    def test_latest_image_is_rejected(self) -> None:
        candidate = copy.deepcopy(self.request)
        candidate["spec"]["image"] = "example/service:latest"
        with self.assertRaisesRegex(platformctl.ContractError, "latest"):
            platformctl.validate(candidate)

    def test_cross_tenant_namespace_is_rejected(self) -> None:
        candidate = copy.deepcopy(self.request)
        candidate["metadata"]["namespace"] = "kube-system"
        with self.assertRaisesRegex(platformctl.ContractError, "team-a"):
            platformctl.validate(candidate)

    def test_renderer_includes_operational_controls(self) -> None:
        output = platformctl.render(platformctl.validate(self.request))
        for expected in (
            "kind: Deployment",
            "kind: ServiceAccount",
            "kind: Service",
            "kind: NetworkPolicy",
            "kind: PodDisruptionBudget",
            "allowPrivilegeEscalation: false",
            'drop: ["ALL"]',
            "readOnlyRootFilesystem: true",
            "maxUnavailable: 0",
            "nodePort: 30080",
        ):
            self.assertIn(expected, output)

    def test_catalog_keeps_owner_and_runbook(self) -> None:
        entry = platformctl.catalog_record(platformctl.validate(self.request))
        self.assertEqual(entry["metadata"]["owner"], "payments-team")
        self.assertEqual(entry["spec"]["runbook"], "docs/runbooks/payments-api.md")


if __name__ == "__main__":
    unittest.main()
