# Guided prerequisite — filesystem space is more than bytes

Status: complete guided instruction at Hint 5; the practical lab remains locked

The learner requested detailed instruction after the first attempt. This note therefore provides a worked diagnostic pattern. The original incident is now coached practice, not independent assessment evidence; a later unfamiliar closed-notes transfer is required.

## 1. Start with the storage subsystem

A program does not write to “the computer” in general. It asks a filesystem to create or extend an object at a pathname.

For a path such as `/srv/example/new-file`, Linux walks the path one component at a time:

~~~text
/ → srv → example → new-file
~~~

A mount can appear at any existing directory during that walk. If `/srv/example` is a mount point, it can be backed by a different filesystem from `/srv`. That is why storage evidence must be collected for the deepest existing directory in the failed path, not merely for a familiar parent directory.

## 2. A filesystem tracks independent resources

Two important resources are:

| Resource | What it represents | What consumes it |
|---|---|---|
| Data blocks | Space used to store file contents and filesystem data | Writing bytes |
| Inodes | Records that describe filesystem objects | Creating files and directories |

An inode normally stores metadata such as object type, ownership, permissions, timestamps, size, and pointers to data. A directory entry connects a filename to an inode.

A newly created empty file contains zero application-data bytes, but it still needs a name in its parent directory and an inode. Therefore, free data blocks alone do not guarantee that a new file can be created.

## 3. Why one percentage is incomplete evidence

A human-readable disk-capacity percentage normally answers a block-capacity question: “How much byte-oriented space is used?” It does not automatically answer:

- whether free inodes remain;
- whether the inspected path and the failing path use the same filesystem;
- whether a caller-specific limit applies; or
- whether capacity changed between the failure and the observation.

Imagine a filesystem with:

- block use: 48%;
- inode use: 100%.

Those values do not conflict. They measure different resources. The filesystem still has room for content, but it has no unused object record for another file.

## 4. What `ENOSPC` means

`ENOSPC` is the Linux error commonly displayed as `No space left on device`. It tells us that the attempted operation could not obtain a required storage allocation at that time.

By itself, it does **not** prove that:

- the entire physical disk is full;
- data blocks are the exhausted resource;
- a parent directory is on the same filesystem as the exact target;
- the latest deployment caused the problem; or
- deleting large files is the correct response.

In production, deleting files or restarting first can remove evidence, affect the wrong filesystem, and make recovery harder.

## 5. Complete read-only diagnostic pattern

The failed file does not exist, so start with its deepest existing parent directory. For the lesson incident, that is `/var/lib/api/uploads`.

The command set differs slightly by environment. The pinned BusyBox 1.36.1 image was checked directly: `findmnt` is absent, while `df` supports `-hT` and `-i`, and `stat` supports `-f -c`.

1. Map that directory to its actual mounted filesystem:

   On a normal Ubuntu host:

   ~~~bash
   findmnt -T /var/lib/api/uploads
   ~~~

   Inside this pinned BusyBox lab, use the available fallback:

   ~~~bash
   df -hT /var/lib/api/uploads
   ~~~

   Read the `Filesystem`, `Type`, and `Mounted on` columns. This identifies the backing mount and also supplies block-capacity evidence. Either approach can show that a nested mount, container layer, or `tmpfs` makes broad evidence for `/var` irrelevant.

2. Inspect block capacity and filesystem type on that same directory:

   ~~~bash
   df -hT /var/lib/api/uploads
   ~~~

   Skip this duplicate command if the BusyBox fallback in step 1 already produced the output.

   This answers the byte-oriented capacity question. It does not report inode availability.

3. Inspect inode capacity on the same directory:

   ~~~bash
   df -i /var/lib/api/uploads
   ~~~

   If inode use is 100% while block use is 48%, inode exhaustion can explain why creation fails despite free block capacity.

4. If the output is unclear, inspect raw filesystem counters:

   ~~~bash
   stat -f -c 'type=%T blocks_available=%a inodes_free=%d' /var/lib/api/uploads
   ~~~

The observations in the incident make inode exhaustion and a different nested filesystem strong hypotheses. They are not proven until these checks are run against the exact directory.

## 6. Safe next move, verification, and prevention

If exact-path evidence confirms zero free inodes:

- preserve the error, timestamp, command output, mount identity, and ownership evidence;
- identify which process or file population consumed the inodes, scoped to the affected filesystem;
- request approval before stopping a producer, changing retention, moving data, or deleting anything;
- define success as restored inode headroom plus a successful end-to-end upload;
- abort if the proposed cleanup target, ownership, retention rule, or affected filesystem is uncertain.

There is no rollback needed for the read-only checks. A later remediation must have its own recovery plan. Prefer a reversible move or archive over deletion when practical, and never use broad cleanup commands such as `docker system prune` for this incident.

Prevention includes monitoring both block and inode usage per important mount, alerting before exhaustion, controlling small-file growth, testing retention, and documenting exact-path triage in the runbook.

## 7. Warehouse analogy

Think of a filesystem as a warehouse:

- shelves are data blocks;
- numbered inventory cards are inodes;
- each stored item needs a card, even if it uses almost no shelf space.

The warehouse may have half its shelves free but no blank cards. It cannot register another item. The analogy is intentionally simplified: real filesystems also have directory entries, metadata, quotas, reserved capacity, and mount layers.

## Guided transfer — stop here

Close this note before answering. Consider a different incident:

~~~text
findmnt -T /opt/app/cache       -> /dev/vdb1 mounted on /opt/app/cache
df -hT /opt                    -> 91% block use
df -hT /opt/app/cache          -> 35% block use
df -i /opt/app/cache           -> 100% inode use
~~~

In two or three sentences, answer one question: which filesystem evidence explains failure to create `/opt/app/cache/new-file`, and why should the operator not delete files from `/opt` yet?

A correct answer verifies immediate coached recall only; it does not raise mastery. Do not run the Lesson 1 lab yet. After this transfer, the lab becomes guided practice, followed later by an unfamiliar closed-notes assessment.
