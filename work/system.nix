{
  config,
  username,
  pkgs,
  ...
}:
# This section apply settings to the system configuration only available on macOS
# see <https://daiderd.com/nix-darwin/manual/index.html#sec-options> for more options
{
  system = {
    stateVersion = 5;
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
    defaults = {
      menuExtraClock.Show24Hour = true;
      dock.autohide = true;
      dock.mru-spaces = false;
      screencapture.location = "~/Pictures/screenshots";
      finder.AppleShowAllExtensions = true;
    };
  };

  users.users."${username}".home = "/Users/${username}";
  nix.settings.trusted-users = [ username ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.variables = {
    EDITOR = "hx";
  };

  environment.systemPackages = with pkgs; [
    awscli2
    cargo-outdated
    coreutils
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.Security
    delta
    diffr
    gh
    git
    gnupg
    go
    golangci-lint
    google-cloud-sdk
    gopls
    helix
    jfrog-cli
    just
    k9s
    kdash
    kotlin-language-server
    kubernetes-helm
    kustomize
    libgit2
    libiconv
    nixfmt-rfc-style
    openssl
    openssl.dev
    oras
    perl
    pinentry_mac
    pkg-config
    python3
    rustup
    shellcheck
    skhd
    tailwindcss
    templ
    terraform
    terraform-lsp
    trivy
    virtualenv
    watchexec
    wezterm
    yubikey-manager
  ];

  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.jetbrains-mono
    ];
  };
}
