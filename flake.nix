# https://www.tweag.io/blog/2020-07-31-nixos-flakes/

# Now nixos-rebuild can use flakes:
# sudo nixos-rebuild switch --flake /etc/nixos

# To update flake.lock run:
# sudo nix flake update --commit-lock-file /etc/nixos

{
  inputs.nixpkgs.url = "github:patrickod/nixpkgs/personal";

  ## home manager
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  # agenix for secrets encryption
  inputs.agenix.url = "github:ryantm/agenix";

  outputs = inputs: {
    nixosConfigurations.prismo = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default

        ./machines/prismo.nix

        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixVersions.stable;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          nixpkgs.config = { allowUnfree = true; };

          home-manager.users.patrickod = { ... }: {
            nixpkgs.config = { allowUnfree = true; };
            imports = [ ./home-manager/prismo.nix ];
          };
        })
      ];
    };

    nixosConfigurations.finn = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager

        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixVersions.stable;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          nixpkgs.config = { allowUnfree = true; };
          home-manager.useGlobalPkgs = true;
        })

        ./machines/finn.nix
        ({ pkgs, ... }: {
          home-manager.users.patrickod = { pkgs, ... }: {
            imports = [ ./home-manager/finn.nix ];
          };
        })
      ];
    };

    nixosConfigurations.kimkilwhan = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager

        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixVersions.stable;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          nixpkgs.config = { allowUnfree = true; };
          home-manager.useGlobalPkgs = true;
        })

        ./machines/kimkilwhan.nix

        ({ pkgs, ... }: {
          home-manager.users.patrickod = { pkgs, ... }: {
            imports = [ ./home-manager/kimkilwhan.nix ];
          };
        })
      ];
    };
    homeConfigurations."patrickod@kimkilwhan" =
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home-manager/kimkilwhan.nix
          {
            home = {
              homeDirectory = "/home/patrickod";
              username = "patrickod";
            };
          }
          ({ config, lib, pkgs, ... }: {
            nixpkgs.config = { allowUnfree = true; };
            nixpkgs.overlays = [
              (self: super: {
                nix-direnv = super.nix-direnv.override { enableFlakes = true; };
              })
            ];
            imports = [ ./home-manager/kimkilwhan.nix ];
          })
        ];
      };
  };
}
