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
    # anything else from https://search.nixos.org/packages
  ];

  # Protect Omarchy-managed directories
  home.file.".config/omarchy".enable = false;
  home.file.".config/alacritty".enable = false;
  home.file.".config/btop/themes".enable = false;

  # Hyprland config GPD MicroPC 2 — direct symlinks to repo (live-editable, tracked in git)
  home.file.".config/hypr/monitors.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/monitors.conf";
  home.file.".config/hypr/input.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/input.conf";
  home.file.".config/hypr/bindings.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/bindings.conf";
  home.file.".config/hypr/autostart.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/autostart.conf";
  home.file.".config/hypr/scripts/auto-rotate.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/scripts/auto-rotate.sh";
  home.file.".config/hypr/scripts/monitor-internal-toggle.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/scripts/monitor-internal-toggle.sh";
  home.file.".config/hypr/scripts/monitor-internal-mirror-toggle.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/scripts/monitor-internal-mirror-toggle.sh";
  home.file.".config/hypr/scripts/monitor-recover-watch.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/.config/hypr/scripts/monitor-recover-watch.sh";

  # Waybar config — direct symlinks to repo (live-editable, tracked in git)
  home.file.".config/waybar/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar/.config/waybar/config.jsonc";
  home.file.".config/waybar/style.css".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar/.config/waybar/style.css";
}
