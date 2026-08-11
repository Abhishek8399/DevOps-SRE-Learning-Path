# Caches and Redis: fast is useful only when correct

A cache is a disposable copy that trades freshness, memory, and complexity for lower latency or load. Redis-like systems add data structures and coordination patterns, but they do not replace an authoritative database by default.

```text
request -> cache lookup --hit--> response
              | miss               |
              v                    |
          authoritative store -> fill/invalidate -> response
```

## Freshness and invalidation

Define what stale data is acceptable, TTL, invalidation trigger, version/key scheme, and behavior when the cache is unavailable. A cache hit proves only that a value exists in the cache; it does not prove freshness or authorization for the current caller.

## Stampedes and hot keys

When a popular key expires, many callers can overload the origin. Use jittered TTLs, request coalescing, bounded refresh concurrency, stale-while-revalidate, or prewarming. Measure hit ratio, miss latency, origin load, key size, hot-key concentration, and eviction—not hit ratio alone.

## Memory and eviction

Set memory limits and an explicit eviction policy appropriate to the data. Eviction is a signal, not a repair; protect critical keys or rebuild them from the source. Serialization, large values, and unbounded lists can cause memory pressure and latency spikes.

## Failure and rebuild

Assume cache loss. The source must remain authoritative, rebuild must be bounded, and a cold cache must not create a database outage. Separate cache availability from correctness and authorization decisions.

## Safe local exercise

Use a local JSON file as the source and a temporary directory as a cache. Implement TTL metadata, versioned keys, a miss counter, bounded rebuild concurrency, and invalidation after a source update. Delete the cache and prove the source rebuilds correct values. Use no Redis service or production data.

## Triage sequence

1. Identify key, version, tenant, age, TTL, hit/miss, eviction, and source value.
2. Compare cache behavior with origin latency, load, errors, and freshness.
3. Protect the origin from stampede with bounded refresh or temporary bypass.
4. Invalidate/rebuild only the scoped keys and preserve source authority.
5. Verify user correctness, authorization, hit/miss behavior, and cold-start recovery.

## Interview defense

**Question:** “The cache hit ratio is 99% but users see stale data. Why?”

**Strong answer:** “Hit ratio says nothing about freshness. I inspect TTL/version/invalidation, update ordering, tenant keys, and the source-of-truth path, then choose bounded invalidation or a read-through correction with user-SLI verification.”

**Question:** “How do you prevent a cache outage from taking down the database?”

**Strong answer:** “Bound misses and rebuild concurrency, use request coalescing and rate limits, serve safe stale data where allowed, protect critical origin capacity, and monitor cold-start behavior. The cache remains an optimization, not the authority.”

## Teach-back checkpoint

Design a cache contract. State source of truth, freshness budget, key/version, invalidation, TTL, stampede guard, eviction policy, authorization boundary, and rebuild proof.
