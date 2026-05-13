{ pkgs, user, homeDirectory, stateVersion, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Touch ID for sudo
  security.pam.enableSudoTouchIdAuth = true;

  # User definition required by nix-darwin
  users.users.${user} = {
    name = user;
    home = homeDirectory;
  };

  # macOS-specific packages (in addition to common.nix)
  home-manager.users.${user} = { pkgs, ... }: {
    home.packages = with pkgs; [
      bitwarden-desktop
      tailscale
      google-chrome
      vscode
      transmission_4
      sunvox
      asciinema
      # anything else from https://search.nixos.org/packages
    ];
    home.stateVersion = stateVersion;
  };

  # Homebrew — managed declaratively via nix-homebrew
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap"; # remove unlisted casks/brews on switch
    casks = [
      nextcloud
      bambu-studio
      nextcloud-talk
      # "arc"
    ];
    brews = [
      # "someformula"
    ];
  };

  system.stateVersion = 6;
}
