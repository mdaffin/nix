{ config, lib, pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
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

  # services.pcscd.enable = true;
  programs.gnupg.agent = {
     enable = true;
     # pinentryFlavor = "mac";
     enableSSHSupport = true;
  };


  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  # system.stateVersion = 4;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # programs.zsh.enable = true;  # default shell on catalina

  # programs.zsh.interactiveShellInit = ''
  #   # Note that loading grml's zshrc here will override NixOS settings such as
  #   # `programs.zsh.histSize`, so they will have to be set again below.
  #   source ${pkgs.grml-zsh-config}/etc/zsh/zshrc

  #   export EDITOR='hx'
  #   alias ls=exa

  #   # Increase history size.
  #   HISTSIZE=10000000

  #   # Prompt modifications.
  #   #
  #   # In current grml zshrc, changing `$PROMPT` no longer works,
  #   # and `zstyle` is used instead, see:
  #   # https://unix.stackexchange.com/questions/656152/why-does-setting-prompt-have-no-effect-in-grmls-zshrc

  #   # Disable the grml `sad-smiley` on the right for exit codes != 0;
  #   # it makes copy-pasting out terminal output difficult.
  #   # Done by setting the `items` of the right-side setup to the empty list
  #   # (as of writing, the default is `items sad-smiley`).
  #   # See: https://bts.grml.org/grml/issue2267
  #   zstyle ':prompt:grml:right:setup' items

  #   # Add nix-shell indicator that makes clear when we're in nix-shell.
  #   # Set the prompt items to include it in addition to the defaults:
  #   # Described in: http://bewatermyfriend.org/p/2013/003/
  #   function nix_shell_prompt () {
  #     REPLY=''${IN_NIX_SHELL+"(nix-shell) "}
  #   }
  #   grml_theme_add_token nix-shell-indicator -f nix_shell_prompt '%F{magenta}' '%f'
  #   zstyle ':prompt:grml:left:setup' items rc nix-shell-indicator change-root user at host path vcs percent

  #   if [ -n "''${commands[fzf-share]}" ]; then
  #     source "$(fzf-share)/key-bindings.zsh"
  #     source "$(fzf-share)/completion.zsh"
  #   fi

  #   # Starling config
  #   if [ -e "$HOME/.starling/etc/profile" ]; then
  #     . "$HOME/.starling/etc/profile"
  #   else
  #     echo "Could not find '$HOME/.starling/etc/profile'"
  #   fi

  #   export PATH=$HOME/.local/bin:$HOME/.cargo/bin:$PATH

  #   cluster-name-for() {
  #       local account=''${1?"missing aws account"}
  #       case "$account" in
  #           DevBanking|BuildTheBank|Prod)
  #               echo "smartcore"
  #           ;;
  #           DevTooling|DemoTooling|ProdTooling)
  #               echo "tooling"
  #           ;;
  #           DevBulb|DemoBulb|ProdBulb)
  #               echo "bulb"
  #           ;;
  #           DevNestboxSB|DemoNestboxSB|ProdNestboxSB)
  #               echo "nestboxsb"
  #           ;;
  #       esac
  #   }

  #   aws-region-for() {
  #       local account=''${1?"missing aws account"}
  #       case "$account" in
  #           DevBanking|BuildTheBank|Prod)
  #               echo "eu-west-1"
  #           ;;
  #           DevTooling|DemoTooling|ProdTooling)
  #               echo "eu-west-1"
  #           ;;
  #           DevBulb|DemoBulb|ProdBulb)
  #               echo "eu-central-1"
  #           ;;
  #           DevNestboxSB|DemoNestboxSB|ProdNestboxSB)
  #               echo "eu-west-2"
  #           ;;
  #           DemoSecurity|ProdSecurity)
  #               echo "eu-west-1"
  #           ;;
  #       esac
  #   }

  #   select-kube-cluster() {
  #       local account=''${1:?"missing aws account"}
  #       local cluster=$(cluster-name-for "$account")
  #       local cluster_letter=''${2:?"missing cluster letter"}
  #       local aws_role=''${3:-Staff}
  #       export AWS_REGION=$(aws-region-for "$account")
  #       : "''${cluster:?"unknown cluster"}"
  #       assumerole "''${aws_role}In''${account}" "$(ykman oath accounts code --single aws)" || return
  #       export KUBECONFIG=~/.kube/config-''${account}-''${cluster}_''${cluster_letter}
  #       aws eks update-kubeconfig --name "''${cluster}_''${cluster_letter}"
  #   }
  # '';
  # programs.zsh.promptInit = ""; # otherwise it'll override the grml prompt

  # users.users.root.shell = pkgs.zsh;
}

