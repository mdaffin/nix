# Subcommands and global flags

## Subcommands

`fn main` is the root command and Rust's entry point. Every other `#[command]` function is a
subcommand named after it; a path in `#[command("...")]` nests it deeper.

```rust
use defcmd::command;

/// Add an item.
#[command]
fn add(
    /// What needs doing.
    title: String,
    /// 1 (low) to 3 (high).
    #[flag(-p)]
    #[default(1)]
    priority: u8,
) {
    println!("add {title:?} priority={priority}");
}

/// Add a remote list.
#[command("remote add")]
fn remote_add(
    /// Name of the remote.
    name: String,
    /// Where it lives.
    url: String,
) {
    println!("remote add {name} {url}");
}
```

- Each function registers itself, so there is no list of subcommands and no `parent` field.
- The tree is built from name prefixes, so a middle node that no function defines becomes a
  help-only group rather than an error.
- `#[command(alias = rm)]` adds another name for the same subcommand. The subcommand word is the
  first positional after the command's own flags; if it matches both a subcommand and a positional,
  the subcommand wins — use `--` to pass it as a value.

`--help` lists every descendant, flattened and sorted:

```text
Subcommands:
  todo add - Add an item.
  todo remote add - Add a remote list.
```

## Global flags

A flag of the root marked `#[flag(global)]` is accepted by every command, before or after the
subcommand word.

- A command that wants its value repeats the flag, with the same names and type. `check()` reports
  a repeat that does not match the root's.
- A command that does not repeat it still accepts the flag, and its help lists it.
- A root flag that is **not** marked global cannot come before a subcommand word: the root's body
  does not run then, so a value there is a usage error.

```rust
use defcmd::command;

/// Deploy services.
#[command]
fn main(
    /// Environment to target.
    #[flag(global, -e)]
    #[default("staging")]
    env: String,
) {
    println!("deploy env={env}");
}

/// Roll a service out.
#[command]
fn push(
    /// The service to roll out.
    service: String,
    /// Environment to target.
    #[flag(global, -e)]
    #[default("staging")]
    env: String,
) {
    println!("push {service} to {env}");
}
```

```text
$ deploy --env prod push api
push api to prod
$ deploy push api --env prod
push api to prod
```
