{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Development/dotfiles";
in
{
  # Let Home Manager manage itself
  programs.home-manager.enable = true;

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

  # Shell — direct symlink to repo (live-editable, tracked in git)
  home.file.".bashrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/bash/.bashrc";

  # Mise config — direct symlink to repo (live-editable, tracked in git)
  home.file.".config/mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/mise/.config/mise/config.toml";
}
