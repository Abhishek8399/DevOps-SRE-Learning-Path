#!/usr/bin/env python3
"""Validate a small platform API and render deterministic Kubernetes desired state."""

from __future__ import annotations

import argparse
import json
import os
import re
import tempfile
from pathlib import Path
from typing import Any

NAME = re.compile(r"^[a-z][a-z0-9-]{1,39}[a-z0-9]$")
OWNER = re.compile(r"^[a-z][a-z0-9-]{1,31}[a-z0-9]$")
IMAGE = re.compile(r"^[A-Za-z0-9._/@:-]+$")
TENANTS = {"team-a", "team-b"}


class ContractError(ValueError):
    pass


def load_request(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ContractError(f"cannot read request: {error}") from error
    if not isinstance(value, dict):
        raise ContractError("request root must be an object")
    return value


def require_map(value: Any, field: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ContractError(f"{field} must be an object")
    return value


def validate(request: dict[str, Any]) -> dict[str, Any]:
    allowed_root = {"apiVersion", "kind", "metadata", "spec"}
    unknown = sorted(set(request) - allowed_root)
    if unknown:
        raise ContractError(f"unknown root fields: {', '.join(unknown)}")
    if request.get("apiVersion") != "platform.atlas.dev/v1alpha1":
        raise ContractError("apiVersion must be platform.atlas.dev/v1alpha1")
    if request.get("kind") != "ServiceRequest":
        raise ContractError("kind must be ServiceRequest")

    metadata = require_map(request.get("metadata"), "metadata")
    spec = require_map(request.get("spec"), "spec")
    if set(metadata) != {"name", "namespace", "owner"}:
        raise ContractError("metadata requires exactly name, namespace and owner")
    allowed_spec = {
        "image", "replicas", "port", "cpuRequest", "cpuLimit",
        "memoryRequest", "memoryLimit", "exposeLocal",
    }
    unknown_spec = sorted(set(spec) - allowed_spec)
    missing_spec = sorted(allowed_spec - set(spec))
    if unknown_spec or missing_spec:
        raise ContractError(
            f"spec mismatch missing={missing_spec or 'none'} unknown={unknown_spec or 'none'}"
        )

    name = metadata["name"]
    owner = metadata["owner"]
    namespace = metadata["namespace"]
    image = spec["image"]
    if not isinstance(name, str) or not NAME.fullmatch(name):
        raise ContractError("metadata.name must be lowercase DNS-like text, 3-41 characters")
    if not isinstance(owner, str) or not OWNER.fullmatch(owner):
        raise ContractError("metadata.owner must be lowercase DNS-like text, 3-33 characters")
    if namespace not in TENANTS:
        raise ContractError(f"metadata.namespace must be one of {sorted(TENANTS)}")
    if not isinstance(image, str) or not IMAGE.fullmatch(image):
        raise ContractError("spec.image contains unsupported characters")
    if image.endswith(":latest") or (":" not in image and "@sha256:" not in image):
        raise ContractError("spec.image requires an immutable version tag or digest; latest is forbidden")
    if not isinstance(spec["replicas"], int) or not 1 <= spec["replicas"] <= 5:
        raise ContractError("spec.replicas must be an integer from 1 through 5")
    if not isinstance(spec["port"], int) or not 1024 <= spec["port"] <= 65535:
        raise ContractError("spec.port must be an integer from 1024 through 65535")
    if not isinstance(spec["exposeLocal"], bool):
        raise ContractError("spec.exposeLocal must be boolean")
    for field in ("cpuRequest", "cpuLimit", "memoryRequest", "memoryLimit"):
        if not isinstance(spec[field], str) or not spec[field] or len(spec[field]) > 16:
            raise ContractError(f"spec.{field} must be a short Kubernetes quantity")
    return request


def render(request: dict[str, Any]) -> str:
    metadata = request["metadata"]
    spec = request["spec"]
    name, namespace, owner = metadata["name"], metadata["namespace"], metadata["owner"]
    ingress = f"""    - ports:
        - protocol: TCP
          port: {spec["port"]}""" if spec["exposeLocal"] else f"""    - from:
        - podSelector: {{}}
      ports:
        - protocol: TCP
          port: {spec["port"]}"""
    node_port = """
  type: NodePort
  ports:
    - name: http
      port: {port}
      targetPort: http
      nodePort: 30080""".format(port=spec["port"]) if spec["exposeLocal"] else """
  type: ClusterIP
  ports:
    - name: http
      port: {port}
      targetPort: http""".format(port=spec["port"])
    pdb = f"""---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {name}
  namespace: {namespace}
  labels:
    platform.atlas.dev/owner: {owner}
    platform.atlas.dev/service: {name}
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: {name}
""" if spec["replicas"] > 1 else ""

    return f"""apiVersion: v1
kind: ServiceAccount
metadata:
  name: runtime-{name}
  namespace: {namespace}
  labels:
    platform.atlas.dev/owner: {owner}
    platform.atlas.dev/service: {name}
automountServiceAccountToken: false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {name}
  namespace: {namespace}
  labels:
    app.kubernetes.io/name: {name}
    app.kubernetes.io/managed-by: atlas-platform
    platform.atlas.dev/owner: {owner}
    platform.atlas.dev/service: {name}
spec:
  replicas: {spec["replicas"]}
  revisionHistoryLimit: 3
  progressDeadlineSeconds: 120
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: {name}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {name}
        platform.atlas.dev/owner: {owner}
        platform.atlas.dev/service: {name}
    spec:
      serviceAccountName: runtime-{name}
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: {name}
      containers:
        - name: service
          image: {spec["image"]}
          imagePullPolicy: Never
          ports:
            - name: http
              containerPort: {spec["port"]}
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
            initialDelaySeconds: 1
            periodSeconds: 2
          livenessProbe:
            httpGet:
              path: /livez
              port: http
            initialDelaySeconds: 2
            periodSeconds: 5
          resources:
            requests:
              cpu: {spec["cpuRequest"]}
              memory: {spec["memoryRequest"]}
            limits:
              cpu: {spec["cpuLimit"]}
              memory: {spec["memoryLimit"]}
          securityContext:
            runAsNonRoot: true
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
---
apiVersion: v1
kind: Service
metadata:
  name: {name}
  namespace: {namespace}
  labels:
    platform.atlas.dev/owner: {owner}
    platform.atlas.dev/service: {name}
spec:{node_port}
  selector:
    app.kubernetes.io/name: {name}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {name}-traffic
  namespace: {namespace}
  labels:
    platform.atlas.dev/owner: {owner}
    platform.atlas.dev/service: {name}
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: {name}
  policyTypes: ["Ingress", "Egress"]
  ingress:
{ingress}
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
    - to:
        - podSelector: {{}}
{pdb}"""


def catalog_record(request: dict[str, Any]) -> dict[str, Any]:
    metadata = request["metadata"]
    return {
        "apiVersion": "platform.atlas.dev/v1alpha1",
        "kind": "CatalogEntry",
        "metadata": {
            "name": metadata["name"],
            "namespace": metadata["namespace"],
            "owner": metadata["owner"],
        },
        "spec": {
            "lifecycle": "experimental",
            "system": "atlas-local-platform",
            "source": "git-desired-state",
            "runbook": f"docs/runbooks/{metadata['name']}.md",
            "slo": "99.0% successful readiness probes in the bounded lab window",
        },
    }


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
    except BaseException:
        Path(temporary).unlink(missing_ok=True)
        raise


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("check", "generate"))
    parser.add_argument("--request", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--catalog-output", type=Path)
    args = parser.parse_args()
    try:
        request = validate(load_request(args.request))
        if args.command == "check":
            print(
                f"request=valid service={request['metadata']['name']} "
                f"namespace={request['metadata']['namespace']}"
            )
            return 0
        if args.output is None or args.catalog_output is None:
            raise ContractError("generate requires --output and --catalog-output")
        atomic_write(args.output, render(request))
        atomic_write(
            args.catalog_output,
            json.dumps(catalog_record(request), indent=2, sort_keys=True) + "\n",
        )
        print(
            f"generated=pass service={request['metadata']['name']} "
            f"manifest={args.output} catalog={args.catalog_output}"
        )
        return 0
    except ContractError as error:
        print(f"request=rejected reason={error}", file=os.sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
