{ config, pkgs, ... }:

let
dotfiles = "${config.home.homeDirectory}/Development/dotfiles";
in
{
# Needed for non NixOS linux distro
  targets.genericLinux.enable = true;

# Essential packages
  home.packages = with pkgs; [
    bitwarden-desktop
# tailscale # Comes from Omarchy
# chromium # Comes from Omarchy
# vscode # Comes from Omarchy
      nextcloud-client
      nextcloud-talk-desktop
      transmission_4
      bambu-studio
      sunvox
      asciinema
      popcorntime
# stremio-linux-shell # Buggy, just use web.stremio.com
# mpvpaper # Kills battery
# anything else from https://search.nixos.org/packages
  ];

# Protect Omarchy-managed directories
  home.file.".config/omarchy".enable = false;
  home.file.".config/alacritty".enable = false;
  home.file.".config/btop/themes".enable = false;

# Hyprland config GPD MicroPC 2 — direct symlinks to repo (live-editable, tracked in git)
  home.file.".config/hypr/monitors.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/monitors.lua";
  home.file.".config/hypr/input.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/input.lua";
  home.file.".config/hypr/bindings.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/bindings.lua";
  home.file.".config/hypr/looknfeel.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/looknfeel.lua";
  home.file.".config/hypr/autostart.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/autostart.lua";

  home.file.".config/hypr/scripts/auto-rotate.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/scripts/auto-rotate.sh";
  home.file.".config/hypr/scripts/workspace-follow-external.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/scripts/workspace-follow-external.sh";

# Waybar config — direct symlinks to repo (live-editable, tracked in git)
  home.file.".config/waybar/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar/config.jsonc";
  home.file.".config/waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar/style.css";

# Neo Gotham omarchy theme — direct symlinks to repo (live-editable, tracked in git)
  home.file.".config/omarchy/themes/neo-gotham".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/themes/neo-gotham";

# VSCode Neo Gotham theme extension — direct symlink to repo
  home.file.".vscode/extensions/local.neo-gotham-1.0.0".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/themes/neo-gotham/vscode-extension";
}
