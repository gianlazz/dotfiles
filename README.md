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
| `limine` | `/etc/default/limine` | Limine bootloader defaults for the Omarchy install |

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

For packages that target system paths instead of your home directory, mirror the
target path inside the package and stow against `/`:

```bash
mkdir -p limine/etc/default
sudo stow --adopt -t / limine   # for an existing target file
# or move the file aside first, then run: stow -t / limine
stow -t / limine
```

Remove a package (unlinks symlinks, does not delete live files):

```bash
stow -D -t ~ newpkg
```

---

## Recovering a Broken Omarchy Config

When using AI assistance for Omarchy config changes, review [The Omarchy Skill](https://learn.omacom.io/2/the-omarchy-manual/107/ai#the-omarchy-skill), and be ready to rollback changes or even invoking `omarchy-reinstall-configs, if the agent makes a mess of everything.`

If a stow symlink breaks an Omarchy-managed file (e.g. after reverting a dotfiles
change), restore it from Omarchy's template:

```bash
omarchy-refresh-config hypr/bindings.conf   # restore keybindings
omarchy-refresh-config hypr/monitors.conf   # restore monitor config
omarchy-refresh-config hypr/autostart.conf  # restore autostart
```

The pattern is `omarchy-refresh-config <relative-path-under-~/.config/>`. After
restoring, reload Hyprland:

```bash
hyprctl reload
```

---

## Bailing Out of a Change Cleanly

Reverting git changes alone is **not enough** — stow symlinks in `~` still point
at the (now-deleted or reverted) files in the repo, leaving broken links.

Full bail-out procedure:

**Step 1 — Unstow the affected packages first** (removes symlinks):
```bash
stow -d ~/Development/dotfiles -t ~ -D hypr waybar bin bash git
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
stow -d ~/Development/dotfiles -t ~ hypr waybar bash git
```

**Step 4 — Restore any Omarchy-managed files** that were overridden and are now
missing (check for broken symlinks first):
```bash
find ~/.config/hypr ~/.config/waybar ~/.local/bin -maxdepth 3 -xtype l 2>/dev/null
# For each broken link, restore via Omarchy:
omarchy-refresh-config hypr/bindings.conf
# ...etc
```

**Step 5 — Reload Hyprland:**
```bash
hyprctl reload
```
