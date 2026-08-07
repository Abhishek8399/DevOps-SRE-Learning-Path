import base64
import json
import unittest

import datactl


def order():
    return {
        "schema_version": 1,
        "order_id": "ord-00000001",
        "idempotency_key": "idem-00000001",
        "customer_ref": "cust-00000001",
        "amount_cents": 2599,
    }


class OrderContractTests(unittest.TestCase):
    def test_valid_order_has_stable_hash(self):
        first = datactl.validate_order(order())
        second = datactl.validate_order(dict(reversed(list(order().items()))))
        self.assertEqual(first["payload_hash"], second["payload_hash"])
        self.assertRegex(first["payload_hash"], r"^[0-9a-f]{64}$")

    def test_unknown_and_missing_fields_fail_closed(self):
        candidate = order()
        candidate["privileged"] = True
        with self.assertRaisesRegex(datactl.ContractError, "unknown"):
            datactl.validate_order(candidate)
        candidate = order()
        del candidate["customer_ref"]
        with self.assertRaisesRegex(datactl.ContractError, "missing"):
            datactl.validate_order(candidate)

    def test_boolean_and_out_of_range_amounts_are_rejected(self):
        for value in (True, 0, 100_000_001, "2599"):
            candidate = order()
            candidate["amount_cents"] = value
            with self.assertRaises(datactl.ContractError):
                datactl.validate_order(candidate)

    def test_identifiers_are_narrow(self):
        for field, value in (
            ("order_id", "../orders"),
            ("idempotency_key", "same"),
            ("customer_ref", "customer@example.com"),
        ):
            candidate = order()
            candidate[field] = value
            with self.assertRaises(datactl.ContractError):
                datactl.validate_order(candidate)

    def test_sql_envelope_contains_only_base64_payload(self):
        normalized = datactl.validate_order(order())
        sql = datactl.sql_for_order(normalized)
        encoded = sql.split("decode('", 1)[1].split("'", 1)[0]
        decoded = json.loads(base64.b64decode(encoded).decode("ascii"))
        self.assertEqual(decoded, normalized)
        self.assertNotIn(normalized["order_id"], sql)

    def test_request_loader_refuses_paths_outside_project_requests(self):
        with self.assertRaisesRegex(datactl.ContractError, "under project requests"):
            datactl.load_request(datactl.PROJECT_ROOT / "toolchain.env")

    def test_event_identity_is_narrow(self):
        self.assertIsNotNone(datactl.EVENT_ID.fullmatch("evt-" + "a" * 24))
        self.assertIsNone(datactl.EVENT_ID.fullmatch("evt-../../unexpected"))

    def test_delivery_line_exposes_partition_offset_key_and_payload(self):
        line = (
            'Partition:2|Offset:17|evt-' + 'a' * 24
            + '|{"event_id":"evt-' + 'a' * 24 + '"}'
        )
        match = datactl.DELIVERY_LINE.fullmatch(line)
        self.assertIsNotNone(match)
        self.assertEqual(match.group("partition"), "2")
        self.assertEqual(match.group("offset"), "17")

    def test_malformed_delivery_line_is_rejected_by_pattern(self):
        self.assertIsNone(datactl.DELIVERY_LINE.fullmatch("message consumed"))

    def test_event_contract_accepts_only_versioned_known_shape(self):
        event = {
            "schema_version": 1,
            "event_id": "evt-" + "a" * 24,
            "event_type": "order.accepted.v1",
            "order_id": "ord-00000001",
            "customer_ref": "cust-00000001",
            "amount_cents": 1,
            "occurred_at": "2026-08-07T00:00:00Z",
        }
        self.assertEqual(datactl.validate_event(event), event)
        event["schema_version"] = 99
        with self.assertRaisesRegex(datactl.ContractError, "version"):
            datactl.validate_event(event)


if __name__ == "__main__":
    unittest.main()
