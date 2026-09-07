from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from atlas_service.storage import IdempotencyConflict, Store
from atlas_service.telemetry import request_context


class StoreTests(unittest.TestCase):
    def test_idempotency_replays_same_request_and_rejects_different_request(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            store = Store(Path(directory) / "state.db")
            store.initialize()
            first = store.create_item("alpha", "test-key-0001")
            replay = store.create_item("alpha", "test-key-0001")
            self.assertTrue(first.created)
            self.assertFalse(replay.created)
            self.assertEqual(first.item, replay.item)
            self.assertEqual(store.item_count(), 1)
            with self.assertRaises(IdempotencyConflict):
                store.create_item("beta", "test-key-0001")

    def test_online_backup_is_integral_snapshot(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            store = Store(root / "state.db")
            store.initialize()
            store.create_item("alpha", "test-key-0002")
            backup = root / "backups" / "snapshot.db"
            store.backup_to(backup)
            restored = Store(backup)
            self.assertTrue(restored.ready())
            self.assertEqual(restored.item_count(), 1)


class TelemetryTests(unittest.TestCase):
    def test_invalid_traceparent_is_replaced(self) -> None:
        context = request_context("00-" + "0" * 32 + "-" + "0" * 16 + "-01", "bad id!")
        self.assertNotEqual(context.trace_id, "0" * 32)
        self.assertRegex(context.request_id, r"^[0-9a-f]{24}$")

    def test_valid_trace_id_is_propagated_with_new_span(self) -> None:
        trace_id = "1" * 32
        context = request_context(f"00-{trace_id}-{'2' * 16}-01", "request-123")
        self.assertEqual(context.trace_id, trace_id)
        self.assertNotEqual(context.span_id, "2" * 16)
        self.assertEqual(context.request_id, "request-123")


if __name__ == "__main__":
    unittest.main()
