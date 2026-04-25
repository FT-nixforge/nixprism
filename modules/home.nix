# ft-nixlaunch — Home Manager module entry point
#
# This file is the single import target exposed by the flake:
#
#   homeModules.default = import ./modules/home.nix self;
#
# It does two things only:
#   1. Injects the flake's `self` output into the module system as
#      `ft-nixlaunchSelf`, so the package derivation sub-module can
#      reference the correct store path without a separate input.
#   2. Imports every sub-module that together make up the full
#      `programs.ft-nixlaunch` interface.
#
# Nothing else belongs here — options and config live in their
# respective sub-modules under options/, config/, and integrations/.
self:
{ ... }:

{
  # Make the flake self available to all sub-modules as a named module arg.
  # Sub-modules that need the package reference declare it as:
  #   { config, lib, pkgs, ft-nixlaunchSelf, ... }:
  _module.args.ft-nixlaunchSelf = self;

  imports = [
    # ── Options ──────────────────────────────────────────────────────────
    ./options/behavior.nix   # enable, searchEngine, browser, terminal, extraConfig
    ./options/colors.nix     # nixpaletteIntegration, stylixIntegration, colors.*, opacity
    ./options/font.nix       # font.name, font.size
    ./options/window.nix     # window.*, iconSize, maxResults, padding, spacing

    # ── Config ───────────────────────────────────────────────────────────
    ./config/base.nix        # home.packages — installs the ft-nixlaunch package
    ./config/theme.nix       # color resolution, rasi theme, xdg files, session vars

    # ── DE integrations ───────────────────────────────────────────────────
    ./integrations/de/default.nix
  ];
}
