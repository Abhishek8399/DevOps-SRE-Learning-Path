# Replication and consensus: keep one truth under partition

Replication creates multiple copies; consensus coordinates which copy may make authoritative decisions. They solve different problems and both must define behavior during delay, loss, and recovery.

```text
client -> leader/authority -> replicated log/state -> followers
              |                    |                  |
          lease/term             quorum             lag/repair
```

## Failure models first

Name whether you tolerate crash-stop, omission, delay, network partition, corruption, or Byzantine behavior. A system that survives a crashed follower may not survive two isolated leaders. Timeouts create uncertainty; they do not prove the other side stopped.

## Quorums and availability

A quorum is enough agreeing members to make a decision under the protocol’s assumptions. Odd cluster sizes often improve fault tolerance because a majority must overlap across decisions. More replicas add read/write and repair cost; “three nodes” is not a guarantee without knowing placement and failure domains.

## Leaders, terms, and fencing

Leader election needs an authority such as a term, lease, epoch, or fencing token. A former leader must be prevented from writing after losing authority. Without fencing, a partition can create split brain and conflicting effects even if each side believes it is healthy.

## Consistency and repair

Choose whether reads may be stale, whether writes require quorum, and how conflicts resolve. Repair needs version/vector information, authoritative ordering, tombstone/retention rules, and user-visible reconciliation. Copying bytes back is not enough if the wrong writer won.

## Safe local exercise

Use three local state files and a deterministic message fixture to model majority acknowledgement. Remove one follower, then partition the model into two groups and prove which side may commit. Restore connectivity, reconcile from the authoritative log, and record the result. Do not run a real cluster or mutate network interfaces.

## Triage sequence

1. Establish membership, terms/epochs, failure domains, lag, and writer authority.
2. Determine whether a quorum exists and whether any old writer remains unfenced.
3. Stop unsafe writes before restoring connectivity or forcing promotion.
4. Preserve logs/indices and reconcile from the authoritative history.
5. Verify reads, writes, invariants, and user journeys after repair.

## Interview defense

**Question:** “Why not let both sides accept writes during a partition?”

**Strong answer:** “Without a conflict protocol and business-safe merge, both sides can violate invariants or create duplicate effects. I preserve a single fenced authority or explicitly choose an eventual model with conflict resolution and reconciliation.”

**Question:** “Does adding replicas always improve availability?”

**Strong answer:** “Only if placement, quorum rules, network, repair, and client behavior support it. More replicas can increase coordination latency, cost, and recovery work; I evaluate failure domains and the read/write contract.”

## Teach-back checkpoint

Draw a three-member replicated service during a one-link partition. State which side may write, what fences the old leader, what readers may observe, and how repair proves invariants after reconnection.
