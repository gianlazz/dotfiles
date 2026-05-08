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
      # "visual-studio-code"
      # "arc"
    ];
    brews = [
      # "someformula"
    ];
  };

  system.stateVersion = 6;
}
