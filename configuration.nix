{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-49bfd765-d5c0-4992-85c9-a733f39192af".device = "/dev/disk/by-uuid/49bfd765-d5c0-4992-85c9-a733f39192af";
  networking.hostName = "workshop";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  xdg.portal.wlr.enable = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.udisks2.enable = true;

  # services.greetd = {
  #   enable = true;
  #   settings = rec {
  #     initial_session = {
  #       command = "${pkgs.hyprland}/bin/Hyprland";
  #       user = "nous";
  #     };
  #     default_session = initial_session;
  #   };
  # };

  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    enable = true;

    desktopManager.xterm.enable = false;
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "nous";
      defaultSession = "none+i3";
      lightdm = {
        enable = true;
        greeter.enable = false;
      };
    };
    windowManager = {
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };
    layout = "gb";
    libinput = {
      enable = true;
      touchpad = {
        tapping = false;
        disableWhileTyping = true;
        naturalScrolling = true;
        clickMethod = "clickfinger";
        accelProfile = "flat";
        additionalOptions = ''
          Option "PalmDetection" "True"
        '';
      };
    };
  };

  console.keyMap = "uk";

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  services.printing.enable = true;

  nixpkgs.config = {
    # workaround for issue with obsidian: https://github.com/NixOS/nixpkgs/issues/273611
    permittedInsecurePackages =
      pkgs.lib.optional (pkgs.obsidian.version == "1.4.16") "electron-25.9.0";
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    nushell
    git
    helix
  ];

  users.users.nous = {
    isNormalUser = true;
    description = "nous";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.nushell;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
