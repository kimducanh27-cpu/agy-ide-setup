# APES 2.0 architecture

## Layers

1. **Global Engineering:** workstation-wide rules and reusable skills.
2. **Project Bootstrap:** requirement discovery, source research, stack choice, architecture and risk analysis.
3. **Role Skills:** 17 specialist lenses, invoked by task relevance.
4. **Execution Harness:** milestone planning, executor/reviewer separation, deterministic checks, evaluator scorecard and capped remediation.
5. **Memory & Evidence:** dated lessons, decision records, test outputs and source links.

## Role-based does not mean 17 live agents

Roles are defined as Antigravity Agent Skills. A role can be applied by the main agent. If native subagents are available, the main agent may delegate narrowly scoped tasks. If not, run the role passes sequentially and disclose that fact.

## Milestone state machine

`DRAFT → READY_FOR_APPROVAL → APPROVED → IN_PROGRESS → REVIEW → PASS → DONE`

Review failures transition to `REVISION_REQUIRED`. Permit at most three automated fix/review cycles for the same issue, then escalate. `NEEDS_HUMAN_REVIEW` is required for unclear requirements, risky data changes, external spending, deployment, permission changes or unresolved security risks.

## Evaluator contract

The evaluator judges artifacts, not private reasoning. Input: request, acceptance criteria, changed files/diff, actual command outputs, test logs and risk register. Output: JSON with verdict, findings, evidence, blockers and next actions.

## Design constraints

- No technology lock-in; choose stack after requirements and research.
- No global config overwrite; namespaced APES artifacts only.
- No destructive setup behavior; backups before replacing APES-owned files.
- No fake test results. Missing checks must be `NOT_RUN`.
- No production deployment or paid-resource creation without explicit user approval.
