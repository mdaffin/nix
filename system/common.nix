{ pkgs, ... }:
{
  imports = [
    ./auto-upgrade.nix
    ./boot.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./users.nix
  ];

  nix.optimise.automatic = true;

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      # Keep recent generations to roll back to, however old they are.
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    file
    nushell
    git
    helix
    pciutils
    dig
    ncdu
  ];
}
