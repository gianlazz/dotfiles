# gianlazz/dotfiles

Personal dotfiles managed with [Nix Home Manager](https://nix-community.github.io/home-manager/) + [GNU Stow](https://www.gnu.org/software/stow/) (for Omarchy-adjacent configs).

[Omarchy + Nix Home Manager Integration](https://github.com/basecamp/omarchy/discussions/987)

## Machines

| Machine | OS | Branch |
|---------|-----|--------|
| GPD MicroPC 2 | Omarchy Linux (Arch + Hyprland) | `nix-hm` |
| GPD MicroPC (gen 1) / MacBook | Legacy chezmoi setup | `main` |

---

## Prerequisites

```bash
# Nix (multi-user daemon mode recommended)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (after install, before first use)
mkdir -p ~/.config/nix
echo "experimental-features = nix-flakes nix-command" >> ~/.config/nix/nix.conf

# Stow (for hypr/bash/limine packages)
sudo pacman -S stow
```

---

## Setup on a New Machine

```bash
git clone https://github.com/gianlazz/dotfiles.git ~/Development/dotfiles
cd ~/Development/dotfiles
git checkout nix-hm
```

Apply Nix Home Manager (manages git config + packages):

```bash
nix run home-manager -- switch --flake .#main
```

Apply Stow packages (manages Hyprland config, bash, limine):

```bash
stow -t ~ hypr    # Hyprland config + auto-rotate scripts
stow -t ~ bash    # .bashrc (nvm, omarchy base)
stow -t / limine  # Limine bootloader defaults (system path)
```

Log out and back in so Nix-installed apps appear in the launcher.

---

## What Manages What

| Config | Tool | Location |
|--------|------|----------|
| git config, aliases | Nix Home Manager | `home.nix` → `~/.config/git/config` |
| Packages (nextcloud, bitwarden) | Nix Home Manager | `home.nix` → `~/.nix-profile/` |
| Hyprland (monitors, input, bindings, autostart, scripts) | Stow | `hypr/` → `~/.config/hypr/` |
| bash / .bashrc | Stow | `bash/` → `~/.bashrc` |
| Limine bootloader | Stow | `limine/` → `/etc/default/limine` |

### Updating Home Manager config

Edit `home.nix`, then apply:

```bash
home-manager switch --flake .#main
```

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

### Nix Home Manager changes (packages, git config)

Edit `home.nix`, then apply:

```bash
cd ~/Development/dotfiles
home-manager switch --flake .#main
git add -A
git commit -m "describe the change"
git push
```

To roll back Home Manager to the previous generation:

```bash
home-manager generations              # list generations
home-manager switch --flake .#main --rollback
```

### Stow changes (hypr scripts, bash, limine)

Edit files directly — they are symlinks into the repo:

```bash
# After making changes:
cd ~/Development/dotfiles
git add -A
git commit -m "describe the change"
git push
```

Add a new Stow package targeting system paths:

```bash
mkdir -p limine/etc/default
sudo stow --adopt -t / limine   # for an existing target file
# or move the file aside first, then run: stow -t / limine
stow -t / limine
```

Remove a Stow package (unlinks symlinks, does not delete live files):

```bash
stow -D -t ~ hypr
```

---

## Recovering a Broken Omarchy Config

When using AI assistance for Omarchy config changes, review [The Omarchy Skill](https://learn.omacom.io/2/the-omarchy-manual/107/ai#the-omarchy-skill), and be ready to rollback changes or even invoking `omarchy-reinstall-configs, if the agent makes a mess of everything.`

If a stow symlink breaks an Omarchy-managed file (e.g. after reverting a dotfiles
change), restore it from Omarchy's template:

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
home-manager switch --flake .#main --rollback
```

If git config is now wrong, re-run switch with the correct `home.nix`.

### Rolling back a Stow change

Reverting git changes alone is **not enough** — stow symlinks in `~` still point
at the (now-deleted or reverted) files in the repo, leaving broken links.

**Step 1 — Unstow the affected packages first** (removes symlinks):
```bash
stow -d ~/Development/dotfiles -t ~ -D hypr bash
```

**Step 2 — Revert the repo** (undo uncommitted changes or reset to a commit):
```bash
# Discard all uncommitted changes:
git -C ~/Development/dotfiles checkout -- .
git -C ~/Development/dotfiles clean -fd

# Or reset to a specific commit:
git -C ~/Development/dotfiles reset --hard <commit>
```

**Step 3 — Re-stow** the packages you still want:
```bash
stow -d ~/Development/dotfiles -t ~ hypr bash
```

**Step 4 — Restore any Omarchy-managed files** that were overridden and are now
missing (check for broken symlinks first):
```bash
find ~/.config/hypr ~/.config/waybar ~/.local/bin -maxdepth 3 -xtype l 2>/dev/null
# For each broken link, restore via Omarchy:
omarchy refresh config hypr/bindings.conf
# ...etc
```

**Step 5 — Reload Hyprland:**
```bash
hyprctl reload
```
