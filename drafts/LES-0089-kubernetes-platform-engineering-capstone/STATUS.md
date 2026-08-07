# LES-0089 draft status

Status: **substantive quarantined lesson candidate; independent transfer, formal review and publication pending**

This quarantined directory reserves `LES-0089` / `V11-L02` / `CAP-002` for the Kubernetes platform engineering capstone. The working route is `/book/capstones/kubernetes-platform-engineering-capstone`, volume `11-capstones`, order 2 and domain `capstone-engineering`.

The project is a disposable local developer platform built around a three-node kind cluster. It connects a strict versioned ServiceRequest, deterministic manifest/catalog generation, Git-bound reconciliation, tenant RBAC, quotas, LimitRanges, Restricted Pod Security, native CEL admission, workload security, rollout/rollback, bounded SLO arithmetic, declaration reconstruction, threat/cost/capacity/upgrade analysis and a usability-test protocol.

The source lock contains twenty official or primary references. The pinned baseline is kind `v0.31.0` with `kindest/node:v1.35.0@sha256:452d707d4862f52530247495d180205e029056831160e22870e37e3f6c1ac31f`. The project installer verifies the published Linux-amd64 kind checksum before execution. Reproducible identity and security-patch currency remain separate duties.

The implementation uses an explicit project kubeconfig and loopback-only API/NodePort. The generator rejects unknown fields, unsupported tenants, mutable latest tags, missing resources and unsafe workload posture. The reconciler resolves a full commit, reads the allowlisted path from Git rather than the working tree, hashes desired bytes, performs server-side diff/apply and records field ownership. It intentionally models the GitOps control loop but is not represented as a remote, continuously running, highly available Flux or Argo CD controller.

Ubuntu 24.04 WSL and Docker Desktop 29.6.2 produced this absent-to-absent evidence:

```text
verify=pass tests=12 nodes=3 policies=3 rbac=3 git_reconcile=true
drift=true rollback=true probes=100 reconstruction=true
external_calls=tool-download-and-image-pull-only production_actions=none
cleanup=pass cluster=absent state=absent workload_image=absent
```

All three nodes reached Ready at Kubernetes v1.35.0. Independent server tests proved CEL owner denial, Restricted Pod Security denial and ResourceQuota denial. Namespace RBAC proved same-tenant Deployment access, Secret denial and cross-tenant Deployment denial. A manual replica change was corrected from committed state. An unavailable image candidate was rolled back to version 1.0.0 and the loopback user path recovered. The bounded run completed 100/100 eligible probes with local p95 12.881 ms. Namespace deletion and declarative reconstruction passed; application-data restore was explicitly not exercised. Exact cleanup removed the named cluster, project state and workload image without global prune.

The lesson candidate contains 14,423 whitespace-counted words in the exact eighteen-section structure, six diagrams, twelve command contracts, two labs, six incidents, twenty retrieval questions with complete answers and sixteen product-company scenarios. Three schema-backed assessments cover diagnostic, guided and independent transfer. Their rubrics total 50, 100 and 100 points. The independent assessment is reviewer-only and contains no model answer.

Direct lesson schema validation passes with zero issues. All three assessments and twenty reference records pass their direct schemas. The guided runtime evidence belongs to the repository candidate, not to a learner.

Known proof limits remain material: kind nodes share one host and failure domain; the default CNI was not proved with negative packet tests; no hostile-tenant boundary, signed registry promotion, production identity/secrets, etcd restore, persistent application-data restore, external-resource reconciliation, in-place cluster upgrade, sustained load, accepted SLO/RPO/RTO, independent usability session, formal review or learner mastery was demonstrated.

Canonical content/registry, schema/reader, lint, typecheck and production-build gates pass while the candidate remains deliberately outside the live registry. Publication remains blocked until the candidate is integrated through the repository publication workflow and formal technical, security, reliability, accessibility, instructional and assessment review is complete. Mastery remains blocked until reviewer-observed independent hidden-fault transfer and delayed recall evidence exist.
