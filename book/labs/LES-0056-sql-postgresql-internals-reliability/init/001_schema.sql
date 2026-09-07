\set ON_ERROR_STOP on

CREATE TYPE order_state AS ENUM ('pending', 'paid', 'cancelled');

CREATE TABLE accounts (
  account_id bigint PRIMARY KEY,
  owner_name text NOT NULL,
  balance_cents bigint NOT NULL CHECK (balance_cents >= 0)
);

CREATE TABLE orders (
  order_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id bigint NOT NULL,
  idempotency_key text NOT NULL UNIQUE,
  status order_state NOT NULL,
  total_cents integer NOT NULL CHECK (total_cents > 0),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE order_ledger (
  ledger_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id bigint NOT NULL REFERENCES orders(order_id),
  event_key text NOT NULL UNIQUE,
  event_type text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE ROLE app_user LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT CONNECT ON DATABASE reliability TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE ON accounts, orders, order_ledger TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;
