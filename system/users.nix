{ pkgs, ... }:
{
  users.users.nous = {
    isNormalUser = true;
    description = "nous";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
  };
}
