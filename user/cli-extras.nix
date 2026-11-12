# Extra command line tools on top of shell.nix. Kept apart so images that only
# want the core shell setup (the installer ISO) can leave them out.
{ pkgs, ... }:
{
  programs = {
    bottom.enable = true;
    btop.enable = true;
  };

  home.packages = with pkgs; [
    glow
    nufmt
    sd
    yq-go
  ];
}
