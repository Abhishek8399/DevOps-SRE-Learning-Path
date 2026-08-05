\set ON_ERROR_STOP on
EXPLAIN (ANALYZE, BUFFERS, WAL, FORMAT JSON)
SELECT order_id, status, total_cents, created_at
FROM orders
WHERE customer_id = 4242
ORDER BY created_at DESC
LIMIT 20;
