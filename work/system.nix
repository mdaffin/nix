{ config, ... }:
# This section apply settings to the system configuration only available on macOS
# see <https://daiderd.com/nix-darwin/manual/index.html#sec-options> for more options
{
  system = {
    stateVersion = 5;
    # defaults.smb.NetBIOSName = config.networking.hostName;

    # Add ability to used TouchID for sudo authentication
    # security.pam.enableSudoTouchIdAuth = true;
  };
  programs.zsh.enable = true;

}
