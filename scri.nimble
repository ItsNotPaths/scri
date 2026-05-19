version     = "0.1.0"
author      = "paths"
description = "scri"
license     = "GPL-3.0-only"
srcDir      = "src"
bin         = @["scri"]

requires "nim >= 2.0.0"

task test, "Run unit tests":
  exec "nim c -r --hints:off tests/test_init.nim"
  exec "nim c -r --hints:off tests/test_outline.nim"
  exec "nim c -r --hints:off tests/test_new.nim"
