{ config, pkgs, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Development/dotfiles";
in
{
  # Essential packages
  home.packages = with pkgs; [
    nextcloud-client
    bitwarden-desktop
    # anything else from https://search.nixos.org/packages
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Gian Lazzarini";
      user.email = "1166579+gianlazz@users.noreply.github.com";
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
      };
      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
      };
      commit.verbose = true;
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "-version:refname";
      rerere = {
        enabled = true;
        autoupdate = true;
      };
    };
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;

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

  # Shell
  home.file.".bashrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/bash/.bashrc";
}