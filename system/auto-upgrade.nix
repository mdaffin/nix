# Daily upgrade from the pushed flake, staged for the next boot.
#
# - Never switches or reboots by itself: the disks are encrypted, so a reboot
#   would stop at the passphrase prompt, and a live switch changes the desktop
#   under you.
# - The timer is persistent, so a run missed while the machine was asleep
#   happens once it wakes.
# - Runs at the lowest CPU/IO priority. Desktop notifications: one if a run is
#   still going after a minute, one when a new generation is ready (once), and
#   one on failure. Runs that change nothing and finish quickly are silent.
# - `upgrade-pause` stops a running upgrade and prevents new ones until
#   `upgrade-resume`. Paths already downloaded are kept, so a later run does not
#   start from scratch (useful on a slow connection).
{ config, pkgs, ... }:
let
  stateDir = "/var/lib/nixos-upgrade";
  pausedFile = "${stateDir}/paused";

  # Best effort: tell every logged in desktop session, ignore failures.
  notify = pkgs.writeShellScript "upgrade-notify" ''
    for bus in /run/user/*/bus; do
      [ -S "$bus" ] || continue
      uid=$(basename "$(dirname "$bus")")
      ${pkgs.util-linux}/bin/runuser -u "$(${pkgs.coreutils}/bin/id -nu "$uid")" -- \
        ${pkgs.coreutils}/bin/env "DBUS_SESSION_BUS_ADDRESS=unix:path=$bus" \
        ${pkgs.libnotify}/bin/notify-send --app-name "System upgrade" "$1" "$2" || true
    done
  '';

  # Quick runs are not worth a notification: only say an upgrade is in progress
  # if it is still running after a minute.
  notifySlow = pkgs.writeShellScript "upgrade-notify-slow" ''
    ${pkgs.coreutils}/bin/sleep 60
    if [ "$(${pkgs.systemd}/bin/systemctl is-active nixos-upgrade.service)" = activating ]; then
      ${notify} "System upgrade in progress" "Still downloading in the background. Pause with: upgrade-pause"
    fi
  '';

  # Only announce a new generation once, and not at all if nothing changed or
  # the run was stopped with upgrade-pause.
  notifyDone = pkgs.writeShellScript "upgrade-notify-done" ''
    [ -e ${pausedFile} ] && exit 0
    if [ "$SERVICE_RESULT" = success ]; then
      new=$(${pkgs.coreutils}/bin/readlink -f /nix/var/nix/profiles/system)
      last=$(${pkgs.coreutils}/bin/cat ${stateDir}/last-notified 2>/dev/null || true)
      if [ "$new" != "$(${pkgs.coreutils}/bin/readlink -f /run/booted-system)" ] && [ "$new" != "$last" ]; then
        echo "$new" > ${stateDir}/last-notified
        ${notify} "System upgrade ready" "Reboot to switch to the new generation."
      fi
    else
      ${notify} "System upgrade did not finish" "Result: $SERVICE_RESULT. See: journalctl -u nixos-upgrade"
    fi
  '';
in
{
  # The repo is public, so root fetches it over https with no credentials.
  system.autoUpgrade = {
    enable = true;
    flake = "github:mdaffin/nix#${config.networking.hostName}";
    operation = "boot";
    dates = "12:00";
    persistent = true;
    allowReboot = false;
  };

  systemd = {
    tmpfiles.rules = [ "d ${stateDir} 0755 root root -" ];

    services = {
      nixos-upgrade = {
        unitConfig.ConditionPathExists = "!${pausedFile}";
        serviceConfig = {
          Nice = 19;
          IOSchedulingClass = "idle";
          ExecStartPre = "-${pkgs.systemd}/bin/systemctl start --no-block nixos-upgrade-slow-notify.service";
          ExecStopPost = "-${notifyDone}";
        };
      };

      nixos-upgrade-slow-notify = {
        description = "Notify if the system upgrade is taking a while";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = notifySlow;
        };
      };
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "upgrade-pause" ''
      sudo touch ${pausedFile}
      sudo systemctl stop nixos-upgrade.service
      echo "Upgrades paused. Resume with: upgrade-resume"
    '')
    (pkgs.writeShellScriptBin "upgrade-resume" ''
      sudo rm -f ${pausedFile}
      echo "Upgrades resumed. Next run: $(systemctl list-timers nixos-upgrade.timer --no-legend | cut -c1-40)"
    '')
    (pkgs.writeShellScriptBin "upgrade-status" ''
      if [ -e ${pausedFile} ]; then echo "paused"; else echo "enabled"; fi
      systemctl is-active nixos-upgrade.service || true
      systemctl list-timers nixos-upgrade.timer --no-pager
    '')
  ];
}
