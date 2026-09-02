# LES-0004 request-path observation

This read-only Ubuntu 24.04 walkthrough inspects the local namespace, `localhost` resolution, loopback route, resolver configuration, and listening TCP sockets. It makes no external request and changes nothing.

```bash
bash lab.sh check
bash lab.sh observe
bash lab.sh cleanup
```

Run as a normal user. Keep output local unless interface addresses, routes, and search domains have been reviewed for sharing.
