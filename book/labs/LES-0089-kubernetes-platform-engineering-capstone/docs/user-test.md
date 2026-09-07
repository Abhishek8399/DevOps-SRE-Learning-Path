# Developer usability test

This is a test protocol, not evidence that a real developer has completed it. An independent participant and observer are required before claiming usability.

## Scenario

“Create a private service for team-b, deploy two replicas, find its owner and runbook, then explain why an unsafe deployment is rejected. Finally, update the service image and recover from a failed rollout.”

The participant receives only the project README and a fresh clone. The observer must not give commands, field names or answers. The session stops on unsafe host paths, credentials, broad cleanup, a non-loopback target or unexplained privilege escalation.

## Measures

- Time to find prerequisites and safety boundary.
- Time to validate the first request.
- Number and quality of contract errors.
- Time from valid request to ready user operation.
- Whether the participant can name request, RBAC, admission, quota, scheduling and readiness boundaries.
- Whether the rejection message leads to a safe correction without operator intervention.
- Whether the participant edits the request rather than generated YAML.
- Whether rollback restores the user operation and the participant verifies it.
- Cleanup success and any artifacts left behind.
- Confidence rating before and after, plus one confusing term in the participant’s own words.

## Scoring

A successful task requires correct tenant/owner metadata, versioned image, generated-state review, committed revision, user probe, policy explanation, bounded rollback and exact cleanup. Time alone is not success. A fast participant who bypasses policy or cannot explain the failure owner has not demonstrated the platform’s intended mental model.

Record quotations only with consent and remove personal or company-sensitive information. Convert repeated friction into a backlog item with observed evidence, not a guessed feature. Do not publish “developer experience improved” until multiple representative users complete an unchanged scenario and the before/after measure is defined.
