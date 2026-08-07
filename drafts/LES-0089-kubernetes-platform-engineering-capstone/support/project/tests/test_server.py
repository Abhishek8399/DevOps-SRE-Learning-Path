from __future__ import annotations

import unittest

from workload import server


class WorkloadTests(unittest.TestCase):
    def test_version_is_immutable_contract(self) -> None:
        self.assertEqual(server.VERSION, "1.0.0")

    def test_metrics_begin_empty(self) -> None:
        with server.LOCK:
            server.REQUESTS.clear()
            self.assertEqual(server.REQUESTS, {})


if __name__ == "__main__":
    unittest.main()
