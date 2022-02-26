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

  ## sops-nix for secrets encryption
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs: {
    nixosConfigurations.prismo = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops

        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixFlakes;
          nixpkgs.config = { allowUnfree = true; };
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
        })

        ./machines/prismo.nix

        ({pkgs, ... }: {
          home-manager.users.patrickod = { pkgs, ... }: {
            nixpkgs.config = { allowUnfree = true; };
            imports = [./home-manager/prismo.nix];
          };
        })
      ];
    };

    nixosConfigurations.finn = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops

        ({ pkgs, ... }: {
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = pkgs.nixFlakes;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          nixpkgs.config = { allowUnfree = true; };
          home-manager.useGlobalPkgs = true;
        })

        ./machines/finn.nix
        ({pkgs, ... }: {
          home-manager.users.patrickod = { pkgs, ... }: {
            imports = [./home-manager/finn.nix];
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
          nix.package = pkgs.nixFlakes;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          nixpkgs.config = { allowUnfree = true; };
          home-manager.useGlobalPkgs = true;
        })

        ./machines/kimkilwhan.nix

        ({pkgs, ... }: {
          home-manager.users.patrickod = { pkgs, ... }: {
            imports = [./home-manager/kimkilwhan.nix];
          };
        })
      ];
    };

    homeConfigurations = {
      "patrickod@kimkilwhan" =
        inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/patrickod";
          username = "patrickod";
          stateVersion = "21.11";
          configuration = { config, lib, pkgs, ... }: {
            nixpkgs.config = { allowUnfree = true; };
            nixpkgs.overlays = [
              (self: super: {
                nix-direnv = super.nix-direnv.override { enableFlakes = true; };
              })
            ];
            imports = [ ./home-manager/kimkilwhan.nix ];
          };
        };
    };
  };
}
