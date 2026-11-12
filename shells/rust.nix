# `toolchainFile` is the project's rust-toolchain(.toml); without one the latest
# stable is used.
pkgs:
{
  toolchainFile ? null,
}:
let
  toolchain =
    if toolchainFile != null then
      pkgs.rust-bin.fromRustupToolchainFile toolchainFile
    else
      pkgs.rust-bin.stable.latest.default.override {
        extensions = [
          "rust-src"
          "rustfmt"
        ];
      };
in
pkgs.mkShell {
  packages = with pkgs; [
    toolchain
    openssl
    pkg-config
    cargo-deny
    cargo-edit
    cargo-watch
    rust-analyzer
  ];

  env = {
    # Required by rust-analyzer
    RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
  };
}
