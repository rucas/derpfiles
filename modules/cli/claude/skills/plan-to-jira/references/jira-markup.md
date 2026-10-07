# Jira markup quirks

The Jira MCP converts Markdown → Jira wiki markup itself, so the description you send is
Markdown. Its converter is fragile in the specific ways below; each of these has produced
a visibly broken ticket in practice. Conform the description before creating.

## Code blocks

**Keep every fenced code block at column 0 — never indented under a list item.** A
` ``` ` fence nested inside a numbered/bulleted list renders broken: the literal ```` ``` ````
markers survive and every line gets double-spaced. If a step needs a code block, write the
step as a bold label paragraph (e.g. `*1.* Do X:`) followed by a blank line and the
dedented fence — do NOT use a `1.`/`-` list item that contains the fence.

Always put a **language tag** on the fence (` ```bash `, ` ```yaml `, ` ```kotlin `).
Tagged fences convert to `{code:lang}`; the converter may fall back to `{noformat}` for
some languages — both render cleanly, so this is fine.

Keep prose between steps at column 0 too, so it doesn't get absorbed into a list item's
continuation and re-indented.

## Emphasis

**Prefer single-`*` emphasis (`*label*`) over double-`**`.** Empirically `**bold**` is
flaky in this converter — the same description that breaks with `**1.**` step labels
renders cleanly with `*1.*`. Single `*` converts to `_italic_` and is reliable; reserve it
for short labels/emphasis and keep pairs balanced.

**Avoid bare `*` characters — the converter treats matched `*` pairs as emphasis, even
inside fenced code, and the corruption cascades.** It can mangle every code fence in the
description and even store literal `\n` instead of newlines. The usual offenders live in
code blocks: globs like `Foo*.kt` and C-style `/* … */` comments. A single unmatched `*`
(e.g. `PbpClassify*` once) is fine; it's a second `*` later that closes the pair and
breaks everything.

Before creating, scan the description for `*` outside of intentional emphasis markers and
rewrite:

| Offender | Rewrite as |
| --- | --- |
| a glob, `Foo*.kt` | "the Foo… files" |
| a `/* … */` comment | a `//` line comment |
| a `/* … */` placeholder | `...` or `…` |

## Comments inside fences

**Keep fenced code blocks free of trailing inline comments that contain prose
punctuation** — em-dashes `—`, parens, `~`, `*`. A YAML/bash/kotlin comment like
`slots: 20  # placeholder — size to budget (OQ25)` inside a fence can break the fence
conversion: it mangles into `` `` ``→`{{` and swallows the rest of the description,
sometimes storing literal `\n`. Clean comment-free code converts reliably. Move any such
explanatory note to a prose line *after* the closing fence.

## Verify after writing

After create/update the MCP returns the stored wiki markup. **Glance at it** to confirm
fences became `{code:lang}`/`{noformat}` — not literal ```` ``` ```` or `` `` ``→`{{`
garbage. If it's mangled, fix the source markdown and re-update rather than leaving a
broken ticket.
