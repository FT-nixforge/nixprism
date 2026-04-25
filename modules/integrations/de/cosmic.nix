# ft-nixlaunch — COSMIC Desktop integration
#
# Wires ft-nixlaunch into COSMIC Desktop by writing a custom keybinding to
# the COSMIC shortcuts config file.
#
# COSMIC stores custom shortcuts in RON (Rust Object Notation) format at:
#   ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom
#
# NOTE: COSMIC is still in alpha; the shortcuts schema may change across
# releases.  This integration targets the alpha-era RON format.  If the
# written file is ignored, verify the format against your installed version
# in System Settings → Keyboard → Shortcuts → Custom.
#
# NOTE: Writing this file replaces the entire custom shortcuts list.  If you
# have other COSMIC custom shortcuts, manage them all through this option
# (via extraShortcuts) or disable the integration and configure them manually.
{ config, lib, ... }:

let
  cfg  = config.programs.ft-nixlaunch;
  ccfg = cfg.integrations.cosmic;

  # Build the RON entry for a single shortcut.
  # COSMIC modifier names: Super, Ctrl, Alt, Shift
  # COSMIC key names follow the XKB keysym names (e.g. "space", "Return").
  mkShortcut = { modifiers, key, command, description ? command }: ''
    (
            binding: (
                modifiers: [${lib.concatStringsSep ", " modifiers}],
                key: Key("${key}"),
            ),
            action: Spawn("${command}"),
            description: "${description}",
        )'';

  # All shortcuts to write: the launcher keybind + any user extras.
  allShortcuts =
    [ (mkShortcut {
        inherit (ccfg) modifiers key;
        command     = "ft-nixlaunch";
        description = "Launch ft-nixlaunch";
      })
    ]
    ++ map (s: mkShortcut s) ccfg.extraShortcuts;

  shortcutsFileText = ''
    // ft-nixlaunch: generated, do not edit
    [
        ${lib.concatStringsSep ",\n    " allShortcuts},
    ]
  '';

in
{
  # ── Options ───────────────────────────────────────────────────────────────
  options.programs.ft-nixlaunch.integrations.cosmic = {

    modifiers = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      default     = [ "Super" ];
      description = ''
        COSMIC modifier keys held when pressing the launcher keybind.
        Valid values: `"Super"`, `"Ctrl"`, `"Alt"`, `"Shift"`.
        Only used when `integrations.de = "COSMIC"`.
      '';
      example = [ "Super" "Shift" ];
    };

    key = lib.mkOption {
      type        = lib.types.str;
      default     = "space";
      description = ''
        COSMIC key name for the launcher keybind.
        Uses XKB keysym names (lowercase), e.g. `"space"`, `"Return"`, `"F1"`.
        Only used when `integrations.de = "COSMIC"`.
      '';
      example = "space";
    };

    extraShortcuts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          modifiers   = lib.mkOption { type = lib.types.listOf lib.types.str; };
          key         = lib.mkOption { type = lib.types.str; };
          command     = lib.mkOption { type = lib.types.str; };
          description = lib.mkOption { type = lib.types.str; default = ""; };
        };
      });
      default     = [];
      description = ''
        Additional custom COSMIC shortcuts to include in the generated file.
        Because the entire custom shortcuts file is replaced on each activation,
        any shortcuts you want to keep must be declared here alongside the
        ft-nixlaunch keybind.
      '';
      example = lib.literalExpression ''
        [
          {
            modifiers   = [ "Super" ];
            key         = "t";
            command     = "foot";
            description = "Launch terminal";
          }
        ]
      '';
    };
  };

  # ── Config ────────────────────────────────────────────────────────────────
  config = lib.mkIf (cfg.enable && cfg.integrations.de == "COSMIC") {
    # COSMIC custom shortcuts — RON format.
    # Path: ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom
    xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text =
      shortcutsFileText;
  };
}
