{ pkgs, ... }:
{
  users.users.nous = {
    isNormalUser = true;
    description = "nous";
    extraGroups = [
      "networkmanager"
      "wheel"
      "pipewire"
    ];
    shell = pkgs.nushell;
  };
}
