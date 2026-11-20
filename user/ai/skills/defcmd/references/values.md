# Value parsing and `FromArg`

Every parameter is parsed by the `FromArg` trait. The type is shown in help as `<type>` and its
default is shown via `Display`.

```rust
pub trait FromArg: Sized {
    fn from_arg(arg: &OsStr) -> Result<Self, ArgError>;
    fn possible_values() -> &'static [&'static str] { &[] }
    fn type_name() -> String { default_type_name::<Self>() }
    fn display_arg(&self) -> Option<String> { None }
}
```

## Built-in types

`FromArg` is provided for: `String`, `OsString`, integers, floats, `bool`, `char`, `PathBuf`,
`Duration`, and the `std::net` addresses (`IpAddr`, `Ipv4Addr`, `Ipv6Addr`, `SocketAddr` and the
`V4`/`V6` variants).

- Integers take `0x`/`0o`/`0b` prefixes and `_` digit separators.
- Durations take a unit, as in nushell (e.g. `1.5min`, `30s`).

## Custom and foreign types

- `#[derive(FromArg)]` — fieldless enums. Help shows the possible values as `<fast|careful>`.
- `#[parse(from_str)]` — any type implementing `std::str::FromStr` with a `Display` error.
- `#[parse(path::to::fn)]` — a custom parser function `fn (&OsStr) -> Result<T, E>` where
  `E: Display`. Its result's error becomes an `ArgError`; `possible_values` is empty ("any").
- A manual `impl FromArg` — full control. Return `Err(ArgError::new("..."))` for an invalid value;
  the value goes to stderr and exits 2.

```rust
use defcmd::{ArgError, FromArg, command};
use std::ffi::OsStr;

#[derive(Debug, FromArg)]
enum Mode { Fast, Careful }

struct Percent(u8);

impl FromArg for Percent {
    fn from_arg(arg: &OsStr) -> Result<Self, ArgError> {
        let n: u8 = arg.to_str()
            .ok_or_else(|| ArgError::new("not valid UTF-8"))?
            .strip_suffix('%').unwrap_or(arg.to_str().unwrap())
            .parse().map_err(ArgError::new)?;
        if !(0..=100).contains(&n) { return Err(ArgError::new("must be between 0 and 100")); }
        Ok(Percent(n))
    }
}

/// Fetch a URL.
#[command]
fn main(
    /// What to fetch.
    url: String,
    /// Give up after this long.
    #[flag]
    #[default(std::time::Duration::from_secs(30))]
    timeout: std::time::Duration,
    /// How hard to try.
    #[flag]
    #[default(Mode::Fast)]
    mode: Mode,
    /// How much of the response to cache.
    #[flag]
    cache: Option<Percent>,
) {
    println!("fetch {url} timeout={timeout:?} mode={mode:?} cache={cache:?}");
}
```

```text
$ fetch https://example.com --timeout 1.5min --mode careful --cache 50%
fetch https://example.com timeout=900000000ns mode=Careful cache=Some(Percent(50))
$ fetch https://example.com --mode slow
Error: invalid value 'slow' for '--mode': expected one of: fast, careful
```

## Help rendering

- `type_name()` renders the parameter as `<type>`: `<duration>`, `<fast|careful>` for an enum,
  `<percent>` for a custom type. The default renders the Rust type path lower-cased, or `value`
  for tuples/slices/references.
- A default value shows via `display_arg()` (i.e. `Display`) when present.
- `possible_values()` lists the accepted spellings in help and in the "expected one of" error.
