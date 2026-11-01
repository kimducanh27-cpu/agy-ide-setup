---
trigger: model_decision
description: "Use when work spans multiple steps and needs an APES workflow selection, a generated prompt, or recorded run-state checkpoints with evidence."
---

For multi-step work, select one APES workflow from config/workflows.json and follow its stages/gates. Use the Prompt Builder and explicit Run State ledger when the scripts are available. Do not advance a stage without inspected evidence; require explicit user approval at APPROVAL. The ledger is not automatic telemetry. Preserve FlowPlan and Impeccable as optional independent integrations. Never claim native subagents ran without runtime launch and returned output.
