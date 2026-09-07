# LES-0077 offline OpenStack request-path model

This lab teaches evidence order without calling or creating an OpenStack service or resource. Run it only as a normal Ubuntu user with no OpenStack, cloud, Kubernetes, Docker or remote libvirt authority exported in the shell.

```bash
bash lab.sh doctor
bash lab.sh inventory-tools
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
bash lab.sh evaluate instance-cell-mapping-missing
bash lab.sh evaluate placement-inventory-stale
bash lab.sh evaluate bound-port-no-dataplane
bash lab.sh evaluate guest-up-application-down
bash lab.sh cleanup
bash verify.sh
```

`inventory-tools` reports only local architecture, environment and command presence. It never invokes `openstack`, `curl` or a service endpoint. The presence of an OpenStack client would not prove authentication, endpoint reachability or any control/data-plane service.

Expected verifier result:

```text
verify=pass cases=51 refusal=true cleanup=true service_calls=none
```

The only mutation is a UID-scoped directory under `/tmp` containing a sentinel and copied synthetic fixture. Cleanup removes only those two allowlisted files and refuses an unknown artifact. The lab opens no port, uses no network or credential, creates no load, and performs no API, database, queue, agent, hypervisor, image, network, volume, instance, package, privilege or host action.
