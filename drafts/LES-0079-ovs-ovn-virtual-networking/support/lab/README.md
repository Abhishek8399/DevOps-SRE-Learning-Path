# LES-0079 guarded OVS/OVN evidence model

This lab teaches evidence order without creating or querying a bridge, database, flow, namespace, interface, tunnel, route, policy or packet. It invokes no discovered OVS, OVN, `ip`, `tc` or packet-capture command.

Run as a normal Ubuntu 24.04 user:

```bash
bash lab.sh doctor
bash lab.sh inventory-tools
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate northd-stalled
bash lab.sh evaluate underlay-mtu-failed
bash lab.sh evaluate reverse-path-failed
bash verify.sh
```

The verifier covers one passing baseline and one isolated failure for each of 57 ordered gates. It also proves exported runtime-authority refusal, unknown-artifact refusal and exact cleanup. Tool discovery reports presence only and makes no runtime call.

Do not point this directory at any OVSDB, OVN database, Unix socket, OpenFlow endpoint, cloud, cluster, container engine, hypervisor or production network. A representative exercise belongs only in the reviewer-owned disposable independent lab.
