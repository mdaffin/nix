{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark";
    plugins = with pkgs; [
      rofi-calc
      rofi-systemd
      rofi-bluetooth
      rofi-emoji
      rofi-screenshot
      rofi-power-menu
    ];
  };
  home.packages = with pkgs; [
    i3status
    i3lock
    alacritty
    firefox
    brightnessctl
    rofi-calc
    rofi-systemd
    rofi-bluetooth
    rofi-emoji
    rofi-screenshot
    rofi-power-menu
  ];
  xsession.windowManager.i3 = {
    enable = true;
    config = let mod = "Mod4"; in {
      modifier = mod;
      colors.background = "#444444";

      fonts = {
        names = [ "DejaVu Sans Mono" "FontAwesome 6" ];
        style = "Bold Semi-Condensed";
        size = 8.0;
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+Shift+s" = "exec systemctl suspend";
        "${mod}+Return" = "exec ${pkgs.alacritty }/bin/alacritty";
        "${mod}+Shift+Return" = "exec ${pkgs.firefox }/bin/firefox";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun -modi drun,window,calc,run,power-menu:rofi-power-menu";
        # "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        "${mod}+Shift+l" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 444444 & sleep 5 && xset dpms force off'";
        "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
        "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
        "XF86AudioPrev" = "exec --no-startup-id playerctl previous";
        "XF86AudioNext" = "exec --no-startup-id playerctl next";

        "XF86MonBrightnessUp" = "exec brightnessctl set 2%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 2%-";

        # # Focus
        # "${mod}+j" = "focus left";
        # "${mod}+k" = "focus down";
        # "${mod}+l" = "focus up";
        # "${mod}+semicolon" = "focus right";

        # # Move
        # "${mod}+Shift+j" = "move left";
        # "${mod}+Shift+k" = "move down";
        # "${mod}+Shift+l" = "move up";
        # "${mod}+Shift+semicolon" = "move right";

        # # My multi monitor setup
        # "${mod}+m" = "move workspace to output DP-2";
        # "${mod}+Shift+m" = "move workspace to output DP-5";
      };

      # bars = [
      #   {
      #     position = "bottom";
      #     statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
      #   }
      # ];
    };
  };
}
