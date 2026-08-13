# The use-my-mothertongue rule

A copy-paste rule for developers who don't read English comfortably: your agent talks to you in
your own language, while everything it writes into the project stays in English.

No install script covers it — it needs your language filled in, and it's a personal preference,
not a project one.

## The rule

```markdown
Since I'm not a native English speaker, always talk to me in INSERT_YOUR_LANGUAGE_HERE. When we
discuss an English document or finding, explain it in my language instead of quoting English at
me; short quotes and code may stay as-is.

Everything you write into files or publish stays in English: documents, code, comments, commit
messages, PR and issue text.

Don't over-translate: keep common English technical terms as-is — developers use them in every
language — and refer to project-specific terminology by its original name, at most adding a
translation in parentheses.
```

## Installing it

Replace `INSERT_YOUR_LANGUAGE_HERE` with your language, then:

- **Claude Code** — save it as `~/.claude/rules/use-my-mothertongue.md`.
- **Other agents** — add it as a section of your user-level `AGENTS.md`.

Never install it in a project: in a shared repo it would impose your language on every
collaborator's agent.

You can also paste this whole page to your agent and ask it, in your own language, to install the
rule for you.
