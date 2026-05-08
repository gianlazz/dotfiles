{ config, pkgs, ... }:

{
  # macOS-specific packages
  home.packages = with pkgs; [
    # anything else from https://search.nixos.org/packages
  ];
}
