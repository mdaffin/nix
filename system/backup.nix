# Back up selected paths to a USB drive (label `hddbackup`) that is only
# sometimes attached: backups start when it is plugged in and daily after that.
{ pkgs, ... }:

let
  mountPoint = "/mnt/hddbackup";
  device = "/dev/disk/by-label/hddbackup";
in
{
  fileSystems.${mountPoint} = {
    inherit device;
    fsType = "bcachefs";
    options = [
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=60"
    ];
  };

  services.restic.backups.documents = {
    repository = "${mountPoint}/restic";
    initialize = true;
    paths = [ "/home/nous/Documents" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    # The repository has no password yet. restic needs the flag on every
    # command, and the module insists on a password file, so wrap restic and
    # point the module at an empty one. Remove both when a password is added.
    passwordFile = "/dev/null";
    package = pkgs.writeShellScriptBin "restic" ''
      exec ${pkgs.restic}/bin/restic --insecure-no-password "$@"
    '';
  };

  systemd.services.restic-backups-documents = {
    # Skip quietly while the drive is absent instead of failing the timer run.
    unitConfig = {
      ConditionPathExists = device;
      RequiresMountsFor = mountPoint;
    };
  };

  # Plugging the drive in starts a backup.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="hddbackup", TAG+="systemd", ENV{SYSTEMD_WANTS}="restic-backups-documents.service"
  '';
}
