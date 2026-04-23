# gianlazz/dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io). Supports multiple machines and operating systems from a single repo.

## Machines

| Machine | OS | Hostname | Status |
|---------|-----|----------|--------|
| GPD MicroPC | Omarchy Linux (Arch + Hyprland) | `micropc` | ✅ Active |
| MacBook | macOS | *(to be added)* | 🔜 Planned |

## Prerequisites

- [chezmoi](https://chezmoi.io/install/) installed
- A `~/.config/chezmoi/chezmoi.toml` created locally (see below — this file is **not** in the repo)

## Setup on a New Machine

### 1. Install chezmoi

**Arch / Omarchy Linux:**
```bash
sudo pacman -S chezmoi
```

**macOS:**
```bash
brew install chezmoi
```

### 2. Create the machine identity file

This file is **never committed** — it stays local and tells chezmoi which machine it's on.

Create `~/.config/chezmoi/chezmoi.toml` with values appropriate for the machine:

**Omarchy Linux (micropc):**
```toml
[data]
  machine = "micropc"
  os_type = "linux"
```

**macOS (when adding):**
```toml
[data]
  machine = "macbook"
  os_type = "darwin"
```

### 3. Apply dotfiles

```bash
chezmoi init --apply https://github.com/gianlazz/dotfiles.git
```

This clones the repo to `~/.local/share/chezmoi/` and applies all files appropriate for the current machine/OS.

---

## How It Works

### chezmoi source → live files

chezmoi maps files in `~/.local/share/chezmoi/` to their destinations using naming conventions:

| Source name | Destination |
|-------------|-------------|
| `dot_config/hypr/bindings.conf` | `~/.config/hypr/bindings.conf` |
| `dot_config/hypr/monitors.conf.tmpl` | `~/.config/hypr/monitors.conf` (rendered) |
| `dot_config/git/config` | `~/.config/git/config` |

### OS filtering (`.chezmoiignore`)

Linux-only configs (Hyprland, Waybar, Omarchy, etc.) are automatically skipped on macOS via `.chezmoiignore`.

### Machine-specific configs (templates)

Files ending in `.tmpl` are Go templates rendered using the `machine` and `os_type` values from `chezmoi.toml`.

Currently templated:
- `dot_config/hypr/monitors.conf.tmpl` — display config differs per machine

Example: when `machine = "micropc"`, the GPD's rotated DSI display config is inserted. On any other machine that block is omitted and only the commented examples remain.

To add macOS monitor config, add an `{{ else if eq .machine "macbook" }}` block to `monitors.conf.tmpl`.

---

## What's Tracked

### Shared (all machines)
| Path | Description |
|------|-------------|
| `dot_config/git/config` | Git aliases, defaults, diff settings |
| `dot_config/ghostty/config` | Ghostty terminal |
| `dot_config/alacritty/alacritty.toml` | Alacritty terminal |
| `dot_config/kitty/kitty.conf` | Kitty terminal |
| `dot_config/nvim/` | LazyVim config |
| `dot_config/starship.toml` | Shell prompt |
| `dot_config/tmux/tmux.conf` | Tmux |
| `dot_config/lazygit/` | Lazygit |
| `dot_config/btop/btop.conf` | btop system monitor |
| `dot_config/fastfetch/config.jsonc` | Fastfetch |

### Linux / Omarchy only (skipped on macOS)
| Path | Description |
|------|-------------|
| `dot_config/hypr/` | Hyprland WM — bindings, look & feel, idle, lock, autostart, monitor (templated), input |
| `dot_config/waybar/` | Status bar layout and styles |
| `dot_config/walker/` | App launcher |
| `dot_config/omarchy/hooks/` | Omarchy automation hooks |
| `dot_config/omarchy/themes/` | Custom themes (currently empty, ready for use) |

### What is NOT tracked
| Path | Reason |
|------|--------|
| `~/.config/mako/config` | Omarchy-managed symlink into `current/theme/` — recreated on theme change |
| `~/.config/omarchy/current/` | Omarchy runtime state (current theme, fonts) |
| `~/.config/omarchy/branding/` | Omarchy-managed |
| `~/.config/omarchy/themed/` | Omarchy-generated files |
| `~/.local/share/omarchy/` | Omarchy source — managed by `omarchy-update`, never edit |
| `~/.config/chezmoi/chezmoi.toml` | Machine identity — local only, never committed |

---

## Daily Workflow

### After changing a config file

```bash
# If the file is already tracked, chezmoi picks up the change automatically.
# Just commit:
chezmoi cd
git add -A
git commit -m "describe the change"
git push

# If it's a new file you want to start tracking:
chezmoi add ~/.config/some/new/file
chezmoi cd
git add -A && git commit -m "track new file" && git push
```

### Pulling changes on another machine

```bash
chezmoi update   # pulls from GitHub and applies in one step
```

### Checking what would change before applying

```bash
chezmoi diff
```

### Resetting a chezmoi-managed file to its source state

```bash
chezmoi apply ~/.config/hypr/bindings.conf
```

---

## Adding macOS Dotfiles

When setting up the MacBook:

1. Install chezmoi (`brew install chezmoi`)
2. Create `~/.config/chezmoi/chezmoi.toml` with `machine = "macbook"` and `os_type = "darwin"`
3. Run `chezmoi init --apply https://github.com/gianlazz/dotfiles.git`
4. Linux-only configs will be automatically skipped
5. Add any macOS-specific files (`chezmoi add ~/.zshrc` etc.), commit, push

To add machine-specific macOS blocks to existing templates (e.g. `monitors.conf.tmpl`):
```
{{ else if eq .machine "macbook" }}
monitor = eDP-1, preferred, auto, 2
```

---

## Omarchy-Specific Notes

Omarchy is an opinionated Arch Linux distro. Key rules:
- **Never edit** `~/.local/share/omarchy/` — it's managed by git and wiped on `omarchy-update`
- **Always edit** `~/.config/` — that's the safe user config layer
- After editing Hyprland configs, they **auto-reload** on save (no restart needed)
- After editing Waybar, run `omarchy-restart-waybar`
- To reset a config to Omarchy defaults: `omarchy-refresh-<app>` (creates a timestamped backup first)
- List all available Omarchy commands: `compgen -c | grep -E '^omarchy-' | sort -u`
