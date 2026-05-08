{
  description = "Home Manager configuration";

  inputs = {
    # Use nixpkgs-unstable for the latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, nix-homebrew, ... }:
    let
      linuxUser = "gian";
      darwinUser = "gian";
      linuxHome = "/home/${linuxUser}";
      darwinHome = "/Users/${darwinUser}";
      stateVersion = "25.11";
    in {

    # Linux (GPD MicroPC 2) — standalone Home Manager
    homeConfigurations.micropc2 = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ./common.nix
        ./micropc2.nix
        {
          home = {
            username = linuxUser;
            homeDirectory = linuxHome;
            inherit stateVersion;
          };
        }
      ];
    };

    # macOS (MacBook) — nix-darwin with Home Manager module
    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      specialArgs = { user = darwinUser; inherit stateVersion; homeDirectory = darwinHome; };
      modules = [
        ./macbook.nix
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = darwinUser;
          };
        }
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${darwinUser} = { imports = [ ./common.nix ]; };
          };
        }
      ];
    };

  };
}