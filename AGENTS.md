# Agent Toolkit Guide

A collection of reusable skills and rules for AI agents (Claude Code and similar). Everything must
be self-contained and generic — reusable in any project — so avoid project-specific logic or
assumptions. Rules are opt-in: a skill must work correctly with no rules installed, so never fix
or extend a skill by adding a rule it depends on.

`docs/core-philosophy.md` holds the project's five pillars and their litmus test; read it before
creating or redesigning a skill, or when brainstorming toolkit direction.

Frame rules and skills as agent- and model-agnostic: describe what they do, not tied to a specific
agent (e.g. "for Claude Code") or model. Install instructions may still name agent-specific paths
(e.g. `~/.claude/skills/`) — that's the install mechanism, not the content's framing.

New skills ship at version `0.1` as a trial; bump to `1.0` only after a successful real-world run.

In Markdown, wrap prose lines at the `max_line_length` in `.editorconfig`. Never break code (fenced
blocks or inline backtick spans — a command stays on one line even past the limit), tables, URLs,
links, or YAML frontmatter values to satisfy it.

When changing skills, rules, manifests, install behavior, or repository conventions, update the
docs in the same change — `README.md`, `AGENTS.md`, `docs/`, and any affected artifact
documentation — so a fresh agent session understands the current behavior without prior
conversation context. Keep `README.md` lean: catalogs and quick-install commands only; detailed
guides belong in `docs/`.

## Multi-agent quirks

Skills with `disable-model-invocation: true` also need `type: flow`, or Kimi Code hides them even
from manual invocation.

Never put a `:` in a skill description — `: ` in the unquoted value breaks strict YAML parsers
(e.g. Copilot's); avoid the character entirely instead of quoting.
