# Return values and exit codes

A command returns `()`, [`std::process::ExitCode`], or a `Result` of either with an error that is
`Display`. Nothing in a command body is expected to call `std::process::exit`.

| Command returns | Result |
|---|---|
| `()` | exit 0 |
| `ExitCode` | exit with that code, nothing printed |
| `Result<T, E>` | `T` is any of these, `E: Display`; `Err(e)` prints `Error: {e:#}` and exits 1 |

## The three codes defcmd uses

- `0` — success, and `--help`/`--version` (written to stdout).
- `1` — the command returned `Err` (printed to stderr as `Error: {e:#}`).
- `2` — a usage error: a missing/invalid argument (printed to stderr as an `Error:` line and a
  `help:` line).

## Error display

`Err(e)` prints `Error: {e:#}` to stderr and exits 1. Use the `{:#}` form: it shows the whole
error chain of an `anyhow::Error` while leaving plain `Display` types unaffected, so `String`,
`Box<dyn std::error::Error>` and friends all work without glue.

```rust
use defcmd::command;
use std::process::ExitCode;

/// A command that can fail, and one that picks its own code.
#[command]
fn main(
    /// A file to read.
    file: String,
) -> Result<(), String> {
    let _ = std::fs::read_to_string(&file).map_err(|e| e.to_string())?;
    Ok(())
}

/// A command that reports its own exit codes.
#[command]
fn other() -> ExitCode {
    ExitCode::from(3)
}
```

## What commands should not do

Do not call `std::process::exit` inside a command body. Return an `ExitCode` (or
`Result<ExitCode, E>`) instead so the exit behaviour is explicit and testable.
