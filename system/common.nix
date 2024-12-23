{ config, pkgs, ... }:

{
  imports = [ ];

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
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "bcachefs" ];
  };

  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

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


  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.pathsToLink = [ "/libexec" ];

  services = {
    udisks2.enable = true;
    xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = [];
      };
      displayManager.lightdm = {
        enable = true;
        greeter.enable = false;
      };
      xkb.layout = "gb";
    };
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "nous";
      defaultSession = "none+i3";
    };
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad = {
        tapping = false;
        disableWhileTyping = true;
        naturalScrolling = true;
        clickMethod = "clickfinger";
        accelProfile = "flat";
        accelSpeed = "1";
        additionalOptions = ''
          Option "PalmDetection" "True"
        '';
      };
    };
  };

  console.keyMap = "uk";

  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
    extraConfig = "
      load-module module-switch-on-connect
    ";
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
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
    arandr
  ];

  users.users.nous = {
    isNormalUser = true;
    description = "nous";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.nushell;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
