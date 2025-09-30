{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs =
    { self, nixpkgs, flake-utils, ... }:
    (flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages.pifi = pkgs.callPackage ./default.nix { };
          packages.default = self.packages.${system}.pifi;
          formatter = pkgs.nixpkgs-fmt;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              bundix
              ruby
            ];
          };
          overlays.default = final: prev: {
            inherit (self.packages.${system}) pifi;
          };
          nixosModules.default = { pkgs, config, lib, ... }: {
            imports = [ ./nixos-module.nix ];
            config = lib.mkIf config.services.pifi.enable {
              nixpkgs.overlays = [ self.overlays.${system}.default ];
              services.pifi.package = lib.mkDefault pkgs.pifi;
            };
          };
        }
      )) // {
      nixosConfigurations.test =
        let system = "x86_64-linux";
        in nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.${system}.default
            ({ pkgs, lib, ... }: {
              fileSystems."/" = {
                device = "/dev/sda1";
              };
              boot.loader.grub.enable = false;
              boot.initrd.enable = false;
              boot.kernel.enable = false;
              documentation.enable = false;
              services.pifi.enable = true;
              system.stateVersion = "23.05";
            })
          ];
        };
    };
}
