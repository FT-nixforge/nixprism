{
  description = "Prism — a modern, polished Rofi application launcher for Wayland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system: rec {
        prism = nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
        default = prism;
      });

      homeManagerModules.default = import ./module.nix self;

      overlays.default = final: _prev: {
        prism = self.packages.${final.system}.default;
      };
    };
}
