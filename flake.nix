{
  description = "Danilo's nix-darwin + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
    {
      darwinConfigurations."Danilos-MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit homebrew-core homebrew-cask homebrew-bundle; };
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          ./darwin.nix
          ./brew.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.daniloassis = import ./home.nix;
          }
        ];
      };
    };
}
