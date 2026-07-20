# Learner Profile

Last updated: 2026-07-20

Labels used below:

- **Self-reported**: supplied by the learner; not competency evidence.
- **Observed**: collected through a read-only local check; presence does not prove proficiency or a working runtime.
- **Pending**: requires a learner answer or later verification.

## Known profile

| Field | Value | Evidence status |
|---|---|---|
| Current role | Senior DevOps Engineer | Self-reported |
| Years of experience | 5 | Self-reported |
| Current level | Intermediate | Self-reported; not yet measured |
| Target roles | DevOps, Senior DevOps, SRE, Platform, Cloud/Solutions Architecture, Infrastructure, DevSecOps, AI Platform | Self-reported |
| Target companies | Product companies and startups | Self-reported |
| Job market | Primarily India; also international | Self-reported |
| Deadline | No fixed deadline | Self-reported |
| Study availability | Irregular | Self-reported |
| Cloud sandbox | None | Self-reported |
| Lab delivery policy | Local-first; no online cloud resources | Self-reported |
| Installation policy | Required local lab dependencies may be installed | Self-reported |
| Instruction preference | Beginner-first explanation before assessment, then one focused checkpoint; accelerated pacing without skipping verification or safety | Self-reported |
| Host environment | 64-bit Windows; PowerShell 5.1; 12 logical CPUs; approximately 31.7 GiB RAM | Observed |
| Host storage | Approximately 271 GiB free on `C:` | Observed |
| Linux environment | WSL 2 Ubuntu 24.04.1 LTS; systemd running; cgroup v2 | Observed |
| WSL resource allocation | 2 logical CPUs; 4 GiB RAM; 2 GiB swap | Observed from `.wslconfig` and Ubuntu |
| Linux storage | `ext4` root healthy; approximately 952 GiB reported free; 1% inode use | Observed; host free space is the physical ceiling |
| Docker status | Docker Desktop client/server 29.6.1; Ubuntu integration active; Compose v5.3.0; daemon query succeeded | Observed |
| Native Ubuntu tools | Git 2.43.0, Python 3.12.3, OpenSSL 3.0.13 | Observed |
| Commands resolvable on Windows PATH | Git, Docker, Python, Go, Node.js/npm, Terraform, kubectl, Azure CLI | Observed; availability does not imply Ubuntu-native installation |
| Commands missing from Ubuntu | `jq`, `yq`, `pip3`, Go, native Node.js, Terraform/OpenTofu, kubectl, Helm, kind/minikube, Ansible, `make`, GCC, ShellCheck/Bats, Trivy, Syft, Cosign, Kustomize | Observed; absence is not a competency score |
| Provider-specific cloud target | Deferred; use provider-neutral local simulation first | Self-reported constraint plus program decision |

## Pending profile fields

| Field | Status |
|---|---|
| Preferred session length | Pending |
| Administrator, employer, proxy, network, or reboot restrictions | Pending |
| Programming and scripting depth | Pending |
| Production tools and responsibility depth | Pending |
| Certifications | Pending |
| Defensible existing projects | Pending |
| Strongest and weakest areas | Pending |
| Preferred explanation language | Pending |
| Other cost, accessibility, or operational constraints | Pending |

The normalized machine evidence is in [environment/local-baseline.md](environment/local-baseline.md). The first response batch is recorded in [assessments/initial-assessment.md](assessments/initial-assessment.md). This file will be updated after further evidence is submitted.
