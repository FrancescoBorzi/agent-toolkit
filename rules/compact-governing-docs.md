---
name: compact-governing-docs
description: Run the matching compaction skill before writing or editing any governing doc or a doc it references.
---

Before writing or editing a governing doc (`AGENTS.md`/`CLAUDE.md`, `rules/*.md`, `SKILL.md`,
convention docs) or any doc it references (directly or indirectly), run the matching compaction
skill up front, not as a later cleanup, so each rule stays as compact as possible: a `SKILL.md`
through `/compact-skill-creator`; any other doc through `/compact-docs-writer`.

One invocation covers the whole authoring cycle it opens — draft, feedback revisions, apply —
however many turns it spans. A separate edit later in the session needs a fresh invocation; one
left in context from an earlier cycle doesn't count.
