# https://www.tweag.io/blog/2020-07-31-nixos-flakes/

# Now nixos-rebuild can use flakes:
# sudo nixos-rebuild switch --flake /etc/nixos

# To update flake.lock run:
# sudo nix flake update --commit-lock-file /etc/nixos

{
  inputs.nixpkgs.url = "github:patrickod/nixpkgs/personal";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs: {

    nixosConfigurations.prismo = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager

        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (self: super: {
              nix-direnv = super.nix-direnv.override { enableFlakes = true; };
            })
          ];
        })

        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixFlakes;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          home-manager.useGlobalPkgs = true;
        })

        ./machines/prismo.nix
      ];
    };

    nixosConfigurations.finn = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager

        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (self: super: {
              nix-direnv = super.nix-direnv.override { enableFlakes = true; };
            })
          ];
        })

        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixFlakes;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          home-manager.useGlobalPkgs = true;
        })

        ./machines/finn.nix
      ];
    };

    homeConfigurations = {
      "patrickod@kimkilwhan" = inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        homeDirectory = "/home/patrickod";
        username = "patrickod";
        stateVersion = "21.11";
        configuration = { config, lib, pkgs, ... }: {
          nixpkgs.config = { allowUnfree = true; };
          imports = [ ./home-manager/kimkilwhan.nix ];
        };
      };
    };
  };
}
