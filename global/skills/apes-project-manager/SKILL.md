---
name: apes-project-manager
description: "Understand project goals, create the canonical Project Brief and Master Plan, decompose work into an auditable task graph, and prepare human-approved execution plans. Use for multi-step projects, substantial features, project bootstrap, or when the user asks for a plan."
---

# APES Project Manager — Planning Intelligence

## Mission

Turn a user's goal into a clear, feasible, evidence-oriented project plan. This skill is the planning authority for project intent, scope, milestones, task decomposition, ownership, dependencies and acceptance criteria.

**Master Plan first; FlowPlan visualization second.** FlowPlan is an optional, human-friendly observation board. It is never the only copy of the plan and never the source of truth for architecture, scope or verified execution.

## Source-of-truth model

1. **Project Brief** — canonical record of what the user wants, why, for whom, constraints and non-goals.
2. **Master Plan** — canonical approved strategy: architecture, milestones, deliverables, dependencies, owners, acceptance criteria, risks and approval state.
3. **Task Graph** — machine-readable dependency model linked to the Master Plan.
4. **Execution Evidence** — actual changed files, Git diff, runtime results, test output and independent review results.
5. **FlowPlan** — simplified visual projection for the user. It may be rebuilt from the canonical files.

If FlowPlan disagrees with the canonical plan, reconcile the board from the canonical files. If the Master Plan claims work is complete but execution evidence does not support it, evidence wins for execution status and the plan must be corrected.

## When to use

Use for:
- Full project bootstrap.
- Multi-step features with meaningful dependencies.
- Architecture or implementation planning.
- Projects where the user requests visible progress tracking.
- Substantial research that needs a deliverable/task plan.

Do not create a project plan or FlowPlan board for a trivial question, tiny edit or one-step task unless the user asks.

## Required companion skills and files

Read the workspace instructions and relevant APES Rules first.

For a new or substantial project, read config/workflows.json and the project-management templates. In an APES source repository, the templates are under templates/project-management/. After installation into a project workspace, they are copied to docs/engineering/apes/templates/project-management/.

For FlowPlan display, use:
- .agents/skills/apes-flowplan-projection/SKILL.md

For board operations/execution, use:
- .agents/skills/apes-flowplan-operations/SKILL.md

If a template is unavailable in the active project, report that and use the skill's required structure without pretending the file exists.

## Planning lifecycle

### 1. Intake and workflow selection

- Restate the goal in plain Vietnamese.
- Identify the requested outcome, intended users, constraints and expected level of autonomy.
- Select exactly one existing workflow from config/workflows.json in the APES source repository, or docs/engineering/apes/config/workflows.json after APES installation: quick-fix, standard-feature, full-project, deep-research or hard-review.
- Do not add a new workflow ID for FlowPlan projection. FlowPlan projection is an auxiliary publishing/reconciliation process, not a sixth project workflow.
- Ask one focused question only when a missing fact blocks a safe or meaningful plan. Otherwise state reasonable assumptions and proceed.

### 2. Discover the project

- Inspect the actual workspace root, instructions, repository structure, manifests and relevant documentation.
- Inspect Git branch, status and uncommitted changes before planning changes.
- Identify existing features and reusable components before proposing new ones.
- Identify the actual stack, constraints, test commands and deployment model where relevant.
- Research official documentation and maintained GitHub projects when technical choices materially depend on current facts.
- For important external claims, retain source links and distinguish verified facts from assumptions.
- Never expose secrets in prompts, plans, FlowPlan cards or logs.

Do not overwrite user changes. Do not claim a file, feature, command or test exists until inspected.

### 3. Create the Project Brief

Create or update the project brief at:

docs/engineering/apes/projects/<project-slug>/PROJECT_BRIEF.md

Use the Project Brief template from templates/project-management/ in the APES source repository, or docs/engineering/apes/templates/project-management/ after installation.

The brief must cover:
- Problem and reason for the project.
- Target users and their needs.
- Desired outcomes.
- Functional and non-functional requirements.
- In-scope features and explicit non-goals.
- Constraints and known assumptions.
- Success measures / acceptance outcomes.
- Open questions and decisions needed from the user.

Use accessible Vietnamese. Explain unavoidable technical terms. Label facts, assumptions and unknowns separately.

Do not silently turn suggestions into requirements.

### 4. Build the Master Plan

Create or update:

docs/engineering/apes/projects/<project-slug>/MASTER_PLAN.md

docs/engineering/apes/projects/<project-slug>/task-graph.json

Use MASTER-PLAN-TEMPLATE.md and task-graph.schema.json from the APES source repository's templates/project-management/, or the installed copies under docs/engineering/apes/templates/project-management/.

The Master Plan must include:
- Brief reference and selected workflow.
- Scope and non-goals.
- Architecture direction and important trade-offs, when relevant.
- Milestones defined by outcomes.
- Deliverables per milestone.
- Entry and exit conditions.
- Task ownership and reviewer assignment.
- Real task dependencies and parallel branches.
- Acceptance criteria and verification strategy.
- Test, security, privacy, accessibility and UI/UX checks as applicable.
- Risks, assumptions and unresolved questions.
- Approval state and revision history.

