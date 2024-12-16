{ config, ... }:
# This section apply settings to the system configuration only available on macOS
# see <https://daiderd.com/nix-darwin/manual/index.html#sec-options> for more options
{
  system = {
    stateVersion = 5;
  };

  programs.zsh.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [ 
    virtualenv
    alacritty
    wezterm
    awscli2
    bottom
    carapace
    coreutils
    diffr
    delta
    rustup
    cargo-outdated
    eza
    fd
    fzf
    gh
    git
    tailwindcss
    templ
    gnupg
    darwin.apple_sdk.frameworks.Security
    libgit2
    openssl
    openssl.dev
    perl
    kotlin-language-server
    darwin.apple_sdk.frameworks.AppKit
    libiconv
    pkg-config
    go
    gopls
    oras
    trivy
    google-cloud-sdk
    grml-zsh-config
    golangci-lint
    helix
    jfrog-cli
    jq
    yq
    just
    shellcheck
    k9s
    kdash
    kubernetes-helm
    kustomize
    nushell
    pinentry_mac
    python3
    ripgrep
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    sd
    skhd
    starship
    terraform
    terraform-lsp
    watchexec
    yubikey-manager
    zsh
  ];
}
