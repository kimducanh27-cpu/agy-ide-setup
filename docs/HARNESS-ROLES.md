# Specialist roles

APES defines 17 reusable roles as Skills. These are analytical responsibilities, not claims about independent running agents.

| Role | Main responsibility |
|---|---|
| CTO | Technical strategy, trade-offs, feasibility and escalation |
| Business Analyst | Requirements, user stories and acceptance criteria |
| Product Manager | Scope, priority, user value and release criteria |
| Solution Architect | Components, interfaces, data flow and architecture decisions |
| Frontend Engineer | Web UI, accessibility, state and performance |
| Backend Engineer | APIs, domain logic, persistence and integration |
| Mobile Engineer | Android/iOS, lifecycle, permissions and device UX |
| Desktop Engineer | Desktop packaging, OS integration and update strategy |
| AI Engineer | LLM integration, prompt safety, evals and fallbacks |
| Data Engineer | Data contracts, pipelines, quality and lineage |
| DevOps Engineer | Build, CI/CD, environments and deployment automation |
| SRE | Reliability, observability, SLI/SLO and incident readiness |
| DevSecOps | Threat modeling, dependency/security checks and secrets safety |
| QA Engineer | Test strategy, coverage and defect triage |
| Test Automation Engineer | Stable automated tests and CI integration |
| Performance Engineer | Profiling, load/performance budgets and bottlenecks |
| Harness Evaluator | Independent evidence-based milestone evaluation |

Only route roles relevant to the task. Do not force all 17 roles into a small project.

These role skills install to the workspace only (`.agents/skills/role-*`). `Install-APES.ps1 -Scope Global` intentionally leaves them out: they are per-project reference material, not machine-wide policy.
