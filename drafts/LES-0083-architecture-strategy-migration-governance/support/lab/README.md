# LES-0083 guarded architecture-strategy and migration lab

This offline lab reviews a fictional payments-modernization strategy. It performs no discovery, provider, network, infrastructure, migration, vendor or production call. Its portfolio, capacity, transfer, cost and score values are teaching inputs—not inventory, benchmark, quote, forecast, business case or authorization.

Run as a normal Ubuntu 24.04 user:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh roadmap
bash lab.sh inventory
bash lab.sh capacity
bash lab.sh transfer
bash lab.sh economics
bash lab.sh vendor
bash lab.sh evaluate current-state-asserted-without-evidence
bash lab.sh evaluate vendor-exit-plan-unbound
bash lab.sh evaluate cutover-window-does-not-close
bash verify.sh
```

The model contains one defensible synthetic baseline and one isolated failure for each of 70 ordered review gates. Its five calculations expose portfolio evidence confidence, three-year failure-aware capacity, bulk transfer and cutover closure, horizon economics and break-even, and vendor scoring after hard-veto constraints.

The vendor scores tie at 3.95, but the managed suite is infeasible because its exit plan is absent. A score cannot average away a hard constraint. The three-year fictional migration also costs USD 150,000 more than remaining in place and breaks even after the 36-month decision horizon; non-financial outcomes need explicit evidence rather than invented savings.

The guard refuses root, cloud credentials, Docker/Kubernetes authority, migration/runtime endpoints and vendor tokens. It creates one UID-scoped directory, accepts only its sentinel and two copied fixtures, refuses unknown artifacts and proves exact cleanup.

Independent practice requires a reviewer-owned sanitized portfolio with hidden evidence-quality, dependency, contract and cutover changes. Never place employer inventory, contracts, architecture, pricing, credentials, endpoints, customer data or supplier-confidential information in this repository.
