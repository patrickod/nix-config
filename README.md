# nix-config

My personal NixOS host configuration.

### Instructions

1. git clone to /etc/nixos
2. create a new `hardware/$NAME.nix` file to describe your various hardware configurations
3. create a `machine/$NAME.nix` for each machine you wish to deploy
4. symlink the `configuration.nix` to machine configuration you wish to deploy
5. use `secrets.nix` for any credentials or sensitive values you definitely don't want to contribute to source code.

###  License

Provided under [Apache-2.0 License](LICENSE). 
