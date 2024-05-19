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

  services.network-manager-applet.enable = true;

  home.packages = with pkgs; [
    i3status
    i3lock
    alacritty
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
        "${mod}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${mod}+Shift+Return" = "exec ${pkgs.firefox}/bin/firefox";
        "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun -modi drun";
        # "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        # "${mod}+Shift+l" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 444444 & sleep 5 && xset dpms force off'";
        "${mod}+Ctrl+x" = "--release exec --no-startup-id ${pkgs.xorg.xkill}/bin/xkill";

        "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
        "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
        "XF86AudioPrev" = "exec --no-startup-id playerctl previous";
        "XF86AudioNext" = "exec --no-startup-id playerctl next";

        "XF86MonBrightnessUp" = "exec brightnessctl set 2%+";
        "XF86MonBrightnessDown" = "exec brightnessctl set 2%-";

        # Focus
        "${mod}+Left" = "focus left";
        "${mod}+j" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+k" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+l" = "focus up";
        "${mod}+Right" = "focus right";
        "${mod}+semicolon" = "focus right";

        # Move
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+j" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+k" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+l" = "move up";
        "${mod}+Shift+Right" = "move right";
        "${mod}+Shift+semicolon" = "move right";

        # # My multi monitor setup
        # "${mod}+m" = "move workspace to output DP-2";
        # "${mod}+Shift+m" = "move workspace to output DP-5";

        "${mod}+Tab" = "focus parent";
        "${mod}+Shift+Tab" = "focus child";

        "${mod}+Ctrl+Right" = "workspace next";
        "${mod}+Ctrl+Left" = "workspace prev";

        # move workspace to different screens
        "${mod}+Ctrl+Shift+Left" = "move workspace to output left";
        "${mod}+Ctrl+Shift+Right" = "move workspace to output right";

        "${mod}+Mod1+Left" = "resize shrink width 5 px or 5 ppt";
        "${mod}+Mod1+Down" = "resize grow height 5 px or 5 ppt";
        "${mod}+Mod1+Up" = "resize shrink height 5 px or 5 ppt";
        "${mod}+Mod1+Right" = "resize grow width 5 px or 5 ppt";

        "${mod}+Mod1+Shift+Left" = "resize shrink width 1 px or 1 ppt";
        "${mod}+Mod1+Shift+Down" = "resize grow height 1 px or 1 ppt";
        "${mod}+Mod1+Shift+Up" = "resize shrink height 1 px or 1 ppt";
        "${mod}+Mod1+Shift+Right" = "resize grow width 1 px or 1 ppt";
      };
    };
  };
}
