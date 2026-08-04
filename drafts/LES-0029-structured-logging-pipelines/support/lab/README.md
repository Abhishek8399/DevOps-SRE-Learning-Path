# LES-0029 bounded structured-logging pipeline lab

This lab makes record shape, multiline framing, parser drift, queue conservation, duplicate delivery, sensitive-field detection, timestamp skew, and one incident path inspectable on Ubuntu without downloads.

It is deliberately **not** systemd-journald, syslog, an OpenTelemetry SDK or Collector, Fluent Bit, Logstash, Elasticsearch, Kibana, Splunk, a provider service, a benchmark, or production evidence. Its Python code implements only the declared deterministic cases.

## Environment card

| Field | Contract |
|---|---|
| OS | Ubuntu 24.04 LTS; WSL 2 Ubuntu 24.04 supported |
| Privilege | normal user; UID 0 is refused |
| Network | none |
| Required commands | Bash, Python 3, `id`, `mktemp`, `mv`, `cp`, `rm`, `readlink`, `stat`, `find`, `wc`; verifier additionally uses `grep`, `touch`, and `ln` |
| CPU/RAM/disk | one short Python process; less than 5 MiB owned state |
| Ports/processes | no listening ports and no persistent child process |
| State | exact `/tmp/reliability-atlas-les0029-<UID>` directory |
| Abort | wrong owner/type/path, symlink, unexpected child, invalid manifest/fixture, root caller, failed assertion |
| Cost | no cloud and no paid resource |

## Architecture

```text
checked-in scenario.json
        |
        v
lab.sh --guarded copy--> exact UID-owned /tmp state
        |                           |
        +---- run case ------------+
                    |
                    v
       deterministic Python model
                    |
                    v
          bounded result-<case>.json
```

The wrapper owns lifecycle and path safety. The model owns fixture validation and calculations. Result files are evidence only for the exact deterministic input.

## Commands

```bash
# [READ-ONLY]
bash lab.sh doctor

# [MUTATING / BOUNDED]
bash lab.sh setup

# [READ-ONLY]
bash lab.sh status

# [MUTATING / BOUNDED]
bash lab.sh run baseline
bash lab.sh run multiline
bash lab.sh run parser-drift
bash lab.sh run backpressure
bash lab.sh run duplicate-delivery
bash lab.sh run privacy
bash lab.sh run clock-skew
bash lab.sh run incident

# [MUTATING / BOUNDED]
bash verify.sh

# [MUTATING / BOUNDED]
bash lab.sh cleanup
```

`verify.sh` checks shell and Python syntax, all eight deterministic cases, expected counts, unexpected-child refusal, symlink-child refusal, cleanup, and final absence. Its exit handler removes only the two exact adversarial entries it created, attempts validated cleanup after failure, and reports cleanup failure instead of swallowing it.

## Expected evidence

- Parser drift: six input records, four accepted, two rejected.
- Multiline: five physical lines become two logical events under the declared timestamp-prefix rule.
- Backpressure: 40 produced = 25 consumed + 10 queued + 5 dropped; loss fraction 12.5 percent.
- Duplicate delivery: six deliveries contain four unique event IDs and two duplicate deliveries.
- Privacy: four sensitive-field occurrences are detected and redacted in the model output; raw values are never returned.
- Clock skew: maximum positive observation delay is 75 seconds and one source timestamp is later than its observed timestamp.

These results do not prove a real parser, transport, queue, index, query, retention policy, redaction engine, or vendor backend.

## Troubleshooting

- `root-not-required`: leave the root shell and run as a normal Ubuntu user.
- `missing-tool`: stop. This lab never installs packages.
- `unexpected_child` or `unsafe_child_type`: preserve the refused state and inspect the named entry. Do not recursively delete an ambiguous path.
- `manifest_invalid` or `sentinel_invalid`: the wrapper cannot prove ownership. Preserve evidence and do not bypass the guard.
- failed count assertion: inspect the first failing case and checked-in scenario. Do not change an expected count merely to make the verifier green.

## Cleanup and proof

Cleanup validates the exact parent and basename, resolved path, numeric owner, sentinel, manifest, scenario, allowed child names, file types, ownership, and size before removing the exact state directory. It proves that path absent afterward.

The verifier covers only declared lab state. It says nothing about unrelated `/tmp` content or system cleanliness.
