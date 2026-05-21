Save an observation from this conversation to the ledger.

`$ARGUMENTS` is a short description of the observation to capture. If empty, review the conversation and ask the user what observation they want to save.

## Steps

1. **Synthesize the observation** from the conversation context and the user's description:
   - A descriptive title (sentence case, concise)
   - A slug (lowercase, hyphenated, max 50 chars, alphanumeric and hyphens only)
   - A detailed explanation (2-5 sentences capturing the key insight)
   - Optional context about how/where this was discovered
   - Relevant tags formatted as inline code (e.g., `#git`, `#deployment`, `#python`)

2. **Detect the source project**: Run `git remote get-url origin 2>/dev/null` and extract the `org/repo` name. If not in a git repo, use the current directory basename.

3. **Get today's date**: Run `date +%Y-%m-%d` for the full date, extract year and zero-padded month.

4. **Create the notes directory**: Run `mkdir -p ~/Code/ledger/notes`.

5. **Generate the filename**: `<YYYY-MM-DD>-<slug>.md`. If the file already exists, append `-2`, `-3`, etc.

6. **Write the markdown note** to `~/Code/ledger/notes/<filename>`:

   Formatting rules:
   - Hard-wrap all prose lines at 120 characters max
   - Use tables for comparisons, configurations, mappings, or key-value data
   - Use code blocks for commands, snippets, or output
   - Use bullet lists over paragraphs when listing discrete points
   - Prefer structured formatting (tables, lists, code blocks) over prose wherever it improves scannability
   - Never truncate or shorten identifiers (ARIs, UUIDs, ticket keys, hashes, version strings, etc.) — preserve them exactly as they appear

   ```markdown
   # <Title>

   | Field  | Value                        |
   |--------|------------------------------|
   | Date   | <YYYY-MM-DD>                 |
   | Source | <org/repo or directory name> |
   | Tags   | `#tag1` `#tag2`              |

   ## Observation

   <Detailed explanation — use tables, code blocks, and lists where appropriate>

   ## Context

   <How/where this was discovered — omit this section entirely if not meaningful>
   ```

7. **Add the backlink to today's NOTES section**:
   - Read `~/Code/ledger/<year>/<month>.norg`
   - Find today's date heading (e.g., `** WEDNESDAY 2026-05-20`)
   - Find the `*** NOTES` line under that day
   - If the NOTES section already has `****` entries, insert after the last one (before the next `**` section boundary)
   - If the NOTES section is empty, insert immediately after the `*** NOTES` line
   - Write a 1-2 sentence excerpt of the key finding, followed by a link to the full note. Format:
     ```
     **** <short excerpt of the observation>
          {/ ../notes/<filename>}[full note]
     ```
     The excerpt is plain text at the `****` heading level. The link goes on the next line, indented with 5 spaces (continuation line). Use `{/ path}` (norg file link syntax for non-norg files). The path must be relative to the norg file's location (e.g., `2026/05.norg`), so use `../notes/` to go up from the year directory. No trailing space before `}`. Example:
     ```
     **** you can figure out what version is in prod by checking git tags like `service-v0.479.0`
          {/ ../notes/2026-05-20-git-tags-show-deployed-version.md}[full note]
     ```
   - If the norg file doesn't exist, tell the user to generate it with `ldgr gen month <M> <Y>` and stop
   - If today's date heading isn't found, report the error and stop

8. **Confirm** to the user:
   - The path to the markdown note that was created
   - The backlink that was added and which norg file it was inserted into
