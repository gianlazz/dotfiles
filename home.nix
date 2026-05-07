{ config, pkgs, lib, ... }:

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
}