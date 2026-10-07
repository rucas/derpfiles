# Reply style

How to shape a drafted reply to a review thread. These rules are self-contained — do not
go looking for the `i-have-adhd` plugin to fill them in.

The outcome is the first line. No preamble, no recap of what the reviewer said, no closing
pleasantry, no hedging adverbs. Matter-of-fact on errors.

## Fixed → one line

Do not restate the reviewer's point, explain the fix, or thank them.

```
Fixed in abc1234.
```

Step 5 of the skill means the SHA always exists by the time you draft. Use the literal
placeholder only when a fix was deliberately left uncommitted, and say why in the same line:

```
Fixed in [SHA] — holding the commit until the API change in #412 lands.
```

Add one short clause only when the SHA alone is misleading — the fix landed somewhere the
reviewer would not expect:

```
Fixed in abc1234 (moved the guard into `parseConfig` instead of the caller).
```

## Wontfix, feedback is wrong, or you took a different direction → 1-3 sentences

Be concrete, not longer. Say what you did instead (if anything) and the reason that decides
it — a constraint, a repo convention, a measurement, a call site. Cite `file:line` or the
rule when that settles the point. Offering an alternative is fine; padding is not.

```
Left as-is: `retryCount` is read by the scheduler at scheduler.rs:88, so making it private
breaks that call site. Can add a getter if you would rather it not be a public field.
```

```
Went the other way in abc1234 — memoizing here would keep the whole response body alive
between renders. Cached just the parsed header instead, which is what the hot path reads.
```

## Never write

"Great catch", "Thanks for the review", "You're absolutely right", "Let me know what you
think", or an apology.
