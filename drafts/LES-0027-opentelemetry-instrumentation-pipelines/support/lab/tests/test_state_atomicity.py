from __future__ import annotations

import inspect
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import lab_controller as controller


class StateAtomicityContracts(unittest.TestCase):
    def test_setup_failure_before_publish_removes_staging_and_root(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0027-state-test-") as temporary:
            parent = Path(temporary)
            state_path = parent / "state.d"
            setup_path = parent / "state.d.setup"
            root_path = parent / "runtime-root"

            def fake_mkdtemp(*_args: object, **_kwargs: object) -> str:
                root_path.mkdir(mode=0o700)
                return str(root_path)

            parsed = {
                "refs": {
                    "python": "docker.io/library/python@sha256:" + "1" * 64,
                    "collector": (
                        "docker.io/otel/opentelemetry-collector-contrib@sha256:"
                        + "2" * 64
                    ),
                },
                "digest": "3" * 64,
            }
            with (
                mock.patch.object(controller, "STATE_PATH", state_path),
                mock.patch.object(controller, "STATE_SETUP_PATH", setup_path),
                mock.patch.object(
                    controller, "STATE_RECOVERY_GLOB", "state.d.cleanup.*"
                ),
                mock.patch.object(
                    controller, "require_offline_runtime", return_value=parsed
                ),
                mock.patch.object(controller, "validate_configs"),
                mock.patch.object(controller, "container_ids", return_value=[]),
                mock.patch.object(controller, "network_ids", return_value=[]),
                mock.patch.object(controller.tempfile, "mkdtemp", fake_mkdtemp),
                mock.patch.object(
                    controller,
                    "write_json_exclusive",
                    side_effect=RuntimeError("injected-state-write-failure"),
                ),
            ):
                with self.assertRaisesRegex(
                    RuntimeError, "injected-state-write-failure"
                ):
                    controller.setup()

            self.assertFalse(state_path.exists())
            self.assertFalse(setup_path.exists())
            self.assertFalse(root_path.exists())

    def test_operation_lock_follows_atomically_renamed_state(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0027-lock-test-") as temporary:
            parent = Path(temporary)
            active = parent / "active"
            recovery = parent / "recovery"
            active.mkdir(mode=0o700)
            state = {"_statePath": active, "token": "a" * 32}

            with controller.operation_lock(state):
                self.assertTrue((active / "operation.lock").is_file())
                os.rename(active, recovery)
                state["_statePath"] = recovery

            self.assertFalse((recovery / "operation.lock").exists())

    def test_successful_finalizing_lock_removes_the_state_directory(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0027-lock-test-") as temporary:
            state_path = Path(temporary) / "active"
            state_path.mkdir(mode=0o700)
            (state_path / "state.json").write_text("{}\n", encoding="utf-8")
            state = {
                "_statePath": state_path,
                "stateIdentity": controller.identity(state_path),
                "token": "f" * 32,
            }

            with controller.operation_lock(state, delete_state_on_success=True):
                self.assertTrue((state_path / "operation.lock").is_file())

            self.assertFalse(state_path.exists())

    def test_active_operation_lock_refuses_a_second_operation(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0027-lock-test-") as temporary:
            state_path = Path(temporary) / "active"
            state_path.mkdir(mode=0o700)
            state = {"_statePath": state_path, "token": "b" * 32}

            with controller.operation_lock(state):
                with self.assertRaisesRegex(
                    controller.LabError, "another-lab-operation-is-active"
                ) as raised:
                    with controller.operation_lock(state):
                        self.fail("second operation unexpectedly acquired the lock")
                self.assertEqual(raised.exception.code, 73)

            self.assertFalse((state_path / "operation.lock").exists())

    def test_matching_stale_lock_is_reclaimed(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0027-lock-test-") as temporary:
            state_path = Path(temporary) / "active"
            state_path.mkdir(mode=0o700)
            state = {"_statePath": state_path, "token": "c" * 32}
            lock = state_path / "operation.lock"
            controller.write_exclusive(lock, (state["token"] + "\n").encode())

            with controller.operation_lock(state):
                self.assertTrue(lock.is_file())

            self.assertFalse(lock.exists())

    def test_foreign_stale_lock_token_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory(prefix="les0027-lock-test-") as temporary:
            state_path = Path(temporary) / "active"
            state_path.mkdir(mode=0o700)
            state = {"_statePath": state_path, "token": "d" * 32}
            lock = state_path / "operation.lock"
            controller.write_exclusive(lock, ("e" * 32 + "\n").encode())

            with self.assertRaisesRegex(
                controller.LabError, "operation-lock-token-mismatch"
            ) as raised:
                with controller.operation_lock(state):
                    self.fail("foreign stale lock unexpectedly accepted")
            self.assertEqual(raised.exception.code, 65)
            self.assertTrue(lock.is_file())

    def test_cleanup_locks_before_state_rename(self) -> None:
        source = inspect.getsource(controller.cleanup)
        self.assertLess(
            source.index("with operation_lock(state, delete_state_on_success=True)"),
            source.index("os.rename(candidate, recovery)"),
        )
        self.assertLess(
            source.index("with operation_lock(state, delete_state_on_success=True)"),
            source.index("remove_runtime_resources(state)"),
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
