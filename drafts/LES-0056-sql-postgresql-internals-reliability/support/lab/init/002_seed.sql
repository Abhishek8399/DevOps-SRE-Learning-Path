\set ON_ERROR_STOP on

INSERT INTO accounts(account_id, owner_name, balance_cents)
VALUES (1, 'account-one', 1000000), (2, 'account-two', 1000000);

INSERT INTO orders(customer_id, idempotency_key, status, total_cents, created_at)
SELECT
  1 + (g % 10000),
  'seed-' || g,
  CASE WHEN g % 20 = 0 THEN 'cancelled'::order_state
       WHEN g % 3 = 0 THEN 'pending'::order_state
       ELSE 'paid'::order_state END,
  100 + (g % 50000),
  timestamptz '2026-01-01 00:00:00+00' + (g || ' seconds')::interval
FROM generate_series(1, 100000) AS g;

INSERT INTO order_ledger(order_id, event_key, event_type)
SELECT order_id, 'created-' || order_id, 'order-created'
FROM orders
WHERE order_id <= 1000;

ANALYZE;
