{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai.agent;

  ollamaUrl = "http://127.0.0.1:11434";
  sandboxHome = config.home.homeDirectory;

  agentTools = with pkgs; [
    git
    gnugrep
    gnused
    findutils
    ripgrep
    diffutils
    bash
    coreutils
  ];

  # Minimal gitconfig so the real one (with includes, credential helpers,
  # sshCommand, ...) never enters the sandbox.
  gitConfig = pkgs.writeText "ai-agent-gitconfig" ''
    [user]
      name = ai-agent
      email = ai-agent@localhost
    [safe]
      directory = *
  '';

  opencodeConfig = pkgs.writeText "opencode.json" (builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    model = "ollama/${cfg.model}";
    provider.ollama = {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama (local)";
      options.baseURL = "${ollamaUrl}/v1";
      models.${cfg.model}.name = cfg.model;
    };
  });

  agents = {
    opencode = {
      package = pkgs.opencode;
      bin = "${pkgs.opencode}/bin/opencode";
      binds = ["--ro-bind" "${opencodeConfig}" "${sandboxHome}/.config/opencode/opencode.json"];
      env = [];
      args = [];
    };
    aider = {
      package = pkgs.aider-chat;
      bin = "${pkgs.aider-chat}/bin/aider";
      binds = [];
      env = ["--setenv" "OLLAMA_API_BASE" ollamaUrl];
      args = ["--model" "ollama_chat/${cfg.model}"];
    };
  };

  agent = agents.${cfg.name};

  # Fixed bwrap arguments as a nushell list literal (JSON is valid nu syntax).
  bwrapArgs = builtins.toJSON ([
      "--unshare-all"
      "--share-net"
      "--die-with-parent"
      "--new-session"
      "--dev" "/dev"
      "--proc" "/proc"
      "--tmpfs" "/tmp"
      "--tmpfs" "/run"
      "--ro-bind" "/nix/store" "/nix/store"
      "--ro-bind" "/run/current-system" "/run/current-system"
      "--ro-bind-try" "/etc/static" "/etc/static"
      "--ro-bind-try" "/etc/passwd" "/etc/passwd"
      "--ro-bind-try" "/etc/group" "/etc/group"
      "--ro-bind-try" "/etc/resolv.conf" "/etc/resolv.conf"
      "--ro-bind-try" "/etc/nsswitch.conf" "/etc/nsswitch.conf"
      "--ro-bind-try" "/etc/hosts" "/etc/hosts"
      "--ro-bind-try" "/etc/ssl/certs" "/etc/ssl/certs"
      "--tmpfs" sandboxHome
      "--ro-bind" "${gitConfig}" "${sandboxHome}/.config/git/config"
    ]
    ++ agent.binds
    ++ [
      "--chdir" "${sandboxHome}/project"
      "--setenv" "HOME" sandboxHome
      "--setenv" "PATH" "${lib.makeBinPath ([agent.package] ++ agentTools)}:/run/current-system/sw/bin"
    ]
    ++ agent.env);

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

      let cmd = [...$bwrap_args "--bind" $project "${sandboxHome}/project" "${agent.bin}" ...$agent_args ...$args]
      exec ${pkgs.bubblewrap}/bin/bwrap ...$cmd
    }
  '';
in {
  options.ai.agent = {
    name = lib.mkOption {
      type = lib.types.enum ["opencode" "aider"];
      default = "opencode";
      description = "Which coding agent to install and wrap.";
    };
    model = lib.mkOption {
      type = lib.types.str;
      default = "qwen3.8:27b";
      description = "Ollama model tag the agent should use. It must be pulled separately with `ollama pull`.";
    };
  };

  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    home.packages = [agent.package sandbox];
  };
}
