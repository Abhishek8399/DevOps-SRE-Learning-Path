# Cost and efficiency model

The lab uses no cloud account and records no currency estimate. Its real local costs are Docker disk for node and base images, three continuously running node containers during a session, CPU/memory pressure on the laptop, download time and engineering attention. Cleanup removes runtime resources while retaining the large kind node image and verified binary as intentional cache.

Production platform cost has at least five buckets:

1. Shared control plane and worker baseline, including idle headroom.
2. Network, storage, registry, telemetry and backup consumption.
3. Security, upgrades, incident response and support labor.
4. Developer waiting, failed deployments and cognitive load.
5. Opportunity cost of bespoke exceptions and duplicated team tooling.

Unit costs are more actionable than a total bill: cost per active service, successful deployment, tenant, million requests or protected recovery point. Allocate shared cost with an explicit rule and show teams which usage signals they can influence. Do not charge a team for platform baseline it cannot control.

Efficiency is not minimum utilization. Running every node near saturation removes rollout and failure headroom and converts small demand errors into incidents. Optimize after reliability constraints: right-size requests from observed demand, remove abandoned environments, bound telemetry cardinality and retention, reuse immutable artifacts, schedule noncritical work, and compare managed-service value with ownership burden.

The golden path should expose cost consequences early—for example replica count, request size, storage class, log retention and cross-zone traffic—without requiring developers to become billing experts. A cost policy needs an exception path because a more expensive design can be correct when it buys required availability, recovery or security.
