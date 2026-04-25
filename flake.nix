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
      # ── Registry metadata (consumed by ft-nixpkgs) ───────────────────────
      meta = {
        name         = "ft-nixlaunch";
        type         = "module";
        role         = "standalone";
        description  = "Modern, polished Rofi application launcher for Wayland";
        repo         = "github:FT-nixforge/ft-nixlaunch";
        provides     = [ "packages" "homeModules" "overlays" ];
        dependencies = [ "ft-nixpalette" ];
        version      = "2.0.0";
      };

      # ── Package ──────────────────────────────────────────────────────────
      # src is passed explicitly so pkgs/default.nix doesn't need a relative
      # `../` path — it stays a clean, self-contained derivation file.
      packages = forAllSystems (system: rec {
        ft-nixlaunch = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/default.nix {
          src = ./.;
        };
        default = ft-nixlaunch;
      });

      # ── Home Manager module ──────────────────────────────────────────────
      # ft-nixlaunch is a Home Manager-only module; there is no NixOS module.
      # `homeModules` is the canonical name used across ft-nixpkgs.
      # ft-nixpkgs also accepts the legacy `homeManagerModules` alias.
      homeModules.default        = import ./modules/home.nix self;
      homeManagerModules.default = import ./modules/home.nix self; # legacy alias

      # ── Overlay ──────────────────────────────────────────────────────────
      # Exposes pkgs.ft-nixlaunch when the overlay is applied.
      overlays.default = final: _prev: {
        ft-nixlaunch = self.packages.${final.system}.default;
      };
    };
}
