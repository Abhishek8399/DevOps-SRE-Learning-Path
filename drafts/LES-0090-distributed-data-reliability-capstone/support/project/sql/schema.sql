\set ON_ERROR_STOP on

BEGIN;

CREATE SCHEMA IF NOT EXISTS atlas;

CREATE TABLE IF NOT EXISTS atlas.orders (
    order_id text PRIMARY KEY,
    idempotency_key text NOT NULL UNIQUE,
    payload_hash text NOT NULL CHECK (payload_hash ~ '^[0-9a-f]{64}$'),
    customer_ref text NOT NULL CHECK (customer_ref ~ '^cust-[a-z0-9]{8,32}$'),
    amount_cents integer NOT NULL CHECK (amount_cents BETWEEN 1 AND 100000000),
    created_at timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS atlas.outbox (
    event_id text PRIMARY KEY,
    aggregate_id text NOT NULL REFERENCES atlas.orders(order_id),
    event_type text NOT NULL CHECK (event_type = 'order.accepted.v1'),
    event_payload jsonb NOT NULL,
    published boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL,
    published_at timestamptz
);

CREATE INDEX IF NOT EXISTS outbox_unpublished_idx
    ON atlas.outbox (created_at, event_id)
    WHERE published = false;

CREATE TABLE IF NOT EXISTS atlas.consumer_inbox (
    event_id text PRIMARY KEY,
    payload_hash text NOT NULL CHECK (payload_hash ~ '^[0-9a-f]{64}$'),
    source_partition integer NOT NULL CHECK (source_partition >= 0),
    source_offset bigint NOT NULL CHECK (source_offset >= 0),
    processed_at timestamptz NOT NULL,
    UNIQUE (source_partition, source_offset)
);

CREATE TABLE IF NOT EXISTS atlas.order_facts (
    order_id text PRIMARY KEY,
    customer_ref text NOT NULL,
    amount_cents integer NOT NULL CHECK (amount_cents > 0),
    source_event_id text NOT NULL UNIQUE REFERENCES atlas.consumer_inbox(event_id),
    materialized_at timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS atlas.quarantine (
    quarantine_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_partition integer,
    source_offset bigint,
    raw_hash text NOT NULL,
    reason_code text NOT NULL,
    observed_at timestamptz NOT NULL,
    UNIQUE (source_partition, source_offset, raw_hash)
);

CREATE OR REPLACE FUNCTION atlas.submit_order(document jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    existing atlas.orders%ROWTYPE;
    accepted_at timestamptz := clock_timestamp();
    event_identity text;
    event_document jsonb;
    field_count integer;
BEGIN
    IF document IS NULL OR jsonb_typeof(document) <> 'object' THEN
        RAISE EXCEPTION 'order_document_must_be_object';
    END IF;

    SELECT count(*) INTO field_count FROM jsonb_object_keys(document);

    IF NOT (
        document ? 'schema_version'
        AND document ? 'order_id'
        AND document ? 'idempotency_key'
        AND document ? 'payload_hash'
        AND document ? 'customer_ref'
        AND document ? 'amount_cents'
    ) OR field_count <> 6 THEN
        RAISE EXCEPTION 'order_document_fields_invalid';
    END IF;

    IF document->>'schema_version' <> '1' THEN
        RAISE EXCEPTION 'unsupported_order_schema';
    END IF;

    SELECT * INTO existing
    FROM atlas.orders
    WHERE idempotency_key = document->>'idempotency_key'
    FOR UPDATE;

    IF FOUND THEN
        IF existing.payload_hash <> document->>'payload_hash' THEN
            RAISE EXCEPTION 'idempotency_conflict';
        END IF;
        RETURN jsonb_build_object(
            'order_id', existing.order_id,
            'event_id', (
                SELECT event_id FROM atlas.outbox
                WHERE aggregate_id = existing.order_id
                ORDER BY created_at, event_id LIMIT 1
            ),
            'replayed', true
        );
    END IF;

    INSERT INTO atlas.orders (
        order_id, idempotency_key, payload_hash, customer_ref, amount_cents, created_at
    ) VALUES (
        document->>'order_id',
        document->>'idempotency_key',
        document->>'payload_hash',
        document->>'customer_ref',
        (document->>'amount_cents')::integer,
        accepted_at
    );

    event_identity := 'evt-' || substr(md5(
        (document->>'order_id') || ':' || (document->>'payload_hash')
    ), 1, 24);

    event_document := jsonb_build_object(
        'schema_version', 1,
        'event_id', event_identity,
        'event_type', 'order.accepted.v1',
        'order_id', document->>'order_id',
        'customer_ref', document->>'customer_ref',
        'amount_cents', (document->>'amount_cents')::integer,
        'occurred_at', accepted_at
    );

    INSERT INTO atlas.outbox (
        event_id, aggregate_id, event_type, event_payload, created_at
    ) VALUES (
        event_identity,
        document->>'order_id',
        'order.accepted.v1',
        event_document,
        accepted_at
    );

    RETURN jsonb_build_object(
        'order_id', document->>'order_id',
        'event_id', event_identity,
        'replayed', false
    );
END;
$function$;

COMMIT;
