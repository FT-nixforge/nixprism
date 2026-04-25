# ft-nixlaunch — Niri DE integration
#
# Adds a keybinding to launch ft-nixlaunch via the Niri compositor's native
# bind system (programs.niri.settings.binds).
#
# Activate with:
#   programs.ft-nixlaunch.integrations.de = "Niri";
#
# The default keybind is "Mod+Space". Override with:
#   programs.ft-nixlaunch.integrations.niri.keybind = "Mod+D";
#
# Niri keybind format: "<Modifier>+<Key>"
#   Mod   → Super / Win key
#   Ctrl  → Control
#   Alt   → Alt
#   Shift → Shift
#   Key names follow xkbcommon conventions (e.g. "space", "d", "F2")
#
# Requires the Niri Home Manager module to be imported and configured
# (e.g. via programs.niri.enable = true or the niri flake).
{ config, lib, ... }:

let
  cfg  = config.programs.ft-nixlaunch;
  nCfg = cfg.integrations.niri;
in

{
  options.programs.ft-nixlaunch.integrations.niri = {

    keybind = lib.mkOption {
      type        = lib.types.str;
      default     = "Mod+Space";
      description = ''
        Niri keybind used to open ft-nixlaunch.

        Format: `"<Modifier>+<Key>"` — xkbcommon key names, modifiers joined with `+`.

        Examples:
          "Mod+Space"    Super + Space  (default)
          "Mod+D"        Super + D
          "Ctrl+Space"   Ctrl  + Space
      '';
      example = "Mod+D";
    };

    cooldownMs = lib.mkOption {
      type        = lib.types.int;
      default     = 0;
      description = ''
        Cooldown in milliseconds before the keybind can fire again.
        Set to a positive value to prevent accidental double-launches when
        the launcher closes quickly (e.g. pressing Escape).
        `0` disables the cooldown (Niri default).
      '';
      example = 250;
    };

  };

  # ── Niri config ─────────────────────────────────────────────────────────────
  config = lib.mkIf (cfg.enable && cfg.integrations.de == "Niri") {
    programs.niri.settings.binds = lib.mkMerge [
      {
        # Spawn ft-nixlaunch when the keybind is pressed.
        # programs.niri.settings.binds.<key>.action.spawn accepts a list of
        # strings (program + optional arguments).
        ${nCfg.keybind}.action.spawn = [ "ft-nixlaunch" ];
      }

      # Optional cooldown — only emit when the user explicitly set one.
      (lib.mkIf (nCfg.cooldownMs > 0) {
        ${nCfg.keybind}.cooldown-ms = nCfg.cooldownMs;
      })
    ];
  };
}
