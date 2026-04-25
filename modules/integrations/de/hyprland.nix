# ft-nixlaunch — Hyprland DE integration
#
# Adds a keybinding and compositor layer rules when
# `programs.ft-nixlaunch.integrations.de = "Hyprland"`.
#
# Keybind format: "MODIFIER, key"
#   e.g.  "SUPER, space"
#         "SUPER SHIFT, space"
#
# Requires the Hyprland Home Manager module to be imported and
# `wayland.windowManager.hyprland.enable = true` in your config.
{ config, lib, ... }:

let
  cfg  = config.programs.ft-nixlaunch;
  hCfg = cfg.integrations.hyprland;
in
{
  options.programs.ft-nixlaunch.integrations.hyprland = {

    keybind = lib.mkOption {
      type        = lib.types.str;
      default     = "SUPER, space";
      description = ''
        Hyprland keybinding used to open ft-nixlaunch.
        Format: "MODIFIER, key"  (Hyprland bind syntax).

        Examples:
          "SUPER, space"
          "SUPER SHIFT, F1"
          "ALT, F2"
      '';
      example = "SUPER, space";
    };

    blurLayerRules = lib.mkOption {
      type        = lib.types.bool;
      default     = true;
      description = ''
        Add Hyprland layer rules that enable blur and alpha-pass-through
        for the Rofi surface:

          layerrule = blur, rofi
          layerrule = ignorezero, rofi

        These rules give the launcher its frosted-glass appearance.
        Disable if you manage layer rules manually or use a different
        blur setup.
      '';
    };

    dimAround = lib.mkOption {
      type        = lib.types.bool;
      default     = false;
      description = ''
        Add a `layerrule = dimaround, rofi` rule that dims everything
        behind the launcher while it is open — a Spotlight-style effect.
        Disabled by default.
      '';
    };

  };

  config = lib.mkIf (cfg.enable && cfg.integrations.de == "Hyprland") {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "${hCfg.keybind}, exec, ft-nixlaunch"
      ];

      layerrule =
        lib.optionals hCfg.blurLayerRules [
          "blur, rofi"
          "ignorezero, rofi"
        ]
        ++ lib.optionals hCfg.dimAround [
          "dimaround, rofi"
        ];
    };
  };
}
