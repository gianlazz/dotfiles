# gianlazz/dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Machines

| Machine | OS | Branch |
|---------|-----|--------|
| GPD MicroPC 2 | Omarchy Linux (Arch + Hyprland) | `stow` |
| GPD MicroPC (gen 1) / MacBook | Legacy chezmoi setup | `main` |

---

## Prerequisites

```bash
sudo pacman -S stow   # Arch / Omarchy Linux
```

---

## Setup on a New Machine

```bash
git clone https://github.com/gianlazz/dotfiles.git ~/Development/dotfiles
cd ~/Development/dotfiles
git checkout stow
```

Apply the packages you want:

```bash
stow -t ~ hypr    # Hyprland config + auto-rotate
stow -t ~ bash    # .bashrc (nvm, omarchy base)
stow -t ~ git     # git config, aliases
```

Or apply all at once:

```bash
stow -t ~ hypr bash git
```

---

## Packages

| Package | Symlinks | Description |
|---------|----------|-------------|
| `hypr` | `~/.config/hypr/` | Hyprland monitor config, autostart, auto-rotate script |
| `bash` | `~/.bashrc` | Omarchy base shell + nvm + auto-switch node |
| `git` | `~/.config/git/config` | Git identity, aliases, rebase pull, histogram diff |

---

## Auto-rotation (GPD MicroPC 2)

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

---

## Daily Workflow

Edit any tracked file directly (they are symlinks into the repo):

```bash
# After making changes:
cd ~/Development/dotfiles
git add -A
git commit -m "describe the change"
git push
```

Add a new package:

```bash
mkdir -p newpkg/.config/newpkg
# ... add files ...
stow -t ~ newpkg
git add -A && git commit -m "add newpkg stow package"
```

Remove a package (unlinks symlinks, does not delete live files):

```bash
stow -D -t ~ newpkg
```
