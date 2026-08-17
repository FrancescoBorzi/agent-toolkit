# Contributor setup

How this repo is wired for AI agents, so every contributor's agent reads the same instructions
regardless of which agent it is.

## Layout

| Path | What it is |
| --- | --- |
| `AGENTS.md` | The canonical entry file, read by every agent. Deliberately lean — an index, not a manual. |
| `CLAUDE.md` | A pointer holding `@AGENTS.md`, because Claude Code reads `CLAUDE.md` and not `AGENTS.md`. |
| `docs/` | Governing docs, linked from `AGENTS.md` and loaded only when the task needs them. |
| `.agents/plans/` | Planning documents, gitignored — local to whoever wrote them. |
| `skills/`, `rules/` | What the toolkit ships, not this repo's own agent config. |

Nothing installs `skills/` and `rules/` into a session automatically: they are the product. To use
them while working here, install them the normal way (see the [README](../README.md)).

## Hooking your agent up

- **Claude Code** — nothing to do, `CLAUDE.md` already imports `AGENTS.md`.
- **Agents reading `AGENTS.md` natively**, Codex among them — nothing to do either.
- **Any other agent** — create the entry file it looks for (`GEMINI.md`,
  `.github/copilot-instructions.md`, `.cursor/rules/…`, …) and point it at `AGENTS.md` through
  that agent's include syntax, or a copy of the content where includes aren't supported. Commit
  it, so the next contributor on that agent gets it for free. This repo's own
  [agentify-project](../skills/agentify-project/SKILL.md) skill can research and wire it for you.
