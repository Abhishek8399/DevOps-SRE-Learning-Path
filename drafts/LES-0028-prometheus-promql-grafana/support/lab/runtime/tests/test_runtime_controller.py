from __future__ import annotations

import os
import tempfile
import unittest
from pathlib import Path

import runtime_controller as controller


class RuntimeControllerContracts(unittest.TestCase):
    def test_exact_artifact_lock_and_source_receipts_are_complete(self) -> None:
        refs = controller.image_refs()
        self.assertEqual(set(refs), {"python", "prometheus", "alertmanager", "grafana"})
        for ref in refs.values():
            self.assertRegex(ref, r"^docker\.io/.+@sha256:[0-9a-f]{64}$")
        receipts = controller.source_receipts()
        self.assertIn("runtime_controller.py", receipts)
        self.assertIn("compose.yaml", receipts)
        self.assertTrue(all(len(value) == 64 for value in receipts.values()))

    def test_active_lock_refuses_a_second_operation(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0028-runtime-lock-") as temporary:
            state_path = Path(temporary) / "state"
            state_path.mkdir(mode=0o700)
            state = {"_statePath": state_path, "token": "a" * 32}
            with controller.operation_lock(state):
                with self.assertRaisesRegex(
                    controller.LabError, "another-runtime-operation-is-active"
                ) as raised:
                    with controller.operation_lock(state):
                        self.fail("second operation acquired the active lock")
                self.assertEqual(raised.exception.code, 73)
            self.assertFalse((state_path / "operation.lock").exists())

    def test_matching_stale_sentinel_is_reclaimed(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0028-runtime-lock-") as temporary:
            state_path = Path(temporary) / "state"
            state_path.mkdir(mode=0o700)
            state = {"_statePath": state_path, "token": "b" * 32}
            lock = state_path / "operation.lock"
            lock.write_text(state["token"] + "\n", encoding="utf-8")
            lock.chmod(0o600)
            with controller.operation_lock(state):
                self.assertTrue(lock.is_file())
            self.assertFalse(lock.exists())

    def test_foreign_stale_sentinel_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0028-runtime-lock-") as temporary:
            state_path = Path(temporary) / "state"
            state_path.mkdir(mode=0o700)
            state = {"_statePath": state_path, "token": "c" * 32}
            lock = state_path / "operation.lock"
            lock.write_text("d" * 32 + "\n", encoding="utf-8")
            lock.chmod(0o600)
            with self.assertRaisesRegex(
                controller.LabError, "operation-lock-token-mismatch"
            ) as raised:
                with controller.operation_lock(state):
                    self.fail("foreign sentinel was accepted")
            self.assertEqual(raised.exception.code, 65)
            self.assertTrue(lock.is_file())

    def test_successful_finalizing_lock_removes_exact_state(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0028-runtime-lock-") as temporary:
            state_path = Path(temporary) / "state"
            state_path.mkdir(mode=0o700)
            state_file = state_path / "state.json"
            state_file.write_text("{}\n", encoding="utf-8")
            state_file.chmod(0o600)
            state = {
                "_statePath": state_path,
                "stateIdentity": controller.identity(state_path),
                "token": "e" * 32,
            }
            with controller.operation_lock(state, delete_state_on_success=True):
                self.assertTrue((state_path / "operation.lock").is_file())
            self.assertFalse(state_path.exists())

    def test_failed_finalizing_operation_preserves_state(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0028-runtime-lock-") as temporary:
            state_path = Path(temporary) / "state"
            state_path.mkdir(mode=0o700)
            state_file = state_path / "state.json"
            state_file.write_text("{}\n", encoding="utf-8")
            state_file.chmod(0o600)
            state = {
                "_statePath": state_path,
                "stateIdentity": controller.identity(state_path),
                "token": "f" * 32,
            }
            with self.assertRaisesRegex(RuntimeError, "injected-failure"):
                with controller.operation_lock(state, delete_state_on_success=True):
                    raise RuntimeError("injected-failure")
            self.assertTrue(state_file.is_file())
            self.assertFalse((state_path / "operation.lock").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
