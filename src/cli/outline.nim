## `scri outline` — chapter list with title and word count.
##
## Reads `book/*.md` from the project root, sorts by the `NN-` filename
## prefix (falling back to lex order if the prefix is missing), pulls
## `title:` from frontmatter, counts words in the body, and prints a
## fixed-width table with a project total at the end.

import std/[algorithm, os, strformat, strutils, tables]
import frontmatter

type
  ChapterEntry = object
    num: int
    file: string
    title: string
    words: int

proc parseChapterNum(filename: string): int =
  ## Reads the leading `NN-` prefix as an int. Returns -1 when absent.
  let dash = filename.find('-')
  if dash <= 0:
    return -1
  try:
    parseInt(filename[0 ..< dash])
  except ValueError:
    -1

proc collectChapters(bookDir: string): seq[ChapterEntry] =
  if not dirExists(bookDir):
    return @[]
  for kind, path in walkDir(bookDir):
    if kind != pcFile:
      continue
    let name = extractFilename(path)
    if not name.endsWith(".md"):
      continue
    let fm = parse(readFile(path))
    let title =
      if fm.fields.hasKey("title"): fm.fields["title"]
      else: name.changeFileExt("")
    result.add ChapterEntry(
      num: parseChapterNum(name),
      file: name,
      title: title,
      words: countWords(fm.body),
    )
  result.sort do (a, b: ChapterEntry) -> int:
    if a.num != b.num:
      cmp(a.num, b.num)
    else:
      cmp(a.file, b.file)

proc runOutline*(projectDir: string): int =
  let chapters = collectChapters(projectDir / "book")
  if chapters.len == 0:
    echo "scri outline: no chapters found in book/"
    return 0

  var total = 0
  var maxTitle = len("title")
  for c in chapters:
    if c.title.len > maxTitle:
      maxTitle = c.title.len

  echo &"  # | {alignLeft(\"title\", maxTitle)} | words"
  echo &"----+-{\"-\".repeat(maxTitle)}-+------"
  for c in chapters:
    let numStr = if c.num >= 0: align($c.num, 3) else: "  ?"
    echo &"{numStr} | {alignLeft(c.title, maxTitle)} | {c.words}"
    total += c.words
  echo &"----+-{\"-\".repeat(maxTitle)}-+------"
  echo &"      total{\" \".repeat(maxTitle - 4)} | {total}"
  return 0
