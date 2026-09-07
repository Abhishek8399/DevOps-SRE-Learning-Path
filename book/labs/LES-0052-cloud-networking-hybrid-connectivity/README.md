# LES-0052 local packet-path model

Run `bash lab.sh doctor`, `setup`, `list`, `evaluate CASE`, `status`, and `cleanup` as a normal Ubuntu 24.04 user. The fixture contains only documentation prefixes and booleans. It opens no socket, changes no interface, route, firewall or resolver, and uses no provider account or credential.

`bash verify.sh` checks one reachable baseline, eight first-boundary failures, hostile-state refusal and exact cleanup. A pass is deterministic reasoning evidence only—not cloud, packet, DNS, route, firewall, NAT, VPN, BGP, MTU, cost or production evidence.
