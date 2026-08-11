# Git internals and recovery: make history explainable

Git is a content-addressed database with refs. Commits point to trees and parents; branches and tags are movable or annotated names. Understanding that model turns “lost work” into a recoverable investigation.

```text
working tree -> index -> commit -> tree/blob/parent objects
                              ^
                         branch/tag refs
```

## Inspect before changing

Use `git status`, `git diff`, `git diff --cached`, and `git log --graph --decorate` to distinguish working, staged, and committed state. Read the exact paths and authorship before reset, rebase, revert, or deletion. A clean tree does not prove the desired commit is on the remote.

## Merge, rebase, revert

Merge preserves divergent history with a new parent relationship. Rebase rewrites commit IDs and should be coordinated before sharing. Revert adds a new inverse commit and is usually safer for a published branch. None of these undo external side effects, generated artifacts, or leaked secrets.

## Recovery and secret response

Reflogs can locate recently moved refs locally; unreachable objects may still exist until garbage collection. Preserve a copy before cleanup. If a secret enters history, remove exposure and rotate/revoke the credential; rewriting history alone does not invalidate a leaked value in clones, logs, caches, or artifacts.

## Safe local exercise

Create a temporary repository, make two commits, branch, merge, and intentionally move a branch ref. Use the reflog to recover the commit and verify object identity. Practice a revert on a local branch and inspect the graph. Delete only the temporary directory.

## Triage sequence

1. Record repository path, branch, remote, current commit, status, and uncommitted files.
2. Inspect refs, reflog, graph, and object IDs before mutation.
3. Choose revert, restore, cherry-pick, or coordinated rebase based on publication and collaboration.
4. Preserve a bundle or copy before risky history work.
5. Verify local and remote parity, tests, generated artifacts, and secret rotation where relevant.

## Interview defense

**Question:** “A developer force-pushed and work disappeared. What do you do?”

**Strong answer:** “Freeze further rewrites, capture refs and remote state, inspect reflogs and other clones, recover the commit into a new branch, and coordinate the least disruptive restoration. I verify commits, tests, and release artifacts before changing the shared branch.”

**Question:** “Is deleting a secret from Git history enough?”

**Strong answer:** “No. Treat the value as compromised, revoke or rotate it immediately, assess exposure in clones/logs/artifacts, then rewrite history and add prevention. History cleanup is containment hygiene, not credential invalidation.”

## Teach-back checkpoint

Explain objects, refs, index, merge, rebase, and revert. Then describe the safest response when a published commit contains a credential.
