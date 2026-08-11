# TLS and PKI: prove who is speaking

TLS provides a protected channel; PKI binds a public key to an identity through certificates and trust. Encryption alone does not prove that the endpoint is the intended service.

```text
client -> DNS/address -> TCP -> TLS handshake -> HTTP/application
                         |          |
                     reachability  identity/key/trust/clock
```

## Certificate reasoning

Check the certificate subject alternative name (SAN), validity window, issuer chain, key usage, algorithm, and trust store. The hostname a client verifies must match a SAN; a certificate for the right company or common name is not enough. Clock drift can make a valid certificate appear expired or not-yet-valid.

## Trust and termination

The client trusts a configured root/intermediate set. A reverse proxy may terminate TLS and create a new trust boundary to the backend. Document where encryption ends, which identity is forwarded, whether the backend uses mTLS, and who rotates each key and certificate.

## Rotation and revocation

Rotation needs overlap, automated deployment, reload behavior, monitoring for expiry, and a rollback or previous-certificate path. Revocation is not a substitute for short lifetimes and controlled trust stores; know how clients actually consume revocation information in your environment.

## Safe debugging

Use a disposable or approved endpoint with `openssl s_client -connect host:443 -servername host`, `curl -v`, and certificate inspection. Do not paste private keys, tokens, or full sensitive chains into logs. Compare client trust store, hostname, SNI, negotiated protocol, and clock before changing certificates.

## Safe local exercise

Create a temporary self-signed certificate for `localhost` in a fixture directory, run a local TLS server, inspect the SAN and expiry, and demonstrate the expected trust failure before explicitly supplying the fixture CA. Rotate the fixture certificate, verify the server reload path, then delete the directory. Never install the fixture CA system-wide.

## Triage sequence

1. Identify client, hostname, SNI, destination, termination point, and time.
2. Check TCP reachability separately from TLS handshake and HTTP response.
3. Inspect SAN, chain, trust store, key usage, protocol, cipher, and clock.
4. Compare direct and proxy paths; preserve evidence and avoid disabling verification.
5. Rotate or repair the smallest scoped certificate/trust boundary, then verify the user journey.

## Interview defense

**Question:** “The certificate is valid but clients reject it. What do you check?”

**Strong answer:** “Validity is only one field. I check hostname/SAN and SNI, issuer chain and client trust store, key usage, clock, negotiated protocol, proxy termination, and whether the backend needs mTLS. I preserve verification rather than bypassing it.”

**Question:** “How do you rotate certificates without downtime?”

**Strong answer:** “Use overlapping validity, distribute the new chain and trust before switching, reload gracefully, monitor handshake and user SLIs, retain a bounded rollback path, and remove old trust only after all clients are confirmed.”

## Teach-back checkpoint

Draw the TLS boundaries for a client, proxy, and backend. Name which identity each hop proves, which trust store is used, how rotation is observed, and what evidence distinguishes a trust failure from a routing failure.
