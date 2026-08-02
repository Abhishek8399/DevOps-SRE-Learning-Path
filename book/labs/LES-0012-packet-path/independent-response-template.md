# LES-0012 independent packet-path response

This is a prompt-only worksheet. It contains no diagnosis or model answer.

## Attempt identity

- Date and time:
- Ubuntu or WSL version:
- Effective UID:
- Repository revision:
- Assistance used or accidental source exposure:
- Safety stop conditions confirmed:
- Offline and host-mutation boundary confirmed:
- Scenario command and immutable case selected:
- Prediction recorded before baseline or derived observation:
- Location of external prediction evidence (never inside the guarded lab root):

## Pre-observation calculations

- Source address and prefix:
- Subnet mask:
- Network address:
- Broadcast or reserved-address rule:
- Destination address:
- Destination on-link decision and arithmetic:
- Expected policy rule and table:
- Every expected matching route:
- Predicted winning prefix and why:
- Predicted route type, next hop, and interface:
- Exact neighbor target and why:
- Predicted original tuple:
- Predicted translated tuple:
- Predicted return route and state owner:
- Application response bytes:
- Planned largest TCP segment payload:
- TCP and IP header bytes:
- Predicted segment count:
- Predicted largest emitted inner IP packet (`payload + TCP header + IP header`):
- Underlay link MTU and encapsulation overhead:
- Predicted effective inner IP MTU (`underlay MTU - overhead`):
- Predicted largest encapsulated packet (`inner packet + overhead`):
- Predicted signed headroom (`underlay MTU - encapsulated packet`):
- Predicted operation result:

## Baseline decoding

For each observation, state what it proves and what it does not prove.

- Addresses:
- Routes:
- Next-hop neighbor:
- Forward tuple and translation:
- Return route and reverse state:
- MTU:
- Complete operation:

## Hypotheses written before incident observation

| Rank | Mechanism | Predicted supporting evidence | Predicted rejecting evidence | Safest discriminating observation |
|---:|---|---|---|---|
| 1 |  |  |  |  |
| 2 |  |  |  |  |
| 3 |  |  |  |  |

## Incident evidence

- Address comparison:
- Policy and table:
- All route candidates:
- Longest-prefix decision:
- Route type:
- Next-hop boundary:
- Neighbor observation:
- Forward tuple:
- Translation state:
- Return route:
- Reverse state:
- Small-size probe:
- Large-size probe:
- Application bytes versus segment bytes:
- Header arithmetic:
- Largest emitted inner IP packet:
- Effective-inner-MTU arithmetic:
- Largest encapsulated packet:
- Signed MTU headroom:
- Modeled user result:

## Boundary conclusion

- Last boundary with healthy input and output:
- First boundary with healthy input and abnormal output:
- Evidence that locates it:
- Hypothesis rejected by route evidence:
- Hypothesis rejected by neighbor evidence:
- Hypothesis rejected by return/state evidence:
- Hypothesis rejected by size evidence:
- What remains unknown:

## Recovery and verification

- Supported recovery command:
- Recovery fields decoded:
- Same operation replayed:
- Forward result:
- Return result:
- Translation and reverse-state result:
- Application response bytes preserved:
- Recovered segmentation strategy and segment count:
- Recovered largest inner IP packet arithmetic:
- Recovered encapsulated packet arithmetic:
- Recovered signed headroom:
- MTU result and why it is mathematically consistent:
- User operation result:
- Why restoration is not final causal proof:

## Cleanup proof

- Cleanup result:
- Following check result:
- Registered state absent:
- Any refusal preserved:
- Why no recursive deletion or manual descriptor repair was used:

## Production transfer

- Target environment:
- Namespace and interface owners:
- Route-policy owners:
- Neighbor domain:
- Stateful translation or firewall owner:
- Forward and return observability:
- MTU and encapsulation calculation:
- Capacity signals:
- Security boundaries:
- Change authority and approval:
- Bounded remediation:
- Abort condition:
- Rollback:
- Real user-operation verification:
- Residual uncertainty:
