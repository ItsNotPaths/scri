## `scri ... new ...` — template-inject a new markdown file with
## correct filename and seeded frontmatter. Never overwrites.
##
## Filename rules:
##   characters/<slug>.md
##   snippets/<slug>.md
##   timeline/<YYYY-MM-DD>-<slug>.md
##   book/<NN>-<slug>.md   (NN auto-incremented from existing chapters)
##
## Slugs are ASCII-lowercase, non-alnum collapsed to single hyphens,
## leading/trailing hyphens stripped.

import std/[os, strformat, strutils]

proc slugify*(s: string): string =
  ## Lowercase ASCII slug; non-alnum runs become single hyphens.
  var lastWasDash = true
  for c in s:
    let lower = c.toLowerAscii
    if lower.isAlphaAscii or lower.isDigit:
      result.add lower
      lastWasDash = false
    elif not lastWasDash:
      result.add '-'
      lastWasDash = true
  result = result.strip(chars = {'-'})

proc isValidDate(s: string): bool =
  ## Shallow YYYY-MM-DD shape check. Doesn't validate calendar; the
  ## point is filename sortability, not date arithmetic.
  if s.len != 10: return false
  if s[4] != '-' or s[7] != '-': return false
  for i, c in s:
    if i == 4 or i == 7: continue
    if not c.isDigit: return false
  true

proc writeFresh(path, content: string): int =
  if fileExists(path):
    stderr.writeLine(&"scri new: refusing to overwrite: {path}")
    return 1
  let parent = parentDir(path)
  if parent.len > 0 and not dirExists(parent):
    stderr.writeLine(&"scri new: directory missing: {parent}  (run `scri init` first?)")
    return 1
  writeFile(path, content)
  echo &"scri: wrote {path}"
  return 0

proc newCharacter*(projectDir, name: string): int =
  let slug = slugify(name)
  if slug.len == 0:
    stderr.writeLine("scri character new: name produces an empty slug")
    return 2
  let body = &"""---
name: {name}
role: XXX
---
# {name}

Notes go here.
"""
  writeFresh(projectDir / "characters" / (slug & ".md"), body)

proc newTimelineEvent*(projectDir, dateStr, summary: string): int =
  if not isValidDate(dateStr):
    stderr.writeLine(&"scri timeline new: expected date as YYYY-MM-DD, got: {dateStr}")
    return 2
  let slug = slugify(summary)
  if slug.len == 0:
    stderr.writeLine("scri timeline new: summary produces an empty slug")
    return 2
  let body = &"""---
date: {dateStr}
summary: {summary}
---
# {summary}

Details go here.
"""
  writeFresh(projectDir / "timeline" / (dateStr & "-" & slug & ".md"), body)

proc newSnippet*(projectDir, title: string): int =
  let slug = slugify(title)
  if slug.len == 0:
    stderr.writeLine("scri snippet new: title produces an empty slug")
    return 2
  let body = &"""---
title: {title}
tags: []
---
# {title}

"""
  writeFresh(projectDir / "snippets" / (slug & ".md"), body)

proc nextChapterNum*(bookDir: string): int =
  ## One past the highest NN- prefix in bookDir (default 1 if empty).
  result = 1
  if not dirExists(bookDir): return
  for kind, path in walkDir(bookDir):
    if kind != pcFile: continue
    let name = extractFilename(path)
    if not name.endsWith(".md"): continue
    let dash = name.find('-')
    if dash <= 0: continue
    try:
      let n = parseInt(name[0 ..< dash])
      if n + 1 > result:
        result = n + 1
    except ValueError:
      discard

proc padNum(n: int): string =
  if n < 100: align($n, 2, '0') else: $n

proc newChapter*(projectDir, title: string): int =
  let slug = slugify(title)
  if slug.len == 0:
    stderr.writeLine("scri book new: title produces an empty slug")
    return 2
  let n = nextChapterNum(projectDir / "book")
  let body = &"""---
chapter: {n}
title: {title}
status: draft
---
# {title}

"""
  writeFresh(projectDir / "book" / (padNum(n) & "-" & slug & ".md"), body)
