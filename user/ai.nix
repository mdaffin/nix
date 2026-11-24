{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ai.agent;

  ollamaUrl = "http://127.0.0.1:11434";
  sandboxHome = config.home.homeDirectory;

  agentTools = with pkgs; [
    jq
    statix
    deadnix
    less
    lesspipe
    file
    tree
    nix
    nixfmt
    git
    gnugrep
    gnused
    findutils
    ripgrep
    diffutils
    bash
    nushell
    coreutils
    dprint
    dprint-plugins.dprint-plugin-markdown
  ];

  # Minimal gitconfig so the real one (with includes, credential helpers,
  # sshCommand, ...) never enters the sandbox.
  gitConfig = pkgs.writeText "ai-agent-gitconfig" ''
    [user]
      name = nous
      email = github.palpable@so3.uk
    [safe]
      directory = *
  '';

  opencodeConfig = pkgs.writeText "opencode.json" (
    builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "ollama/${cfg.model}";
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options.baseURL = "${ollamaUrl}/v1";
        models.${cfg.model} = {
          name = cfg.model;
          # Cap the model's reported context width at the Ollama limit (OLLAMA_CONTEXT_LENGTH = 64000).
          # Without this, OpenCode reads Ollama's native 262144 and computes its context bar
          # and compaction threshold against a 256k window — so at ~58k it says "22% full" and
          # never compacts, while you're actually ~90% into the real 64k and about to hit the
          # "too long" wall. `limit.output` is required by the schema; setting it to the same
          # value is a no-op for responses (output can never exceed the context window) and
          # just keeps the two caps consistent.
          limit.context = 128000;
          limit.output = 128000;
        };
      };
    }
  );

  # TUI keybindings. ctrl+c stays bound to prompt.clear and
  # session.interrupt; it is only removed from app.exit so the app no
  # longer quits on ctrl+c.
  opencodeCliConfig = pkgs.writeText "cli.json" (
    builtins.toJSON {
      session = {
        sidebar = "auto";
        scrollbar = false;
        submit_scroll = "bottom";
        thinking = "show";
        grouping = "auto";
        image_preview = false;
        tps = true;
        markdown = "rendered";
        new_location = "launch";
        permissions = "prompt";
      };
      keybinds = {
        app_exit = [
          "ctrl+d"
          "<leader>q"
        ];
      };
    }
  );

  agents = {
    opencode = {
      package = pkgs.opencode;
      bin = "${pkgs.opencode}/bin/opencode";
      binds = [
        "--ro-bind"
        "${sandboxHome}/.config/opencode"
        "${sandboxHome}/.config/opencode"
      ];
      env = [ ];
      args = [ "--standalone" ]; # private per-instance server, no port collision
    };
    aider = {
      package = pkgs.aider-chat;
      bin = "${pkgs.aider-chat}/bin/aider";
      binds = [ ];
      env = [
        "--setenv"
        "OLLAMA_API_BASE"
        ollamaUrl
      ];
      args = [
        "--model"
        "ollama_chat/${cfg.model}"
      ];
    };
  };

  agent = agents.${cfg.name};

  # Tools available in the sandbox. Nothing from the host system profile is
  # visible; project-specific tools come from the project flake dev shell.
  basePath = lib.makeBinPath ([ agent.package ] ++ agentTools);

  # Fixed bwrap arguments as a nushell list literal (JSON is valid nu syntax).
  bwrapArgs = builtins.toJSON (
    [
      "--unshare-all"
      "--share-net"
      "--die-with-parent"
      "--clearenv"
      "--dev"
      "/dev"
      "--proc"
      "/proc"
      "--tmpfs"
      "/tmp"
      "--tmpfs"
      "/run"
      "--ro-bind"
      "/nix/store"
      "/nix/store"
      "--symlink"
      "${pkgs.bash}/bin/sh"
      "/bin/sh"
      "--symlink"
      "${pkgs.coreutils}/bin/env"
      "/usr/bin/env"
      "--ro-bind-try"
      "/etc/static"
      "/etc/static"
      "--ro-bind-try"
      "/etc/passwd"
      "/etc/passwd"
      "--ro-bind-try"
      "/etc/group"
      "/etc/group"
      "--ro-bind-try"
      "/etc/resolv.conf"
      "/etc/resolv.conf"
      "--ro-bind-try"
      "/etc/nsswitch.conf"
      "/etc/nsswitch.conf"
      "--ro-bind-try"
      "/etc/hosts"
      "/etc/hosts"
      "--ro-bind-try"
      "/etc/ssl/certs"
      "/etc/ssl/certs"
      "--ro-bind-try"
      "/sys"
      "/sys"
      "--tmpfs"
      sandboxHome
      "--ro-bind"
      "${gitConfig}"
      "${sandboxHome}/.config/git/config"
      "--ro-bind"
      "${sandboxHome}/.config/git/ignore"
      "${sandboxHome}/.config/git/ignore"
      "--ro-bind"
      "${sandboxHome}/.config/dprint"
      "${sandboxHome}/.config/dprint"
    ]
    ++ agent.binds
    ++ [
      "--setenv"
      "HOME"
      sandboxHome
    ]
    ++ agent.env
  );

  # Wrap the coding agent in bubblewrap: fresh namespaces, throwaway home, the
  # project directory as the only writable path.
  #
  # The network namespace is shared with the host because ollama listens on
  # host loopback, so the agent can also reach the internet and the LAN. This
  # is a known gap; closing it needs a unix-socket bridge into a private netns.
  #
  # Usage: <name>-sandbox [PROJECT_DIR] [AGENT_ARGS...]
  # The first argument is only taken as the project when it is a directory.
  sandbox = pkgs.writeScriptBin "${cfg.name}-sandbox" ''
    #!${lib.getExe pkgs.nushell}

    def --wrapped main [--project: string = ".", ...args: string] {
      let project = $project | path expand

      let bwrap_args = ${bwrapArgs}
      let agent_args = ${builtins.toJSON agent.args}

      # Pass terminal settings through; --clearenv drops everything else.
      let passthrough = ["TERM" "COLORTERM" "LANG" "LC_ALL" "TZ"]
        | where {|n| $n in $env}
        | each {|n| ["--setenv" $n ($env | get $n)]}
        | flatten

      # Realise the project flake dev shell outside the sandbox (the sandbox
      # has no nix daemon) and hand its environment in. Only store paths are
      # kept on PATH so host locations never leak in.
      let skip = ["HOME" "PATH" "PWD" "OLDPWD" "SHELL" "TMPDIR" "TMP" "TEMP" "TEMPDIR" "NIX_BUILD_TOP" "NIX_STORE" "TERM" "SHLVL" "_"]
      let dev = if ($project | path join "flake.nix" | path exists) {
        try {
          ^nix print-dev-env --json $project | from json | get variables
        } catch {
          print -e "warning: could not load the project dev shell; continuing without it"
          {}
        }
      } else { {} }
      let dev_vars = $dev
        | transpose name spec
        | where {|v| $v.spec.type == "exported" and ($v.name not-in $skip) and (($v.spec.value | describe) == "string")}
      let dev_args = $dev_vars
        | each {|v| ["--setenv" $v.name $v.spec.value]}
        | flatten
      let dev_path = if "PATH" in $dev {
        $dev.PATH.value | split row ":" | where {|p| $p starts-with "/nix/store/"}
      } else { [] }
      let path = ($dev_path | append "${basePath}" | str join ":")

      let cmd = [
        ...$passthrough ...$dev_args ...$bwrap_args
        "--setenv" "PATH" $path
        "--bind" $project $project
        "--chdir" $project
        "${agent.bin}" ...$agent_args ...$args
      ]
      exec ${pkgs.bubblewrap}/bin/bwrap ...$cmd
    }
  '';
