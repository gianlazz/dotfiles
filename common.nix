{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Development/dotfiles";
in
{
  # Explicitly allow unfree packages — add new ones here consciously
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
    "google-chrome"
    "sunvox"
    "stremio-linux-shell"
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Tmux — session persistence via resurrect + continuum
  # (see nix/tmux.nix for the programs.tmux module config)
  imports = [ ./nix/tmux.nix ];

  # nh — Nix helper (https://github.com/nix-community/nh)
  home.packages = with pkgs; [ nh ];

  home.sessionVariables = {
    NH_HOME_FLAKE = dotfiles;
  };

  # Git configuration
  home.file.".config/git/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/git/config";

  # Shell — direct symlink to repo (live-editable, tracked in git)
  home.file.".bashrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/bash/.bashrc";

  # Mise config — direct symlink to repo (live-editable, tracked in git)
  home.file.".config/mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/mise/config.toml";
}
