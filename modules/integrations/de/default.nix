# ft-nixlaunch — DE integration entry point
#
# Declares the `programs.ft-nixlaunch.integrations.de` option and imports
# every per-DE module.  Each DE module is responsible for:
#   - Declaring its own sub-options under
#     `programs.ft-nixlaunch.integrations.<de>.*`
#   - Adding its HM config, gated on
#     `cfg.enable && cfg.integrations.de == "<DE>"`
#
# Supported desktop environments / compositors:
#   "Hyprland"  — keybind + blur layer rules
#   "Niri"      — keybind via programs.niri.settings.binds
#   "GNOME"     — keybind via dconf custom-keybindings
#   "KDE"       — keybind via home.activation + kwriteconfig6
#   "COSMIC"    — keybind via COSMIC shortcuts config file
#   "MangoWC"   — keybind via MangoWC compositor config
{ lib, ... }:

{
  options.programs.ft-nixlaunch.integrations.de = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [
      "Hyprland"
      "Niri"
      "GNOME"
      "KDE"
      "COSMIC"
      "MangoWC"
    ]);
    default     = null;
    description = ''
      Desktop environment or compositor to wire ft-nixlaunch into.

      When set, the corresponding integration module automatically adds a
      keybinding to launch ft-nixlaunch and any compositor-specific rules
      (e.g. blur layer rules for Hyprland).

      Configure the keybind for your chosen DE under
      `programs.ft-nixlaunch.integrations.<de>.keybind`.

      Set to `null` (the default) to skip all DE-level integration and
      manage your keybinding manually.

      Supported values:
        "Hyprland" — Hyprland compositor keybind + blur layer rules
        "Niri"     — Niri compositor keybind
        "GNOME"    — GNOME Shell custom keybind via dconf
        "KDE"      — KDE Plasma global shortcut via kwriteconfig6
        "COSMIC"   — COSMIC Desktop keybind via shortcuts config
        "MangoWC"  — MangoWC compositor keybind
    '';
    example = "Hyprland";
  };

  imports = [
    ./hyprland.nix
    ./niri.nix
    ./gnome.nix
    ./kde.nix
    ./cosmic.nix
    ./mangowc.nix
  ];
}
