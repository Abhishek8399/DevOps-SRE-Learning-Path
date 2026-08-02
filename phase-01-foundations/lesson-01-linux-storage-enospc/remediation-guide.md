# Guided Inode-Exhaustion Remediation

Last validated: 2026-07-31

Use this guide only with the disposable `devops-sre-p1-enospc` lab container. The commands and deletion policy below do not authorize deletion on a real VM, host, volume, or production container.

## The decision you are making

Zero free inodes tells you why file creation fails. It does not tell you which files are safe to delete.

Keep these as two separate decisions:

```text
Diagnosis                              Remediation
---------                              -----------
Which resource is exhausted?           Who created the objects?
Which filesystem owns the path?        Are they still needed?
What operation failed?                 Is deletion approved?

df/findmnt can prove the left side.     Ownership and retention policy
                                        must prove the right side.
```

Memory rule:

> The largest directory is a place to investigate, not automatic permission to delete it.

## Current lab architecture

```text
Docker Desktop
└── devops-sre-p1-enospc
    ├── image: devops-sre-training/enospc-lab:2
    ├── user: 65534:65534 (unprivileged)
    ├── network: none
    ├── root filesystem: read-only
    └── tmpfs mounted at /var
        └── /var/lib/api/uploads
            ├── .retained-data                  KEEP
            └── .runtime/cache/objects
                └── 00000000.part ...           DISPOSABLE IN THIS LAB
```

The lab policy is explicit:

- `/var/lib/api/uploads/.runtime/cache/objects/*.part` files are synthetic disposable cache fragments.
- `/var/lib/api/uploads/.retained-data` represents retained application data and must not be deleted.
- No other path is approved for deletion.

In production, obtain the equivalent rule from the application owner, retention policy, runbook, or incident commander. A filename containing `cache` is not sufficient evidence by itself.

## Step 1 — enter the running lab

From the lesson directory:

```bash
# [MUTATING — EPHEMERAL EXEC SESSION]
bash lab.sh shell
```

Expected prompt: an unprivileged shell inside the container.

## Step 2 — confirm identity and failure state

```bash
# [READ-ONLY]
id
df -hT /var/lib/api/uploads
df -i /var/lib/api/uploads
```

Expected important evidence:

```text
uid=65534(nobody) gid=65534(nobody)
block use approximately 48%
inode use 100%, zero available
filesystem mounted on /var
```

Stop if the user is root, the image is not version 2, or the target filesystem differs from `/var`. Recreate the lab instead of adapting the deletion command to an unexpected environment.

## Step 3 — locate the file population

First count the affected upload tree:

```bash
# [READ-ONLY]
find /var/lib/api/uploads -xdev -type f | wc -l
```

Then test the candidate population against the exact policy:

```bash
# [READ-ONLY]
find /var/lib/api/uploads/.runtime/cache/objects \
  -xdev -maxdepth 1 -type f -name '*.part' | wc -l
```

Preview only a few matching paths:

```bash
# [READ-ONLY]
find /var/lib/api/uploads/.runtime/cache/objects \
  -xdev -maxdepth 1 -type f -name '*.part' | head -n 5
```

Expected fixture evidence is 500 files in the upload tree, of which 499 are policy-approved `.part` fragments.

Why every filter matters:

- Exact directory limits the target.
- `-xdev` prevents crossing onto another filesystem.
- `-maxdepth 1` prevents unexpected recursion.
- `-type f` excludes directories and links.
- `-name '*.part'` applies the approved filename policy.
- Quoting `*.part` prevents the shell from expanding it before `find` evaluates it.

## Step 4 — predict before changing state

Before deletion, say this prediction in your own words:

> Removing the 499 approved fragments should free approximately 499 inodes, preserve `.retained-data`, and allow creation of the failed temporary file.

Abort if:

- the candidate count is not 499;
- `.retained-data` appears in the candidate list;
- the directory, filesystem, image, or user differs from the expected lab state;
- any command would target a parent path such as `/var` or `/var/lib`.

## Step 5 — remove only the approved lab fragments

```bash
# [DESTRUCTIVE — DISPOSABLE LAB FILES ONLY]
find /var/lib/api/uploads/.runtime/cache/objects \
  -xdev -maxdepth 1 -type f -name '*.part' -delete
```

This is deliberately not `rm -rf`. The selection and deletion happen using the same exact filters, avoiding a mismatch between preview and execution.

## Step 6 — verify system recovery

```bash
# [READ-ONLY]
find /var/lib/api/uploads/.runtime/cache/objects \
  -xdev -maxdepth 1 -type f -name '*.part' | wc -l

df -i /var/lib/api/uploads

test -f /var/lib/api/uploads/.retained-data \
  && echo 'retained_data_present=true'
```

Expected evidence:

- matching `.part` count: `0`;
- inode use: approximately `3%`;
- approximately `498` inodes available;
- `retained_data_present=true`.

## Step 7 — verify the failed operation

The lab does not run a real API, so file creation is its bounded end-to-end check:

```bash
# [MUTATING — DISPOSABLE LAB TEST FILE]
touch /var/lib/api/uploads/7f9c.tmp

# [READ-ONLY]
test -f /var/lib/api/uploads/7f9c.tmp \
  && echo 'upload_path_write_recovered=true'

# [DESTRUCTIVE — EXACT LAB TEST FILE ONLY]
rm -f /var/lib/api/uploads/7f9c.tmp
```

In production, replace `touch` with the real user operation: upload a controlled test object through the API and verify application error rate, latency, and logs.

## What the real production response adds

```text
Preserve evidence
      ↓
Stop or throttle the producer if impact is continuing
      ↓
Identify the high-file-count directory
      ↓
Confirm owner, purpose, age, retention, and backup
      ↓
Get approval for the exact population
      ↓
Delete, archive, or move it to a different filesystem
      ↓
Verify inode headroom and the real user operation
      ↓
Fix retention/producer behavior and add inode alerts
```

Useful Ubuntu investigation command:

```bash
# [READ-ONLY — POTENTIALLY EXPENSIVE]
sudo du --inodes -x -d 1 /var | sort -n
```

Start with the narrowest credible directory. Recursive inode scans can add significant I/O load to a filesystem already under pressure.

Important consequences:

- Deleting one large file usually frees one inode.
- Deleting many approved small files frees many inodes.
- Truncating a file frees blocks but keeps its inode.
- Moving files within the same filesystem does not free inodes.
- Moving files to a different filesystem can free source inodes after the source entries are removed, but needs destination capacity, authorization, and recovery planning.
- If deleted files remain open, resources may remain allocated until the owning process closes them.

## Rollback and reset

Deleted cache fragments cannot be individually restored. That is why production deletion requires retention and recovery evidence.

The entire lab is disposable and can be regenerated:

```bash
# [DESTRUCTIVE — EPHEMERAL LAB CONTAINER ONLY]
bash lab.sh cleanup

# [MUTATING — LOCAL LAB]
bash lab.sh setup
```

## Completion evidence

Submit:

1. Candidate count before deletion.
2. Your prediction.
3. Candidate count after deletion.
4. `df -i` after deletion.
5. Retained-data verification.
6. Upload-path write verification.
7. One sentence explaining why finding the inode-heavy directory did not itself authorize deletion.
