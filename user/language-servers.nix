# Language servers and formatters for helix. Kept apart from editor.nix so
# images that want the editor but not the toolchains (the installer ISO) can
# leave them out.
{ pkgs, ... }:
{
  programs.helix = {
    extraPackages = with pkgs; [
      bash-language-server
      gopls
      gotools
      kotlin-language-server
      marksman # markdown
      taplo # toml
      terraform-ls
      typescript-language-server
      yaml-language-server
    ];

    languages = {
      language = [
        {
          name = "go";
          formatter = {
            command = "goimports";
          };
        }
        {
          name = "templ";
          auto-format = true;
        }
      ];
    };
  };
}
