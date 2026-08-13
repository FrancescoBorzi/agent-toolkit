---
name: agentify-project
description: Make a project ready for AI agentic engineering by converging it toward a canonical agent-neutral structure — a lean AGENTS.md index with progressive disclosure, shared skills and gitignore hygiene. Re-runnable, and doubles as an audit.
disable-model-invocation: true
type: flow
license: MIT
metadata:
  version: "0.1"
---

# Agentify project

Converge a project — greenfield or half-way-there — toward the canonical agent-neutral structure
specified in [references/target-structure.md](references/target-structure.md) (read it before the
audit), so a team of developers using different agents shares one lean, progressively disclosed
setup. Re-running converges further and reports drift.

Invocation: `/agentify-project [audit] [path]`

- `audit` — run step 1 only, print the findings and what a full run would change, modify nothing;
  the periodic drift check.
- `path` — target a subdirectory instead of the repo root (see Monorepos).

## Principles

- **Ask, don't enforce**: prefer asking — all options shown, one recommended — over enforcing a
  choice, except for obvious easy wins (e.g. clear progressive-disclosure moves). Questions
  answerable from the codebase go to the codebase.
- One approval gate per destructive/bulk change; show diffs or proposals before applying; nothing
  happens behind the user's back. Never commit — suggest reviewing the diff and leave committing
  to the user.
- Generic: behavior is driven by [references/agent-matrix.md](references/agent-matrix.md) — read
  it whenever agent detection or an agent's specifics are needed. One documented exception, the
  **Claude carve-out**: a team with no Claude users at all is rare, so Claude wiring (the
  CLAUDE.md pointer, the `.claude/skills/` links, the Claude gitignore entries) is applied
  unconditionally, never detection-gated.

## 1. Audit (read-only)

- Detect each target-structure area's state, and which agents are in use by their traces (matrix).
- Warn — never block — if the git working tree is dirty, so the user can commit first and keep
  the restructure reviewable as an isolated diff.
- Detect nested entry files (monorepo packages).
- Diff duplicated entry files (agents without include syntax) against AGENTS.md; divergence
  becomes a re-sync menu item — the one artifact class guaranteed to drift.
- Detect Claude-only assets (`.claude/commands/`, `.claude/agents/`, `.claude/rules/`): report,
  leave. Flag `.claude/rules/` content as candidate governing-doc material (path-scoped rules are
  a Claude-specific disclosure mechanism); legacy commands may get a one-off note that they could
  become skills — the conversion itself is out of scope.
- Record entry-file line counts: menu annotations now, coarse before-figure for
  `/context-checkup` later.

Done when every target-structure area has a detected state and every agent trace found is
accounted for.

## 2. Menu

Multi-select over the applicable change areas only — entry-file indirection, AGENTS.md slimming
into docs, skills relocation + symlinks, gitignore hygiene, planning dir, onboarding doc, README
pointer — each annotated with audit findings (e.g. "CLAUDE.md, 180 lines, no AGENTS.md →
indirection + slimming"). **"All" is the first and recommended option.** Report already-converged
areas ✓ and omit them from the choices. Every area is independently skippable: a team may
deliberately stay Claude-only (no multi-agent support) — then apply the selected areas within the
Claude-only variant in target-structure.md.

## 3. Execute — live, step by step

Apply each accepted area immediately, behind its approval gate — no migration-plan artifact: the
moves are mostly mechanical, and re-running converges. Suggested order: entry files →
slimming/docs → skills → gitignore → extras.

**Entry files.** Invariant covering every starting state: the content of **all** existing entry
files — any agent's, including a divergent CLAUDE.md + AGENTS.md pair — feeds the slimming
mapping; AGENTS.md ends canonical; every detected entry file ends as a pointer (or duplicated
content, per matrix), CLAUDE.md always included. Common case (CLAUDE.md exists, no AGENTS.md):
rename it to AGENTS.md — git detects the rename — and recreate CLAUDE.md as `@AGENTS.md` plus any
genuinely Claude-specific remainder. AGENTS.md-only and third-party-only repos: same invariant —
create the missing pointer(s), seed AGENTS.md from whatever entry-file content exists. Greenfield
(no entry file of any agent): minimal seed from cheap reconnaissance (README, package manifest /
build files) — one-liner, **verified** build/test/run commands, planning-dir convention — plus
the pointer; deep doc generation is out of scope, the structure grows later via `/self-improve`
and `/memory-doctor`.

**Slimming (mapping-first).** Draft one full mapping: each block → stays / moves to existing doc
X / new doc Y, applying the keep-vs-extract test (target-structure §1); where a block's relevance
is verifiable from the codebase, check the code instead of asking. Present the mapping with
obvious calls pre-decided; walk **only doubtful blocks** as individual questions, each with a
recommendation; one approval gate before any edit. Offer a compaction pass on blocks that stay;
write extracted docs compact from birth — via `compact-docs-writer` when installed, else inline
with its core principle (least text, zero information loss). Each extracted doc gets a plain-link
index entry in AGENTS.md with its "read when…" hook.

**Skills.** Move real dirs, create relative symlinks (committed), per matrix; leave
foreign/personal links untouched and report them.

**Gitignore.** Show the proposed block as a diff; apply on approval.

**Extras.** Planning dir + AGENTS.md convention line; onboarding doc; README pointer.

Done when every selected area is applied or explicitly skipped by the user.

## 4. Verify (mechanical)

Every AGENTS.md reference resolves; symlinks point at real dirs; `git check-ignore` confirms each
ignore entry; CLAUDE.md pointer intact; duplicated entry files match AGENTS.md. Close with a
short converged-state report of what changed.

## 5. Close

Suggest, each only when installed and applicable — skip silently otherwise:

- `/memory-doctor` — when the agent accumulates project memory (e.g. auto memory) — to relocate
  saved lessons into the new docs structure and share them with the team; it no-ops harmlessly on
  empty memory, so no content check is needed.
- `/context-checkup` — measure what now auto-loads, with the audit's entry-file line counts as
  the coarse before-figure.

## Monorepos

Full treatment targets the repo root. Nested entry files are offered only the cheap mechanical
indirection (nested CLAUDE.md → nested AGENTS.md + pointer); defer nested slimming to a re-run
with that subdirectory as the `path` argument.
