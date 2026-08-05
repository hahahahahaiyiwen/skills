# Review Guidance

Use this guidance to convert concrete PR comments into reusable review principles.

## Core review posture

- Review for correctness, safety, operability, and maintainability before style.
- Prefer comments that explain the risk and desired invariant, not only the local code change.
- Distinguish transient failures from deterministic data, configuration, and deployment problems.
- Require changes to fail before side effects when a prerequisite cannot be validated.

## Safety and side-effect boundaries

- Validate all required inputs at the boundary of helper methods and service operations.
- Resolve external coordinates, feature gates, and deployment prerequisites before mutating state or deleting resources.
- Avoid flows that can leave a resource partially cleaned up when later validation fails.
- If a later operation depends on metadata integrity, check that integrity before earlier destructive work.

## Exception and retry semantics

- Use dedicated exception types only when they carry actionable semantics for callers.
- Do not label deterministic data/configuration failures as retryable unless another cycle can realistically fix them.
- Catch typed exceptions narrowly and document the operational meaning: skip for safety, alert/remediate, or retry.
- Error messages should identify the missing or inconsistent prerequisite clearly enough for operators to fix it.

## Configuration and rollout gates

- Treat feature flags and deployment settings as part of runtime correctness.
- Check mismatches early, such as resource metadata requiring a feature while the agent configuration disables it.
- Preserve compatibility during rollout skew by skipping unsafe work and surfacing clear diagnostics.
- Verify all newly introduced deployment values have defaults, substitutions, or documented release requirements.

## Data integrity and ownership

- Ensure helper logic derives resource coordinates from authoritative metadata.
- Do not rely on debug-only assertions for runtime data validation.
- Validate assumptions that can be violated by old data, partial backfills, or manual repair.
- Prefer explicit validation over allowing invalid values to reach infrastructure clients.

## Review comment shape

Good review comments should include:

1. The violated invariant or risk.
2. Why the current behavior is unsafe or misleading.
3. The preferred behavior or design direction.
4. Whether the issue is blocking or non-blocking.

Example:

> This should be validated before cleanup deletes primitives or DNS records. If regional DNS metadata cannot be resolved, retrying the next cycle will not fix corrupted metadata or deployment mismatch, and the current flow can leave the store partially cleaned up. Please fail fast for this store, log an actionable error, and only proceed once DNS coordinates are known to be safe.

