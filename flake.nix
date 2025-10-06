{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in {
        packages = {
          default = self.packages.${system}.pifi;
          inherit (pkgs) pifi pifi-portable-service;
        };
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bundix
            ruby
          ];
        };
      }
    ))
    // {
      overlays.default = final: prev: {
        pifi = final.callPackage ./default.nix {};
        pifi-portable-service = final.callPackage ./portable-service.nix {};
      };
      nixosModules.default = {
        pkgs,
        config,
        lib,
        ...
      }: {
        imports = [./nixos-module.nix];
        config = lib.mkIf config.services.pifi.enable {
          nixpkgs.overlays = [self.overlays.default];
          services.pifi.package = lib.mkDefault pkgs.pifi;
        };
      };
      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          ({
            pkgs,
            lib,
            ...
          }: {
            fileSystems."/" = {
              device = "/dev/sda1";
            };
            boot.loader.grub.enable = false;
            boot.initrd.enable = false;
            boot.kernel.enable = false;
            documentation.enable = false;
            services.pifi.enable = true;
            services.pifi.streams = {
              "BBC Radio 1" = "http://as-hls-ww-live.akamaized.net/pool_01505109/live/ww/bbc_radio_one/bbc_radio_one.isml/bbc_radio_one-audio%3d96000.norewind.m3u8";
              "BBC Radio 2" = "http://as-hls-ww-live.akamaized.net/pool_74208725/live/ww/bbc_radio_two/bbc_radio_two.isml/bbc_radio_two-audio%3d96000.norewind.m3u8";
              "BBC Radio 3" = "http://as-hls-ww-live.akamaized.net/pool_23461179/live/ww/bbc_radio_three/bbc_radio_three.isml/bbc_radio_three-audio%3d96000.norewind.m3u8";
              "BBC Radio 4" = "http://as-hls-ww-live.akamaized.net/pool_55057080/live/ww/bbc_radio_fourfm/bbc_radio_fourfm.isml/bbc_radio_fourfm-audio%3d96000.norewind.m3u8";
            };
            system.stateVersion = "23.05";
          })
        ];
      };
    };
}
