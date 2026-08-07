from __future__ import annotations

import unittest

from ops import measure_slo


class SloTests(unittest.TestCase):
    def test_nearest_rank_percentile(self) -> None:
        self.assertEqual(measure_slo.percentile([1, 2, 3, 4, 100], 0.95), 100)

    def test_evaluate_counts_only_eligible_events(self) -> None:
        events = [
            {"eligible": True, "success": True, "latencyMs": 10},
            {"eligible": True, "success": False, "latencyMs": 50},
            {"eligible": False, "success": False, "latencyMs": 1000},
        ]
        receipt = measure_slo.evaluate(events, 0.90, 20)
        self.assertEqual(receipt["eligibleEvents"], 2)
        self.assertEqual(receipt["failedEvents"], 1)
        self.assertEqual(receipt["availability"], 0.5)
        self.assertFalse(receipt["objectiveMet"])

    def test_empty_window_is_rejected(self) -> None:
        with self.assertRaises(measure_slo.MeasurementError):
            measure_slo.evaluate([], 0.99, 200)

    def test_external_probe_is_rejected(self) -> None:
        with self.assertRaisesRegex(measure_slo.MeasurementError, "loopback"):
            measure_slo.validate_loopback("https://example.com/readyz")


if __name__ == "__main__":
    unittest.main()
