# Project Bootstrap flow

## Stage 0 — Inventory

Determine workspace root, git state, project files, runtime/framework, current tests, existing customizations and environment. Avoid loading huge trees; inspect targeted files.

## Stage 1 — Requirements

Write user goals, target users, user journeys, constraints, must-have / out-of-scope scope and testable acceptance criteria. Mark assumptions and unknowns.

## Stage 2 — Research

Prefer official vendor docs. Search GitHub for maintained references; compare maintenance, releases, issues, security posture, license, platform compatibility and fit. Record dates and links. Popularity is not proof of quality.

## Stage 3 — Architecture

Propose a simple architecture and 1–3 viable stack options when trade-offs matter. Record decision rationale in ADRs. Include data flows, trust boundaries, failure modes, privacy, cost and rollback/recovery.

## Stage 4 — Quality plan

Select checks appropriate to the actual stack: formatting, lint, type checks, unit/integration/e2e, accessibility, performance, security and build. Every check must have an actual command or be marked NOT_CONFIGURED.

## Stage 5 — Approval

Populate `06-approval.md`, summarize decisions in Vietnamese and wait for a clear approval in chat. Do not edit source code or implement features before approval.

## Stage 6 — Delivery

Execute one milestone at a time. Run actual checks, collect logs, request independent review, evaluate against acceptance criteria, remediate at most three times and update memory.
