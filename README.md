# scri

Terminal book-writing scaffolder. Markdown files with YAML frontmatter, organized by folder.

## Build

```
nimble build
```

Requires Nim 2.0+.

## Commands

```
scri init [<dir>] [--template]              scaffold a project
scri outline [<dir>]                        chapter list with word counts
scri character new <name>                   inject a character md
scri timeline  new <YYYY-MM-DD> <summary>   inject a timeline event md
scri snippet   new <title>                  inject a snippet md
scri book      new <title>                  inject the next chapter md
```

## Layout

```
my-novel/
├── characters/   # slug.md
├── timeline/     # YYYY-MM-DD-slug.md
├── book/         # NN-slug.md
└── snippets/     # slug.md
```

## License

GPLv3.
