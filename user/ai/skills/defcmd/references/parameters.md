# Parameters and flags

Every parameter is a positional unless it has `#[flag]`. All flags are optional.

| Declaration | Meaning |
|---|---|
| `x: T` | required positional |
| `x: Option<T>` | optional positional |
| `#[default(expr)] x: T` | optional positional with a default |
| `x: Vec<T>` or `#[rest] x: Vec<T>` | variadic positionals, last |
| `#[flag] x: bool` | switch |
| `#[flag] x: Option<T>` | value flag |
| `#[flag] #[default(expr)] x: T` | value flag with a default |
| `#[flag] x: Vec<T>` | repeatable value flag |
| `#[flag] x: Option<bool>` | tri-state switch (also `--no-x`) |
| `#[flag] #[default(true)] x: bool` | negatable switch (also `--no-x`) |
| `#[flag(global)] x: T` | global flag, on the root and repeated on the commands that read it |

## Positionals

- A required positional is a bare `x: T`.
- `x: Option<T>` is optional.
- `#[default(expr)]` on a positional supplies a value when it is omitted.
- A variadic positional is `x: Vec<T>` or `#[rest] x: Vec<T>` and must be the last parameter.

## Flags

- `#[flag] x: bool` is a switch.
- `#[flag] x: Option<T>` is a value flag.
- `#[flag] x: Vec<T>` collects every occurrence (a "repeatable" value flag); otherwise the last
  occurrence wins.
- `#[flag] x: Option<bool>` is a tri-state switch: `--x`, `--no-x`, or absent.
- `#[flag] #[default(true)] x: bool` is a negatable switch: `--x`/`--no-x`, defaulting on.

## Flag naming

`#[flag]` derives `--long-name` from the Rust name. Choose the spellings explicitly:

- `#[flag(-f)]` — short only.
- `#[flag(--jobs)]` — long only (matches the name).
- `#[flag(--jobs, -j)]` — both, spelling both.

## Parsing rules

- Flags and positionals may be mixed in any order.
- A value flag takes `--flag value` or `--flag=value`.
- A short flag takes `-j value`, not `-j8`.
- A repeated flag: the last one wins, unless it is a `Vec`, which collects every occurrence.
- `--` ends flag parsing; everything after it is a positional.

## Defaults

`#[default(expr)]` supplies the value when the parameter is omitted. For a value flag with a
default, the default is shown in help and used as the value when the flag is absent; the value
flag can still be given an explicit `None`/absent to override depending on whether the type is
`Option`. Help shows the default via `Display` (see `values.md`).
