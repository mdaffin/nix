{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.ai.agent;

  agentTools = [pkgs.git];

  # Wrap a coding agent in bubblewrap: fresh namespaces, throwaway home, the
  # project directory as the only writable path. Network is kept solely so the
  # agent can reach the loopback ollama endpoint.
  mkSandbox = {
    name,
    bin,
  }:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail

      PROJECT="''${1:-$PWD}"
      shift || true

      exec ${pkgs.bubblewrap}/bin/bwrap \
        --unshare-all --share-net \
        --die-with-parent --new-session \
        --dev /dev --proc /proc \
        --tmpfs /tmp \
        --tmpfs /run \
        --ro-bind /nix/store /nix/store \
        --ro-bind /run/current-system /run/current-system \
        --ro-bind-try /etc/static /etc/static \
        --ro-bind-try /etc/resolv.conf /etc/resolv.conf \
        --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf \
        --ro-bind-try /etc/hosts /etc/hosts \
        --ro-bind-try /etc/ssl/certs /etc/ssl/certs \
        --tmpfs /home/${username} \
        --bind "$PROJECT" /home/${username}/project \
        --ro-bind-try "${config.home.homeDirectory}/.gitconfig" /home/${username}/.gitconfig \
        --chdir /home/${username}/project \
        --setenv HOME /home/${username} \
        --setenv PATH "${
        lib.makeBinPath ([bin] ++ agentTools ++ [pkgs.bash pkgs.coreutils])
      }:/run/current-system/sw/bin" \
        ${bin} "$@"
    '';
in {
  options.ai.agent = {
    agent = lib.mkOption {
      type = lib.types.enum ["opencode" "aider"];
      default = "opencode";
      description = "Which coding agent to install and wrap.";
    };
  };

  config = {
    home.packages =
      (lib.optionals (cfg.agent == "opencode") [
        pkgs.opencode
        (mkSandbox {
          name = "opencode-sandbox";
          bin = "${pkgs.opencode}/bin/opencode";
        })
      ])
      ++ (lib.optionals (cfg.agent == "aider") [
        pkgs.aider-chat
        (mkSandbox {
          name = "aider-sandbox";
          bin = "${pkgs.aider-chat}/bin/aider";
        })
      ]);
  };
}
