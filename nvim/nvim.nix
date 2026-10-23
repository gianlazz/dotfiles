{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Development/dotfiles";
in
{
  home.packages = with pkgs; [ neovim ];

  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";
}
