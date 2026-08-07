# LES-0089 draft status

Status: **source-locked quarantined capstone; implementation, independent transfer, formal review and publication pending**

This directory reserves `LES-0089` / `V11-L02` / `CAP-002` for the Kubernetes platform engineering capstone. Its working route is `/book/capstones/kubernetes-platform-engineering-capstone`, volume `11-capstones`, order 2 and domain `capstone-engineering`.

The learner builds one disposable local platform around a kind cluster: versioned cluster configuration, tenant namespaces, quotas, RBAC, Pod Security, native CEL admission, a golden-path service contract, rendered Kubernetes resources, Git-owned desired state, pull-shaped reconciliation, rollout and rollback, SLO/capacity evidence, disaster reconstruction, threat and cost analysis, and a developer usability test.

The pinned baseline is kind `v0.31.0` with `kindest/node:v1.35.0@sha256:452d707d4862f52530247495d180205e029056831160e22870e37e3f6c1ac31f`. This pairing comes from the kind release. Kubernetes 1.35 remains supported on the 2026-08-07 source-review date, but 1.35.0 is not its latest security patch. The verifier therefore teaches immutable reproduction and update review as separate duties.

The lab is local and disposable. It does not represent cloud, managed Kubernetes, high availability, a production CNI, production secrets, production identity, accepted SLO/capacity, an organizational platform, or learner mastery. kind documents disposal and recreation—not an in-place update strategy—as its cluster lifecycle. Any replacement exercise must preserve desired state and evidence, recreate under a new cluster name, validate, and only then remove the old fixture.

Publication remains blocked until the project, assessments, manuscript, Ubuntu/Docker runtime evidence, independent hidden-fault transfer, technical/security/reliability/accessibility/instructional review and reader integration pass.
