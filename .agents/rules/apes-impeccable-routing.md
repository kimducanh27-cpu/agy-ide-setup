---
trigger: model_decision
description: "Use when the task involves frontend, website, mobile-screen, component, design-system, interaction or visual-design work, so UI work can route to the optional Impeccable skill."
---

# APES Optional Impeccable Routing

Apply only to frontend, website, mobile-screen, component, design-system, interaction or visual-design tasks.

- Check for the upstream Impeccable skill at workspace .agent/skills/impeccable/SKILL.md first, then the Antigravity global path ~/.gemini/config/skills/impeccable/SKILL.md.
- If installed, the primary agent must read its SKILL.md and follow its command/reference routing. On Windows, use the bundled impeccable.cmd launcher when the skill requests its context command.
- Use Impeccable as the design workflow; use APES apes-ui-ux-reviewer for a separate read-only review.
- Do not treat Impeccable as an APES Custom Agent or native subagent.
- Do not claim Antigravity has an automatic post-edit Impeccable hook. Run an explicit review/audit workflow when appropriate.
- If absent, continue using APES UI/UX Skills and reviewer. Mention the optional integration only when it materially affects the requested work.
- Do not auto-install or download Impeccable unless the user explicitly asks.
- Do not invoke Impeccable for backend-only, data-only or infrastructure-only work.
