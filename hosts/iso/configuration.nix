# Live installer image: COSMIC like the machines and bcachefs support. Install
# from GitHub:
#
#   nixos-install --flake github:mdaffin/nix#<host>
#
# Build the image with:
#
#   nix build .#nixosConfigurations.iso.config.system.build.isoImage
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  isoModules = "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd";
in
{
  imports = [
    "${isoModules}/installation-cd-graphical-base.nix"
    # Latest kernel with bcachefs on and zfs off, as on the hosts.
    "${isoModules}/latest-kernel.nix"
    inputs.home-manager.nixosModules.home-manager
    ../niver/XB270HU.nix
    ../../system/audio.nix
    ../../system/bluetooth.nix
    ../../system/desktop.nix
    ../../system/locale.nix
    ../../system/nix.nix
  ];

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  isoImage.edition = "cosmic";

  services.displayManager = {
    # Nothing to protect on a live session, and the greeter is still there to
    # handle an idle logout.
    autoLogin = {
      enable = true;
      user = "nixos";
    };
  };

  # The graphical base adds firefox to read the manual; the browser comes from
  # the home-manager config instead. Same list otherwise.
  environment.defaultPackages = lib.mkForce (
    with pkgs;
    [
      gparted
      mesa-demos
      nano
      rsync
      vim
    ]
  );

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.cryptsetup
    pkgs.gptfdisk
    pkgs.nvme-cli
    pkgs.parted
    pkgs.smartmontools
  ];

  programs.nh.enable = true;

  users.users.nixos.shell = pkgs.nushell;

  # The live user gets the core of the home-manager setup: shell, editor, git
  # and the browser. Left out on purpose: language servers, the extra CLI tools,
  # direnv and the nix-index database, to keep the image small.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.nixos = {
      imports = [
        ../../user/browser.nix
        ../../user/editor.nix
        ../../user/git.nix
        ../../user/shell.nix
      ];

      # The release the image was first built with: there is no existing
      # state to preserve on a live session.
      home.stateVersion = "26.05";
    };
  };
}
