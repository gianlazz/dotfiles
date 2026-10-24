-- Extra autostart processes.

-- Auto-rotate the internal panel from the accelerometer (disabled for now).
-- Re-enable by uncommenting the line below.
-- o.launch_on_start("~/.config/hypr/scripts/auto-rotate.sh")

-- Move workspaces to an external monitor when one is connected.
o.launch_on_start("~/.config/hypr/scripts/workspace-follow-external.sh")

-- Note: monitor hotplug recovery is now handled by Omarchy v4's built-in
-- omarchy-hyprland-monitor-watch (already in the default autostart).
