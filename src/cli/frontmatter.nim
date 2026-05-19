## Minimal YAML-frontmatter reader for scri.
##
## scri's frontmatter is a flat set of `key: value` lines, fenced by
## `---` markers at the very top of the file. No nesting, no anchors,
## no flow-style maps. Lists declared inline as `[a, b]` are returned
## as the raw string `[a, b]`; callers that care can split.
##
## Anything resembling a full YAML parser is intentionally out of
## scope — this matches what `scri init --template` writes.

import std/[strutils, tables]

type
  Frontmatter* = object
    fields*: Table[string, string]
    body*: string

proc parse*(text: string): Frontmatter =
  ## Returns frontmatter fields and the body (post-fence content).
  ## If `text` has no leading `---` fence, `fields` is empty and
  ## `body` equals `text`.
  result.fields = initTable[string, string]()
  let lines = text.splitLines
  if lines.len < 2 or lines[0].strip != "---":
    result.body = text
    return

  var i = 1
  while i < lines.len and lines[i].strip != "---":
    let line = lines[i]
    let stripped = line.strip
    if stripped.len > 0 and not stripped.startsWith("#"):
      let colon = line.find(':')
      if colon > 0:
        let key = line[0 ..< colon].strip
        let val = line[colon + 1 .. ^1].strip
        if key.len > 0:
          result.fields[key] = val
    inc i

  if i >= lines.len:
    # Unterminated fence — treat whole input as body, no fields.
    result.fields.clear()
    result.body = text
    return

  # Skip the closing `---` line; rejoin the rest verbatim.
  inc i
  result.body = lines[i .. ^1].join("\n")

proc countWords*(body: string): int =
  ## Whitespace-separated token count. Strips empty splits.
  for token in body.splitWhitespace:
    inc result
