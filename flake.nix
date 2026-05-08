{
  description = "Home Manager configuration";

  inputs = {
    # Use nixpkgs-unstable for the latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # This ensures home-manager uses the same nixpkgs version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Define user configurations for different devices
      userConfigs = {
        micropc2 = {
          username = "gian";
          homeDirectory = "/home/gian";
          system = "x86_64-linux";
          modules = [ ./common.nix ./micropc2.nix ];
        };
        macbook = {
          username = "gian";
          homeDirectory = "/Users/gian";
          system = "aarch64-darwin";
          modules = [ ./common.nix ./macbook.nix ];
        };
      };

      mkHomeConfig = name: cfg:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${cfg.system};
          modules = cfg.modules ++ [
            {
              home = {
                inherit (cfg) username homeDirectory;
                stateVersion = "24.11";
              };
            }
          ];
        };
    in {
      homeConfigurations = builtins.mapAttrs mkHomeConfig userConfigs;
    };
}