-- Personal keybinding overrides (loaded after Omarchy defaults).

-- Rebind SUPER+SHIFT+SLASH from 1Password to Bitwarden.
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden" })

-- Rebind SUPER+SHIFT+A from ChatGPT to Claude.
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai" })

-- Rebind SUPER+SHIFT+P from Google Photos to HyprMode display switcher.
hl.unbind("SUPER + SHIFT + P")
o.bind("SUPER + SHIFT + P", "Display switcher", "alacritty --class hyprmode -e hyprmode")
o.window("^(hyprmode)$", { float = true, center = true, size = "597 530", opacity = "0.95" })

-- Note: laptop display toggle (SUPER+CTRL+Delete) and mirror (SUPER+CTRL+ALT+Delete)
-- now use Omarchy v4's built-in commands, which detect DSI/eDP/LVDS panels the same
-- way the old user-owned scripts did. No override needed here.
