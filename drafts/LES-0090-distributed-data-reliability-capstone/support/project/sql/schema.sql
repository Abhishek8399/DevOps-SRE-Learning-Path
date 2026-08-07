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

CREATE TABLE IF NOT EXISTS atlas.delivery_attempts (
    source_partition integer NOT NULL CHECK (source_partition >= 0),
    source_offset bigint NOT NULL CHECK (source_offset >= 0),
    event_id text NOT NULL,
    payload_hash text NOT NULL CHECK (payload_hash ~ '^[0-9a-f]{64}$'),
    duplicate boolean NOT NULL,
    observed_at timestamptz NOT NULL,
    PRIMARY KEY (source_partition, source_offset)
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
    event_id text,
    raw_hash text NOT NULL,
    reason_code text NOT NULL,
    observed_at timestamptz NOT NULL,
    UNIQUE (source_partition, source_offset, raw_hash)
);

ALTER TABLE atlas.quarantine ADD COLUMN IF NOT EXISTS event_id text;

CREATE TABLE IF NOT EXISTS atlas.pipeline_runs (
    run_id text PRIMARY KEY CHECK (run_id ~ '^run-[0-9a-f]{32}$'),
    job_name text NOT NULL CHECK (job_name = 'order_fact_reconciliation'),
    input_dataset text NOT NULL CHECK (input_dataset = 'atlas.orders'),
    output_dataset text NOT NULL CHECK (output_dataset = 'atlas.order_facts'),
    status text NOT NULL CHECK (status IN ('pass', 'fail')),
    metrics jsonb NOT NULL,
    started_at timestamptz NOT NULL,
    completed_at timestamptz NOT NULL CHECK (completed_at >= started_at)
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

CREATE OR REPLACE FUNCTION atlas.process_event(document jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    event_document jsonb;
    existing atlas.consumer_inbox%ROWTYPE;
    observed_at timestamptz := clock_timestamp();
    duplicate_delivery boolean := false;
    attempt_inserted integer := 0;
BEGIN
    IF document IS NULL OR jsonb_typeof(document) <> 'object' THEN
        RAISE EXCEPTION 'delivery_document_must_be_object';
    END IF;
    IF NOT (
        document ? 'source_partition'
        AND document ? 'source_offset'
        AND document ? 'payload_hash'
        AND document ? 'event'
    ) OR (SELECT count(*) FROM jsonb_object_keys(document)) <> 4 THEN
        RAISE EXCEPTION 'delivery_document_fields_invalid';
    END IF;

    event_document := document->'event';
    IF jsonb_typeof(event_document) <> 'object'
       OR NOT (
           event_document ? 'schema_version'
           AND event_document ? 'event_id'
           AND event_document ? 'event_type'
           AND event_document ? 'order_id'
           AND event_document ? 'customer_ref'
           AND event_document ? 'amount_cents'
           AND event_document ? 'occurred_at'
       )
       OR (SELECT count(*) FROM jsonb_object_keys(event_document)) <> 7
       OR event_document->>'schema_version' <> '1'
       OR event_document->>'event_type' <> 'order.accepted.v1' THEN
        RAISE EXCEPTION 'event_contract_invalid';
    END IF;

    INSERT INTO atlas.delivery_attempts (
        source_partition, source_offset, event_id, payload_hash, duplicate, observed_at
    ) VALUES (
        (document->>'source_partition')::integer,
        (document->>'source_offset')::bigint,
        event_document->>'event_id',
        document->>'payload_hash',
        false,
        observed_at
    ) ON CONFLICT (source_partition, source_offset) DO NOTHING;
    GET DIAGNOSTICS attempt_inserted = ROW_COUNT;

    SELECT * INTO existing
    FROM atlas.consumer_inbox
    WHERE event_id = event_document->>'event_id'
    FOR UPDATE;

    IF FOUND THEN
        IF existing.payload_hash <> document->>'payload_hash' THEN
            RAISE EXCEPTION 'event_identity_conflict';
        END IF;
        duplicate_delivery := true;
        IF attempt_inserted = 1 THEN
            UPDATE atlas.delivery_attempts
            SET duplicate = true
            WHERE source_partition = (document->>'source_partition')::integer
              AND source_offset = (document->>'source_offset')::bigint;
        END IF;
    ELSE
        INSERT INTO atlas.consumer_inbox (
            event_id, payload_hash, source_partition, source_offset, processed_at
        ) VALUES (
            event_document->>'event_id',
            document->>'payload_hash',
            (document->>'source_partition')::integer,
            (document->>'source_offset')::bigint,
            observed_at
        );

        INSERT INTO atlas.order_facts (
            order_id, customer_ref, amount_cents, source_event_id, materialized_at
        ) VALUES (
            event_document->>'order_id',
            event_document->>'customer_ref',
            (event_document->>'amount_cents')::integer,
            event_document->>'event_id',
            observed_at
        );
    END IF;

    RETURN jsonb_build_object(
        'event_id', event_document->>'event_id',
        'order_id', event_document->>'order_id',
        'duplicate', duplicate_delivery
    );
END;
$function$;

COMMIT;
