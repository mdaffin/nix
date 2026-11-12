# General language servers for helix. Kept apart from editor.nix so images that
# want the editor but not the toolchains (the installer ISO) can leave them
# out. Language specific servers live in the dev shells.
{ pkgs, ... }:
{
  programs.helix.extraPackages = with pkgs; [
    bash-language-server
    marksman # markdown
    taplo # toml
    yaml-language-server
  ];
}
