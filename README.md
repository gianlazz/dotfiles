# gianlazz/dotfiles

Personal dotfiles managed with [Nix Home Manager](https://nix-community.github.io/home-manager/).

[Omarchy + Nix Home Manager Integration](https://github.com/basecamp/omarchy/discussions/987)

## Machines

| Machine | OS | Flake target |
|---------|-----|--------------|
| GPD MicroPC 2 | Omarchy Linux (Arch + Hyprland) | `.#micropc2` |
| MacBook | macOS | `.#macbook` |

---

## Prerequisites

```bash
# Nix (multi-user daemon mode recommended)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (after install, before first use)
mkdir -p ~/.config/nix
echo "experimental-features = nix-flakes nix-command" >> ~/.config/nix/nix.conf
```

---

## Setup on a New Machine

```bash
git clone https://github.com/gianlazz/dotfiles.git ~/Development/dotfiles
cd ~/Development/dotfiles
git checkout nix-hm
```

Apply Home Manager (manages all dotfiles + packages):

```bash
# GPD MicroPC 2
nix run home-manager -- switch --flake .#micropc2

# MacBook
nix run home-manager -- switch --flake .#macbook
```

Log out and back in so Nix-installed apps appear in the launcher.

For limine (system path under `/etc/`, cannot be managed by HM), sync manually after changes:

```bash
sudo cp ~/Development/dotfiles/limine/boot/limine.conf /boot/limine.conf
```

---

## What Manages What

| Config | Tool | Nix file | Location |
|--------|------|----------|----------|
| git config, aliases | Nix Home Manager | `common.nix` | `~/.config/git/config` |
| bash / .bashrc | Nix Home Manager | `common.nix` | `~/.bashrc` (symlinked to repo) |
| mise config | Nix Home Manager | `common.nix` | `~/.config/mise/config.toml` (symlinked to repo) |
| Packages (nextcloud, bitwarden) | Nix Home Manager | `micropc2.nix` | `~/.nix-profile/` |
| Hyprland (monitors, input, bindings, autostart, scripts) | Nix Home Manager | `micropc2.nix` | `~/.config/hypr/` (symlinked to repo) |
| Waybar (config, style) | Nix Home Manager | `micropc2.nix` | `~/.config/waybar/` (symlinked to repo) |
| Limine bootloader | Manual copy | — | `limine/boot/limine.conf` → `/boot/limine.conf` |

Hyprland configs and `.bashrc` use `mkOutOfStoreSymlink` — they symlink directly to the repo files and are live-editable without re-running `home-manager switch`. Run `home-manager switch` only when adding/removing managed files or changing packages.

---

## Auto-rotation (GPD MicroPC 2)

https://wiki.archlinux.org/title/GPD_MicroPC_2

https://wiki.archlinux.org/title/Tablet_PC#Screen_rotation

Requires `iio-sensor-proxy`:

```bash
sudo pacman -S iio-sensor-proxy
sudo systemctl enable --now iio-sensor-proxy
```

The `hypr` package includes `~/.config/hypr/scripts/auto-rotate.sh` which listens
for orientation changes via `monitor-sensor` and applies the correct Hyprland
display + touchscreen transform. It is started automatically on login via
`autostart.conf`.

Display: `DSI-1` (built-in, 270° rotation)
Touchscreen: `iltp7807:00-222a:fff1`
External display: `DP-1` (Viture, 1.5 scale)

### Middle-button Scroll (GPD MicroPC 2)

Vendored source: `drivers/gpd-micropc2-linux-scroll/`

```bash
cd ~/Development/dotfiles/drivers/gpd-micropc2-linux-scroll
./setup-middle-scroll.sh            # install
./setup-middle-scroll.sh --status   # status
./setup-middle-scroll.sh --reconfigure
./setup-middle-scroll.sh --remove
journalctl --user -u gpd-scroll -f  # logs
```

If you change `limine/etc/default/limine` (e.g. kernel rotation params), run
`sudo limine-update` so `/boot/limine.conf` and the UKI are regenerated.

`/boot` is typically an ESP (FAT), so it does not support symlinks. Keep a
tracked copy at `limine/boot/limine.conf` and sync it manually when needed:

```bash
sudo cp ~/Development/dotfiles/limine/boot/limine.conf /boot/limine.conf
```

---

## Daily Workflow

### Editing hypr configs or .bashrc

Edit directly in the repo — symlinks are live:

```bash
# e.g. edit monitors, bindings, input, autostart, scripts, .bashrc
$EDITOR ~/Development/dotfiles/hypr/.config/hypr/monitors.conf

# Commit as usual
cd ~/Development/dotfiles
git add -A
git commit -m "describe the change"
git push
```

Hyprland auto-reloads on save. After any hypr config change, validate:

```bash
hyprctl reload && hyprctl configerrors
```

Waybar does **not** auto-reload — run after waybar config/style changes:

```bash
omarchy restart waybar
```

### Adding/removing managed files or packages

Edit `common.nix` (shared) or `micropc2.nix` / `macbook.nix` (device-specific), then apply:

```bash
cd ~/Development/dotfiles
home-manager switch --flake .#micropc2
git add -A
git commit -m "describe the change"
git push
```

To roll back to a previous generation:

```bash
home-manager generations                        # list generations
home-manager switch --flake .#micropc2 --rollback   # go back one
```

---

## Recovering a Broken Omarchy Config

When using AI assistance for Omarchy config changes, review [The Omarchy Skill](https://learn.omacom.io/2/the-omarchy-manual/107/ai#the-omarchy-skill), and be ready to rollback changes or even invoking `omarchy-reinstall-configs, if the agent makes a mess of everything.`

If a Home Manager symlink conflicts with an Omarchy-managed file (e.g. after `omarchy update` overwrites a tracked file), restore it from Omarchy's template then re-run HM:

```bash
omarchy refresh config hypr/bindings.conf   # restore keybindings
omarchy refresh config hypr/monitors.conf   # restore monitor config
omarchy refresh config hypr/autostart.conf  # restore autostart
# or reset all hypr configs at once:
omarchy refresh hyprland
```

The pattern is `omarchy refresh config <relative-path-under-~/.config/>`. After
restoring, reload Hyprland:

```bash
hyprctl reload
```

---

## Bailing Out of a Change Cleanly

### Rolling back a Home Manager change

```bash
home-manager switch --flake .#micropc2 --rollback
```

Then revert the repo if needed:

```bash
git -C ~/Development/dotfiles checkout -- .
```

### Recovering from a bad hypr/bash edit

Since hypr configs and `.bashrc` are live symlinks into the repo, just revert the file in git:

```bash
git -C ~/Development/dotfiles checkout -- hypr/.config/hypr/monitors.conf
# Hyprland auto-reloads; validate:
hyprctl reload && hyprctl configerrors
```

### If Omarchy update overwrites a tracked file

`omarchy update` may overwrite files in `~/.config/hypr/`. Since HM uses `mkOutOfStoreSymlink`, the symlink itself survives but the target repo file may be replaced. Check with:

```bash
git -C ~/Development/dotfiles status
```

If Omarchy replaced a symlink with a regular file, restore:

```bash
home-manager switch --flake .#micropc2   # re-creates the symlink
git -C ~/Development/dotfiles diff   # review any content changes
```

### Check for broken symlinks

```bash
find ~/.config/hypr ~/.config/waybar ~/.local/bin -maxdepth 3 -xtype l 2>/dev/null
# For each broken link, restore via Omarchy:
omarchy refresh config hypr/bindings.conf
# ...etc
```

**Reload Hyprland after any recovery:**
```bash
hyprctl reload
```
