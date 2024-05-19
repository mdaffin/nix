{ config, pkgs, ... }:

{
  imports = [ ];

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
    Xft.dpi: 192
    EOF
  '';
}
