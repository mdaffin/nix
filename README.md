# nix

My NixOS configuration as a single flake: three hosts, an installer ISO, dev shells
and project templates, plus home-manager and nix settings modules that other flakes
can reuse.

## Layout

| Path | Contents |
| --- | --- |
| `flake.nix` | Inputs and outputs: hosts, modules, `devShells`, `templates`, `checks`, `formatter` |
| `hosts/<name>/` | Per host config (`configuration.nix`, hardware, disko layout) |
| `system/` | NixOS modules hosts opt in to (desktop, audio, laptop, ...) |
| `user/` | home-manager config shared across machines |
| `shells/` | Dev shells, exposed as `devShells.<system>.<name>` |
| `templates/` | Thin project templates wrapping the shells |
| `hosts/iso/` | Installer ISO (`nixosConfigurations.iso`) |

Hosts: `niver`, `eulfe`, `lucal`, plus the installer `iso`.

## Day to day

```nushell
git pull --rebase --autostash origin main; sudo nixos-rebuild switch --flake $".#(hostname)"

nix flake update      # update all inputs
nix flake check       # formatting, statix and evaluation
nix fmt               # format
```

## Reusable modules

The flake exports modules for other flakes:

- `homeModules.{base,cli-extras,editor,git,language-servers,shell}`: home-manager
  modules. `base` needs a `username` in `extraSpecialArgs`.
- `nixosModules.nix-settings` and `darwinModules.nix-settings`: shared nix settings.

```nix
inputs.nix.url = "github:mdaffin/nix";
# then, in a home-manager config:
imports = [ inputs.nix.homeModules.base inputs.nix.homeModules.shell ];
```

## Automatic upgrades

Every NixOS host runs `system.autoUpgrade` daily (`system/auto-upgrade.nix`). It
stages the new generation for the next boot and never reboots. `upgrade-pause`,
`upgrade-resume` and `upgrade-status` control it. It uses the pushed repo, so
only what is on GitHub gets picked up. To test a run: `sudo systemctl start nixos-upgrade`.

The lock is updated weekly by `update-lock` and pushed straight to main. If an
update breaks something, run the `revert-lock` workflow from the repo's Actions
tab (Run workflow), or `gh workflow run revert-lock.yml`. It restores
`flake.lock` to before the latest update, so hosts upgrade back to the last good
lock. The next scheduled update will update it again.

## Dev environments

```nushell
nix develop github:mdaffin/nix#rust    # one-off shell (go, kube, python, rust)
nix flake init -t github:mdaffin/nix#rust # per project flake + .envrc
```

The templates are standalone: they copy the shell definition into the project and
lock their own nixpkgs, so they do not depend on this repo after `flake init`.
With direnv enabled, `use flake` in `.envrc` loads the shell automatically.

## Adding a host

1. Create `hosts/<name>/` with `configuration.nix` and hardware config
   (and a disko layout if it is installed from scratch).
2. Set `system.stateVersion` in that host's configuration.
3. Add `<name> = mkNixos { hostname = "<name>"; };` to `nixosConfigurations`.

## Installer ISO

A live COSMIC session for installing the hosts: latest kernel with bcachefs, audio
and bluetooth, nushell, helix (no language servers), git, zen, and `disko` plus the
usual partitioning tools (`parted`, `gdisk`, `cryptsetup`, `smartmontools`,
`nvme-cli`). Build it on an x86_64-linux machine; the image ends up in `result/iso/`:

```nushell
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

The image has no copy of the repo inside it. Install straight from GitHub (see below).

## Install

Boot the installer, then:

```nushell
sudo -i
disko --mode format --flake github:mdaffin/nix#HOSTNAME
```

disko cannot create encrypted bcachefs, so the root partition is formatted by
hand (adjust the devices to the host's layout in `hosts/<name>/disko-configuration.nix`):

```bash
bcachefs format -L root --encrypted --compression=lz4 --background_compression=zstd /dev/sda2
bcachefs unlock /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
nixos-install --flake github:mdaffin/nix#HOSTNAME
```

niver has two NVMe drives mirrored in one encrypted bcachefs filesystem
(`replicas=2`). It is mounted by one member's partlabel and bcachefs finds the
other from its superblock. Format both devices in a single `bcachefs format`
call when reinstalling it.
