# Azure DevOps-first Orchestration Model

This workspace uses a **Azure DevOps-first orchestration model**.

## Model overview

- Azure DevOps (Board + WorkItem + Comment) is the shared cross-session context.
- Operational behavior, governance, and lifecycle standards are loaded by `orchestrator-boot`.

### Startup entrypoint

- At session start, check `$env:ADO_ORCH_ORG_URL` and `$env:ADO_ORCH_PROJECT`; run **`orchestrator-boot`** only if either value is missing or empty.
- If both values are already set for the current session, do not run `orchestrator-boot` again.
- `orchestrator-boot` is the only startup skill referenced by this file.
- `orchestrator-boot` is responsible for loading:
  - governance and development standards (`references/CORE.md`, `references/DEV-FLOW.md`)
  - project mapping (`references/RESOURCE-MAP.yml`)
  - operational skill routing for the task lifecycle

Natural language can express intent, but runtime execution should follow the skill routing loaded by `orchestrator-boot`.

# Interface-first Development Approach

Core rule: **every external dependency and cross-module collaboration must be expressed as an interface owned by the module boundary**.

- Business/domain behavior depends on interfaces, not concrete infrastructure.
- Interfaces are owned by the module where the behavior belongs.
- Shared model/contract projects are for data contracts, not a global interface bucket.

## Design Conventions

1. **Constructor injection only** for interface dependencies.
2. **Single responsibility per interface**; avoid broad “god interfaces”.
3. **Async-first signatures** (`Task` / `Task<T>`) for IO or orchestration boundaries.
4. **Domain types at boundaries** (use `DecisionProposal`, `AuditEvent`, etc., not raw dictionaries).
5. **No direct infrastructure calls** inside domain/agent logic; call interface ports only.

## Interface Driven Testing Strategy
- For new behavior and bug fixes, write or update tests first, then implement code to pass them.
- Keep changes incremental: red -> green -> refactor.
- Prefer unit tests for decision logic and policy checks; add integration tests for end-to-end runtime flows.
- Do not merge implementation changes without corresponding test coverage for the changed behavior.

### Test at behavior seams

Test each module by substituting interface collaborators:
- Real class under test
- Fake or mock implementations for dependencies
- Assert outcome + interactions

### Preferred test doubles

1. **Simple fake** (in-memory deterministic behavior) for most tests.
2. **Spy** when you need to verify call arguments/count.
3. **Mock framework** only for high-interaction tests; keep assertions focused on behavior.

### What every unit test should verify

- **Happy path**: expected result is produced.
- **Policy/safety block path**: rejected proposal does not roll out.
- **Failure path**: dependency failures are surfaced or handled explicitly.
- **Boundary path**: min/max bounds, confidence floors, cooldown behavior.

# Documentation-first implementation
- Before major implementation work, update design/issue documentation with goal, scope, and acceptance criteria.
- Keep docs aligned with code as behavior evolves (contracts, safety rules, rollout behavior, APIs).
- For each completed issue, record key decisions and constraints in docs or issue comments so later agents can continue without ambiguity.

## Evolving-spec module documentation (mandatory)
- Treat module-level `README.md` files as part of the implementation, not optional docs.
- If an agent changes behavior, interfaces, invariants, dependencies, or key decisions in a module, the same change must update that module's `README.md`.
- If a new module boundary is created (project-level or lower-level), create a `README.md` at that module root and document:
  - purpose and boundary ownership,
  - key design considerations/invariants,
  - concise implementation decisions,
  - maintenance expectations for future changes.
- Do not close a code change that modifies a module boundary without corresponding module README updates.

## No backward compatibility
- Do not add backward compatibility for runtime behavior or interfaces unless explicitly required by a design decision.
- Remove obsolete paths and interfaces when they are no longer needed; do not maintain them indefinitely.
- Do not add compatibility layers, fallbacks, or shims for old behavior unless explicitly required by a design decision.

# OS Context 

## PowerShell quoting guardrail

- In PowerShell, the backtick (`` ` ``) is the escape character.
- Do not put markdown backticks inside double-quoted strings unless you intentionally escape them.
- For CLI arguments that include markdown/code formatting, prefer single-quoted strings (for example: `--body 'Start development, branch: `<branch>`'`) or assign a single-quoted here-string to a variable and pass that variable.

# Product Context