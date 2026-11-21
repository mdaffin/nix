---
name: markdown
description: |
  Writing and formatting Markdown documents. Use when creating or editing `.md` files, or any time
  a Markdown file needs to be formatted. Formatting is done with dprint, which is installed and
  configured via a global config that already maps the `markdown` plugin. Covers running dprint,
  the formatting rules it enforces, conventions for tables and code blocks, and keeping edits
  consistent with the surrounding document.
---

# markdown

This project formats Markdown with [dprint](https://dprint.dev) using the `dprint-plugin-markdown`
plugin, run against a **global** config at `~/.config/dprint/dprint.json` (no per-project
`dprint.json`). The plugin enforces table alignment, consistent list and heading spacing, and
single blank-line rules; it is the single source of truth for Markdown style, so prefer letting it
format over hand-aligning anything.

## When to reach for this

Use this skill whenever a task touches a `.md` file: writing a new document, editing prose, fixing
a table, or adding a code block. If a file is expected to be formatted, run dprint before finishing
so the diff is clean and consistent.

## Running dprint

dprint is on PATH in this environment (verified `0.64.3`) and the global config already declares
the `markdown` plugin, so no local config is needed. Format a file:

```console
dprint fmt README.md
```

Check without writing (used in CI-style checks):

```console
dprint check README.md
```

Format the whole directory:

```console
dprint fmt .
```

Notes:

- No local `dprint.json` is written or left behind. If you need a config for something, prefer the
  global one; only add a temporary local config as a last resort and delete it after.
- The global config points at a **local** wasm plugin path in the Nix store
  (`/nix/store/.../plugin.wasm`). If dprint reports the plugin is missing or the path is gone,
  run `dprint install` to (re)resolve it against `~/.config/dprint/dprint.json`, or clear the cache
  with `dprint clear-cache` and try again.
- To preview changes before applying, run `dprint check` first: a non-zero exit with a file name
  means that file would be reformatted.
- To upgrade the plugin to the latest version: `dprint upgrade` (the plugin is newer than the CLI;
  this is cosmetic and not required to format).

## Formatting rules

The plugin's defaults are what you see after `dprint fmt`. The main things it does to Markdown:

- **Tables**: pads cells so column borders align vertically and aligns the separator row (`| --- |`).
  Do not hand-pad table cells; dprint does it.
- **Blank lines**: collapses multiple consecutive blank lines into one, and removes stray blank
  lines before/after fenced code blocks and around headings. Keeps exactly one blank line between
  paragraphs.
- **Lists**: normalizes list item spacing and numbering.
- **Trailing punctuation / emphasis**: leaves these as written; the plugin does not rewrite prose
  or add periods.
- **Fenced code blocks**: preserves contents and language tags verbatim; only surrounding spacing
  is touched.

Run `dprint fmt` rather than guessing which rule applies — it enforces the style authoritatively.

## Conventions

- Keep prose tight and in `sentence case` for headings and body; match the casing that already
  surrounds your edit.
- Use ATX headings (`## Foo`, with a space before the name), not underlined setext headings.
- Prefer fenced code blocks with an explicit language tag (``nushell`,``bash, ```nix) over
  indented code.
- Use inline code (backticks) for paths, commands, and identifiers.
- For reference-heavy topics, mirror the `defcmd` layout: an `SKILL.md` at the skill root plus
  `references/*.md` files that are loaded on demand.

## Workflow

1. Read the target file and its neighbours before editing — Markdown in this repo documents live
   configuration, so wording can reflect actual flake behaviour worth getting right.
2. Make the prose/table/code change, matching surrounding style.
3. Run `dprint fmt` on the file to normalize spacing and table alignment.
4. Review `git diff` to confirm only your intended change (plus formatting) landed.

## Examples

```console
dprint fmt README.md          # format one file
dprint check SKILL.md         # would it be reformatted?
dprint fmt user/ai/skills/    # format an entire tree
```