in
{
  options.ai.agent = {
    name = lib.mkOption {
      type = lib.types.enum [
        "opencode"
        "aider"
      ];
      default = "opencode";
      description = "Which coding agent to install and wrap.";
    };
    model = lib.mkOption {
      type = lib.types.str;
      default = "ornith-1.5:35b";
      description = "Ollama model tag the agent should use. It must be pulled separately with `ollama pull`.";
    };
  };

  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    xdg.configFile."opencode/opencode.json".source = "${opencodeConfig}";
    xdg.configFile."opencode/cli.json".source = "${opencodeCliConfig}";

    programs.agent-skills = {
      enable = true;

      sources = {
        nushell-pro = {
          input = "nushell-pro";
          subdir = ".";
        };
        nix-skills = {
          input = "nix-skills";
          subdir = "skills";
        };
        # Skills stored alongside this config instead of in a flake input.
        local = {
          input = "local-skills";
          subdir = ".";
        };
      };

      skills.enable = [
        "nushell-pro"
        "defcmd"
        "markdown"
        "project-planning"
      ];
      # Enable every skill shipped by the nix-skills repo (nix-language,
      # nixos-operations, home-manager, ...); new skills are picked up
      # automatically when the input is updated.
      skills.enableAll = [ "nix-skills" ];

      targets.opencode.enable = true;
    };

    home.packages = [
      agent.package
      sandbox
    ];
  };
}
