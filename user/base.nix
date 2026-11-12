{
  pkgs,
  username,
  ...
}:

{
  home = {
    inherit username;
    homeDirectory = (if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home") + "/${username}";
  };

  programs = {
    home-manager.enable = true;

    # Prebuilt file index: nix-locate, command-not-found and `, <command>`.
    nix-index.enable = true;
    nix-index-database.comma.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # Keep the "loading"/"using flake" lines but drop the huge export list.
      config.global.hide_env_diff = true;
    };
  };
}