Do not over-engineer a small task. Detail must scale with risk and complexity.

### 5. Adaptive task decomposition

Create tasks around independently understandable deliverables.

A good task:
- Has one clear objective and an observable output.
- Has a bounded scope and identifies relevant files/modules when known.
- Has one accountable owner.
- Has acceptance criteria that can be checked.
- Defines how the output will be verified.
- Lists real prerequisites and explains why they are prerequisites.
- Identifies risks and known unknowns.

Granularity rules:
- Split a task when it combines unrelated outcomes, has multiple owners, hides a major integration boundary, or cannot be verified as a unit.
- Keep a task intact when splitting would produce trivial administrative cards with no independent value.
- Do not create a card for every command or file edit.
- Do not invent deadlines or precise duration estimates without evidence.

Use only existing APES worker IDs when assigning specialists:
- apes-project-analyst
- apes-github-researcher
- apes-solution-architect
- apes-implementation-engineer
- apes-qa-engineer
- apes-ui-ux-reviewer
- apes-security-reviewer
- apes-harness-evaluator

One accountable owner per task. Add a reviewer when independent validation is useful. A skill/role pass is not a live worker. Claim native invocation only when the runtime creates a separate worker and returns its result.

### 6. Dependency graph rules

The Task Graph must be a directed acyclic graph (DAG).

- Give each milestone and task a stable, unique ID.
- Every dependency must point to an existing task ID.
- Explain why each edge is needed.
- Do not create cycles or self-dependencies.
- Use a true root/foundation task where the FlowPlan connector requires one.
- Create parallel branches only when they share completed prerequisites and do not conflict over file ownership.
- Integration tasks depend on the specific branches they integrate.
- QA tasks depend on the deliverables they verify.
- Final audit depends on required verification tasks.

Do not add fake dependencies to satisfy a UI/API constraint. If the current FlowPlan connector requires dependencies after the first card, build a real root task or report that the graph cannot be represented without distorting it.

### 7. Plan Quality Audit

Before publishing, critically audit the plan.

**Completeness**
- Required user outcomes are represented.
- The plan includes relevant implementation, integration and QA work.
- Security/privacy and UI/UX are included when relevant.

**Clarity and size**
- Each task has a clear Vietnamese title and outcome.
- No task is too broad or needlessly fragmented.
- A non-technical user can understand the visible summary.

**Feasibility**
- The stack and approach fit the inspected project.
- Dependencies are available or explicitly identified.
- Estimates, if any, are labeled as estimates.
- Critical path and parallel branches are plausible.

**Verification**
- Acceptance criteria are testable.
- Test commands are discovered, not invented.
- Independent review is planned where useful.
- Missing verification is explicitly marked NOT_RUN.

**Safety and governance**
- User changes are preserved.
- Destructive, production, spending, permission or real-data actions are gated.
- No implementation begins before required approval.
- No native worker activity is fabricated.

Fix critical planning defects before publishing. If a critical unknown cannot be resolved safely, mark the plan BLOCKED or request a decision.

### 8. FlowPlan handoff

If FlowPlan is connected or the user requested a visual board:

1. Read .agents/skills/apes-flowplan-projection/SKILL.md.
2. Verify the canonical Brief, Master Plan and Task Graph exist and are internally consistent.
3. Run the Plan Quality Audit.
4. Publish a readable draft projection. Cards stay [REVIEW] while user approval is pending.
5. Read back the plan and cards and verify persisted IDs, titles, types and dependencies.
6. Present the Project Brief summary and FlowPlan board to the user.
7. Do not begin implementation until explicit approval is recorded.
8. After approval, set eligible cards to [TODO] through actual FlowPlan operations and read back.

If FlowPlan is unavailable, keep the canonical files and present the plan in chat. Report MCP_DISCONNECTED; do not claim a board was created.

### 9. Approval contract

Approval is explicit and scope-bound.

- A draft board is for observation and review, not permission to implement.
- Require a clear user instruction such as DUYỆT KẾ HOẠCH before execution.
- Record the approval decision, scope/revision, date and approver in APPROVALS.md.
- If the user changes scope, architecture, security posture, spending, production data or permissions, update the plan and obtain approval again.
- Never infer approval from silence, a board being open, or a card being visible.

### 10. Output contract

Always report in Vietnamese:
- Project understanding and selected workflow.
- Brief path and current status.
- Master Plan path and revision.
- Milestones and meaningful task count.
- Critical path and parallel branches.
- Owner/reviewer assignments.
- Plan audit findings.
- FlowPlan state: connected/disconnected, plan ID and readback result.
- Assumptions, unresolved questions and risks.
- Approval required.
- Work not performed.

Distinguish:
- PLANNED: exists in the canonical plan.
- PUBLISHED: successfully written to FlowPlan and read back.
- ASSIGNED: an owner is named in the plan.
- INVOKED: a native worker session was actually created.
- DOING: execution has actually started and there is evidence.
- PASS: acceptance criteria have been verified with evidence.

Never present a planned or published task as active execution.
