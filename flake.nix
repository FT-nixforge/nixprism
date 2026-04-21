{
  description = "ft-nixlaunch — a modern, polished Rofi application launcher for Wayland";

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
      meta = {
        name = "ft-nixlaunch";
        type = "module";
        role = "standalone";
        description = "Modern, polished Rofi application launcher for NixOS and Wayland";
        repo = "github:FT-nixforge/ft-nixlaunch";
        provides = [ "packages" "homeModules" "overlays" ];
        dependencies = [ "nixpalette" ];
        status = "stable";
        version = "0.1.0";
      };

      packages = forAllSystems (system: rec {
        ft-nixlaunch = nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
        default = ft-nixlaunch;
      });

      homeManagerModules.default = import ./module.nix self;

      overlays.default = final: _prev: {
        ft-nixlaunch = self.packages.${final.system}.default;
      };
    };
}
