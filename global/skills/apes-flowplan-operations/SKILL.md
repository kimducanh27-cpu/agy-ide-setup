---
name: apes-flowplan-operations
description: "Operate the optional FlowPlan MCP board as a human-friendly projection of the canonical APES Master Plan, including card-by-card execution, evidence-based status updates, feedback and safe recovery. Use when FlowPlan MCP is connected or the user requests a visual project board."
---

# APES FlowPlan Operations

## When to use

Use only when FlowPlan MCP tools are available in this runtime or the user explicitly requests FlowPlan. Do not make FlowPlan mandatory for small questions, simple edits or work that does not benefit from a task board.

Read docs/FLOWPLAN-WINDOWS-INTEGRATION.md and templates/prompts/FLOWPLAN-WORKFLOW-PROMPTS-VI.md in the APES source repository, or their installed copies under docs/engineering/apes/, when the user needs setup or copy-ready prompts.

## Non-negotiable truths

- FlowPlan is a visual task board and feedback surface; it does not edit the workspace, run tests, observe every terminal command or automatically know whether a subagent is running.
- Only report tool operations that actually returned successfully.
- FlowPlan's current card MCP schema has no dedicated status property. Encode status as a title prefix: [TODO], [DOING], [PASS], [BLOCKED], [REVIEW].
- The actual repository, Git diff and test output are the evidence for code completion. A FlowPlan title alone is not evidence.
- Antigravity MCP config uses serverUrl for remote Streamable HTTP. Do not suggest legacy url/httpUrl for this integration.
- The Windows community build is optional. APES must not download, install, auto-start, update or publish the app unless the user explicitly asks and a separate reviewed workflow exists.

## Connection preflight

1. Confirm FlowPlan tools are present in the current Antigravity session.
2. Call list_plans and inspect its actual result.
3. For read-only verification, use get_plan/get_cards/get_all_feedback.
4. If tools are absent or calls fail, report MCP_DISCONNECTED and stop FlowPlan-dependent actions. Do not claim a config file alone proves connectivity.
5. Never invoke destructive tools as a connection test.

## Plan projection and creation

1. Do not use this skill as the strategic planning source. For multi-step planning, first use apes-project-manager to create the canonical Project Brief, Master Plan and task-graph.json.
2. Use apes-flowplan-projection to validate and simplify that canonical plan for a non-technical user.
3. FlowPlan is a visual projection and feedback surface. It is not the only plan store and does not own canonical scope, architecture, milestones or dependencies.
4. Call list_plans before creating a board; reuse a matching plan only after confirming project identity and revision.
5. Create a new plan only when the user requested/approved a visual board or the active workflow explicitly requires one. Retain plan_id and canonical task ID ↔ card_id mappings in FLOWPLAN-MAPPING.json.
6. Publish concise Vietnamese card titles and explanations. Keep deeper technical details in the canonical plan and include only useful references in card descriptions.
7. Use only five valid card types: research, planning, create, edit, test.
8. FlowPlan add_cards may require dependencies on later cards. Make the first card a real root/foundation task. Create parallel branches only from shared genuine prerequisites; connect integration/final-test cards to the branches they truly require. Do not invent dependencies or cycles.
9. Use $0, $1... only to refer to cards added in the same add_cards call.
10. For a plan awaiting user approval, publish cards with [REVIEW]. After explicit approval, use [TODO]. Never start implementation merely because a draft board exists.
11. After create_plan/add_cards, call get_plan/get_cards and verify the persisted plan and graph. If readback fails, report the board as unverified.
12. If FlowPlan disconnects, continue using canonical project files and report MCP_DISCONNECTED. Never lose or replace the Master Plan with board content.

## Card execution loop

Default to one card at a time. Parallelize only when the user approves parallel execution, dependencies are met, native subagents really launch and file ownership does not conflict.

For each card:

1. Read its current title, description, files and dependencies.
2. Confirm all prerequisite cards are [PASS] with evidence.
3. Check get_all_feedback for relevant new user input.
4. Use update_card to set [DOING] and record the work scope.
5. Read back with get_cards; do not edit code until the write is confirmed.
6. Implement only the approved card scope.
7. Inspect Git diff and changed files.
8. Discover real commands from package manifests, project scripts and config. Run suitable lint, typecheck, unit/integration tests, build or UI verification. Record exact command, exit code and meaningful output.
9. Ask the QA/reviewer agent for read-only independent review when useful. Claim independent review only if the runtime launched a separate subagent and it returned. Otherwise label the check self-review.
10. If a check fails, fix within scope and retest. Follow APES's remediation cap: no more than three rounds for the same defect. Then stop as BLOCKED.
11. When all acceptance criteria are supported by evidence, update title to [PASS] and write summary, changed files, tests/results, review, known issues and NOT_RUN items into the description.
12. If unresolved, use [BLOCKED] or [REVIEW] with the reason and evidence.
13. Call get_cards/get_plan to verify the status and evidence were persisted. Do not continue if readback fails.

Only [PASS] cards may satisfy dependencies. If a prerequisite regresses, revisit dependent card eligibility.

## Status convention

- [TODO]: not started.
- [DOING]: active work; set before implementation.
- [PASS]: acceptance criteria passed with evidence; not equivalent to code written.
- [BLOCKED]: dependency, test, scope or environment prevents safe progress.
- [REVIEW]: human decision or verification required.

Do not invent a status field in MCP arguments. update_card supports title/description/files/dependencies/order and other card metadata, not a status parameter.

## Feedback loop

- Question: investigate and answer with answer_feedback.
- Directive: handle only if it is within approved scope; acknowledge after handling.
- Issue: investigate, fix/verify if authorized, then acknowledge.
- Scope, architecture, security, production-data or cost change: stop and obtain human approval.
- Do not acknowledge unresolved feedback just to clear it.

## Recovery

After a new chat or FlowPlan restart:
1. Confirm MCP connection and list_plans.
2. Reuse matching plan; do not create duplicates by default.
3. Read plan/cards/feedback.
4. Compare [DOING] and [PASS] labels with actual files, Git diff and test evidence.
5. Downgrade unverifiable cards to [REVIEW] or [BLOCKED]; never trust stale labels blindly.
6. Resume only the next dependency-eligible card.

## Destructive operations

Treat remove_card and clear_plan as destructive. Never call them without explicit user authorization. Prefer adding a correction or updating a card rather than deleting a plan item. Do not delete a plan as part of normal completion.
