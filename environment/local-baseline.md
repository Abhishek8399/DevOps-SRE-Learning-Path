# Local Lab Baseline

Verified: 2026-07-20

This file records normalized, non-sensitive environment evidence. Raw inventory output is intentionally not committed.

## Delivery decision

- Primary lab environment: WSL 2 Ubuntu 24.04.
- Delivery model: local-first.
- Online cloud resources: out of scope.
- Required local dependency installation: authorized, but only when a selected exercise requires it.
- No packages, services, resource limits, or Docker settings were changed during this baseline.

## Verified host and WSL resources

| Item | Observed state | Readiness interpretation |
|---|---|---|
| Windows host | 12 logical CPUs, approximately 31.7 GiB RAM | Sufficient host capacity for the planned local program |
| Host storage | Approximately 271 GiB free on `C:` | Sufficient current headroom; WSL virtual capacity is not treated as physical free space |
| WSL distribution | Ubuntu 24.04.1 LTS on WSL 2 | Approved primary Linux environment |
| WSL allocation | 2 CPUs, 4 GiB RAM, 2 GiB swap | Adequate for Phase 1 Linux work; constrained for later Kubernetes and observability stacks |
| Linux root filesystem | `ext4`; approximately 952 GiB reported free; 1% inode use | Healthy, but underlying host free space is the real storage ceiling |
| Windows mount in WSL | `9p` at `/mnt/c` | Functional; Linux permission, file-watching, and I/O behavior can differ from WSL-native `ext4` |
| Init and controls | `systemd` running; cgroup v2 active | Suitable for service-management and resource-control labs |
| Package state | `dpkg --audit` clean | No locally known partial or broken package installation |
| Learner account | Non-root; member of `sudo` and `docker` groups | Appropriate default privilege boundary; elevation still requires explicit use |

## Verified local tools

| Tool area | Observed state |
|---|---|
| Native Git | Git 2.43.0 |
| Native Python | Python 3.12.3; `pip3` absent |
| TLS tooling | OpenSSL 3.0.13 |
| Docker | Windows Docker CLI 29.6.1 present; Docker Desktop engine stopped; Ubuntu WSL integration disabled |
| Windows-interoperability commands | `npm` and Azure CLI resolve from `/mnt/c`; they are not native Ubuntu installations |
| Missing Phase 1 utilities | `jq`, `yq`, `make`, `gcc`, ShellCheck, and Bats |
| Missing later-phase tools | Go, native Node.js, Terraform/OpenTofu, kubectl, Helm, kind/minikube, Ansible, Trivy, Syft, Cosign, and Kustomize |

Tool absence is not a competency score. Dependencies will be installed only after the diagnostic selects the language and the next practical exercise.

## Readiness and deferred changes

Ready now:

- Linux process, filesystem, permission, service, networking, Git, Bash, and native Python diagnostic work.
- Local exercises that do not require a running container engine.

Deferred:

- Docker labs until Docker Desktop is running and Ubuntu integration is deliberately enabled and verified.
- Local Kubernetes and heavier observability labs until WSL resource allocation is reviewed; changing `.wslconfig` affects all WSL distributions and requires a WSL restart.
- Provider-specific cloud implementation. Cloud concepts will use local simulation, emulation, configuration validation, and architecture reasoning.
- Installation of missing tools until learner evidence establishes the primary scripting language and immediate lab requirement.

## Safety boundary

- Do not use production systems, employer cloud accounts, or real credentials.
- Do not commit raw environment output, secrets, kubeconfigs, Terraform state, or private endpoints.
- GitHub remains the approved remote for versioning this training repository; it is not an authorization to create online cloud infrastructure.
