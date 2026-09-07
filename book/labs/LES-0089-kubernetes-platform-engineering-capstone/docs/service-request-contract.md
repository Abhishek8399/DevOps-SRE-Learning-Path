# ServiceRequest v1alpha1 contract

The API version is `platform.atlas.dev/v1alpha1` and kind is `ServiceRequest`. The root allows only `apiVersion`, `kind`, `metadata` and `spec`. Unknown fields are errors.

Metadata requires:

- `name`: lowercase DNS-like identifier, 3–41 characters.
- `namespace`: exactly `team-a` or `team-b`.
- `owner`: lowercase DNS-like team identifier, 3–33 characters.

Spec requires a versioned image, one to five replicas, a non-privileged application port, CPU/memory requests and limits, and a boolean local-exposure decision. `latest` is forbidden. Quantity syntax receives definitive validation from Kubernetes; the local boundary limits size and type before rendering.

Generation produces a ServiceAccount without token automount, Deployment with rolling and security controls, Service, NetworkPolicy, optional PodDisruptionBudget and catalog record. Outputs are atomic and deterministic. The verifier regenerates to a temporary directory and byte-compares both committed outputs.

## Compatibility

v1alpha1 is experimental. A breaking field rename, semantic change or newly required field needs a new API version or explicit migration. Generated manifest changes can be breaking even when the request schema is unchanged—for example a stricter security context or new probe. Review generator version, request and generated diff together.

No default is hidden in the request processor. This keeps user intent reviewable, although Kubernetes still performs API defaulting. Production evolution should publish defaulting, validation and conversion behavior, plus deprecation dates and an automated migration path.
