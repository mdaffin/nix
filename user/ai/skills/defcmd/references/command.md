# Commands and the `#[command]` macro

A command is a plain Rust function marked `#[command]`. The macro turns the function's
signature into the command's parameter and flag definitions, and registers the function.

```rust
use defcmd::command;

/// Print a greeting.
#[command]
fn main(
    /// Who to greet.
    name: String,
    /// Print in upper case.
    #[flag]
    shout: bool,
) {
    let msg = format!("Hello, {name}!");
    println!("{}", if shout { msg.to_uppercase() } else { msg });
}
```

## How commands register

- `fn main` is the root command and Rust's entry point.
- Every other `#[command]` function is a subcommand named after itself; a path in `#[command("...")]`
  nests it deeper (`#[command("remote add")]` becomes `remote add`).
- Each function registers itself through a link-time inventory registry, so there is no list of
  subcommands and no `parent` field to manage. Discovery is a link-time registry, so testing runs
  under `cargo test`.
- Because the tree is built from name prefixes, a missing middle node (a name that no function
  defines) becomes a help-only group rather than an error.

## The doc comments are the help text

The doc comment on a command is its help text. The doc comment on each parameter (or flag)
describes it, and appears on that line of the help output. Keep these short and imperative.

## Naming

- `snake_case` function and parameter names derive the help text but not the flag spellings; flags
  derive `--long-name` from their own name.
- `#[command(alias = rm)]` adds an alternate name for the same subcommand.

## Body expectations

A command body just runs. It returns `()` / `ExitCode` / `Result` (see `returns.md`); it must not
call `std::process::exit`, and it should parse and validate through the signature rather than from
`std::env::args` itself.

## Clippy

The crate allows `too_many_arguments`, `doc_overindented_list_items` and `doc_lazy_continuation`
because a command's signature legitimately has many parameters and the examples are verbatim
documentation.
