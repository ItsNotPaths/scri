## scri entrypoint.
##
## Shell surface:
##   scri init [<dir>] [--template]              scaffold a project (defaults to cwd)
##   scri outline [<dir>]                        list chapters with word counts
##   scri character new <name>                   inject a character md
##   scri timeline  new <YYYY-MM-DD> <summary>   inject a timeline event md
##   scri snippet   new <title>                  inject a snippet md
##   scri world     new <title>                  inject a world note md
##   scri book      new <title>                  inject the next chapter md

import std/[os, strformat, strutils]
import cli/init
import cli/outline
import cli/new

proc usage() =
  stderr.writeLine("usage:")
  stderr.writeLine("  scri init [<dir>] [--template]              scaffold a new project (defaults to cwd)")
  stderr.writeLine("  scri outline [<dir>]                        list chapters with word counts")
  stderr.writeLine("  scri character new <name>                   inject a character md")
  stderr.writeLine("  scri timeline  new <YYYY-MM-DD> <summary>   inject a timeline event md")
  stderr.writeLine("  scri snippet   new <title>                  inject a snippet md")
  stderr.writeLine("  scri world     new <title>                  inject a world note md")
  stderr.writeLine("  scri book      new <title>                  inject the next chapter md")

proc runInit(args: openArray[string]): int =
  var dir = ""
  var useTemplate = false
  for a in args:
    if a == "--template":
      useTemplate = true
    elif a.startsWith("--"):
      stderr.writeLine(&"scri init: unknown flag: {a}")
      return 2
    elif dir.len == 0:
      dir = a
    else:
      stderr.writeLine("scri init: too many positional arguments")
      return 2
  if dir.len == 0:
    dir = "."
  initProject(dir, useTemplate)

proc runOutlineCmd(args: openArray[string]): int =
  var dir = ""
  for a in args:
    if a.startsWith("--"):
      stderr.writeLine(&"scri outline: unknown flag: {a}")
      return 2
    elif dir.len == 0:
      dir = a
    else:
      stderr.writeLine("scri outline: too many positional arguments")
      return 2
  if dir.len == 0:
    dir = "."
  runOutline(dir)

proc runCharacter(args: openArray[string]): int =
  if args.len == 0:
    stderr.writeLine("usage: scri character new <name>")
    return 2
  case args[0]
  of "new":
    if args.len != 2:
      stderr.writeLine("usage: scri character new <name>")
      return 2
    newCharacter(".", args[1])
  else:
    stderr.writeLine(&"scri character: unknown subcommand: {args[0]}")
    2

proc runTimeline(args: openArray[string]): int =
  if args.len == 0:
    stderr.writeLine("usage: scri timeline new <YYYY-MM-DD> <summary>")
    return 2
  case args[0]
  of "new":
    if args.len != 3:
      stderr.writeLine("usage: scri timeline new <YYYY-MM-DD> <summary>")
      return 2
    newTimelineEvent(".", args[1], args[2])
  else:
    stderr.writeLine(&"scri timeline: unknown subcommand: {args[0]}")
    2

proc runSnippet(args: openArray[string]): int =
  if args.len == 0:
    stderr.writeLine("usage: scri snippet new <title>")
    return 2
  case args[0]
  of "new":
    if args.len != 2:
      stderr.writeLine("usage: scri snippet new <title>")
      return 2
    newSnippet(".", args[1])
  else:
    stderr.writeLine(&"scri snippet: unknown subcommand: {args[0]}")
    2

proc runWorld(args: openArray[string]): int =
  if args.len == 0:
    stderr.writeLine("usage: scri world new <title>")
    return 2
  case args[0]
  of "new":
    if args.len != 2:
      stderr.writeLine("usage: scri world new <title>")
      return 2
    newWorld(".", args[1])
  else:
    stderr.writeLine(&"scri world: unknown subcommand: {args[0]}")
    2

proc runBook(args: openArray[string]): int =
  if args.len == 0:
    stderr.writeLine("usage: scri book new <title>")
    return 2
  case args[0]
  of "new":
    if args.len != 2:
      stderr.writeLine("usage: scri book new <title>")
      return 2
    newChapter(".", args[1])
  else:
    stderr.writeLine(&"scri book: unknown subcommand: {args[0]}")
    2

when isMainModule:
  let args = commandLineParams()
  if args.len == 0:
    usage()
    quit(2)

  case args[0]
  of "init":      quit(runInit(args[1..^1]))
  of "outline":   quit(runOutlineCmd(args[1..^1]))
  of "character": quit(runCharacter(args[1..^1]))
  of "timeline":  quit(runTimeline(args[1..^1]))
  of "snippet":   quit(runSnippet(args[1..^1]))
  of "world":     quit(runWorld(args[1..^1]))
  of "book":      quit(runBook(args[1..^1]))
  of "-h", "--help":
    usage()
    quit(0)
  else:
    stderr.writeLine(&"scri: unknown command: {args[0]}")
    usage()
    quit(2)
