{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    unrar
    steamtinkerlaunch
    protonplus
    winetricks
  ];
  programs.gamemode = {
    enable = true;
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraPackages = with pkgs; [ hidapi ];
  };
  hardware.steam-hardware.enable = true;

  services.pipewire.alsa.support32Bit = true;
}
