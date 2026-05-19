## Project scaffolding for `scri init`.
##
## Pure I/O. Returns a process exit code so the caller can `quit` directly.

import std/[os, strformat]

const
  charactersStub = """---
name: Example Character
role: protagonist
---
# Example Character

Notes go here.
"""

  timelineStub = """---
date: 2025-01-01
summary: Example event
---
# Example event

Details go here.
"""

  bookStub = """---
chapter: 1
title: Example Chapter
status: draft
---
# Example Chapter

Prose goes here.
"""

  snippetsStub = """---
title: Example snippet
tags: []
---
# Example snippet

Reusable bit.
"""

proc isEffectivelyEmpty(dir: string): bool =
  for _, _ in walkDir(dir):
    return false
  true

proc firstEntry(dir: string): string =
  for _, path in walkDir(dir):
    return extractFilename(path)
  ""

proc isGitAware(dir: string): bool =
  dirExists(dir / ".git") or fileExists(dir / ".gitignore")

proc writeIfMissing(path, content: string) =
  if not fileExists(path):
    writeFile(path, content)

proc initProject*(dir: string, useTemplate: bool): int =
  ## Scaffolds the scri project layout at `dir`.
  ## Returns 0 on success, non-zero on refusal.
  let existed = dirExists(dir)
  if existed and not isEffectivelyEmpty(dir) and not isGitAware(dir):
    stderr.writeLine(&"scri init: refusing to init non-empty directory: {dir}")
    stderr.writeLine(&"(found e.g. '{firstEntry(dir)}'; target must be missing, empty, or contain .git/ or .gitignore)")
    return 1

  createDir(dir)
  for sub in ["characters", "timeline", "book", "snippets"]:
    createDir(dir / sub)

  if useTemplate:
    writeIfMissing(dir / "characters" / "example.md", charactersStub)
    writeIfMissing(dir / "timeline" / "2025-01-01-example.md", timelineStub)
    writeIfMissing(dir / "book" / "01-example.md", bookStub)
    writeIfMissing(dir / "snippets" / "example.md", snippetsStub)

  echo &"scri: initialized project at {dir}"
  return 0
