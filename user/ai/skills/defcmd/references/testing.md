# Testing with `try_run` / `try_run_with` / `check`

Command discovery is a link-time registry, so tests run under `cargo test`. Every command other
than the empty root `main` stays an ordinary function, so it can also be called directly.

- `try_run(argv)` runs the registered commands from an explicit argument list and returns the exit
  code.
- `try_run_with(argv, out, err)` does the same and also writes defcmd's own output (help, version
  and error messages) to your buffers.
- `check()` validates the whole command tree once; put it in one `#[test]`.

```rust
use defcmd::{command, try_run_with};
use std::path::PathBuf;
use std::process::ExitCode;

#[command]
fn main() {}

#[command]
fn tool(file: PathBuf) -> Result<(), String> {
    let _ = std::fs::read_to_string(&file).map_err(|e| e.to_string())?;
    Ok(())
}

#[test]
fn tree_is_valid() {
    defcmd::check();
}

#[test]
fn a_missing_argument_is_reported() {
    let (mut out, mut err) = (Vec::new(), Vec::new());
    let code = try_run_with(["tool", "missing.conf"], &mut out, &mut err);
    assert_eq!(code, ExitCode::from(2));
    // A missing required argument is a usage error, written to stderr.
    let message = String::from_utf8(err).unwrap();
    assert!(message.starts_with("Error: missing required argument 'file'"));
}
```

## Direct calls

Because non-root commands stay ordinary functions, you can call them by name in a test too:

```rust
#[command]
fn tool(file: PathBuf) -> Result<(), String> {
    let _ = std::fs::read_to_string(&file).map_err(|e| e.to_string())?;
    Ok(())
}

#[test]
fn called_directly() {
    assert!(tool(PathBuf::from("does-not-exist")).is_err());
}
```

## Exit codes in assertions

Remember the codes defcmd emits: `0` success and `--help`/`--version`, `1` when the command
returned `Err`, `2` for a usage error. `ExitCode::from(n)` takes the numeric code (e.g.
`ExitCode::from(2)`).
