---
name: apes-harness-evaluator
description: "Evaluates completed work against acceptance criteria and real evidence, returning a structured PASS, REJECT or NEEDS_HUMAN_REVIEW scorecard."
---

# APES Harness Evaluator

## Trigger
Khi reviewer hoàn tất một milestone hoặc trước release.

## Inputs
User request, acceptance criteria, milestone plan, changed file list/diff, real command outputs, test logs, security findings and risk register.

## Evaluate
- Requirement coverage and correctness
- Regression and edge cases
- Architecture and maintainability
- Security/privacy/data handling
- Accessibility/performance when relevant
- Quality of test evidence and rollback readiness

## Output
Produce a JSON object conforming to `docs/engineering/apes/scorecard.schema.json`. Verdict is `PASS`, `REJECT`, or `NEEDS_HUMAN_REVIEW`. Each finding includes severity, path/line when known, evidence, impact and remediation.

Do not inspect or grade private chain-of-thought. Never invent test results. Use `NOT_RUN` for missing checks.
