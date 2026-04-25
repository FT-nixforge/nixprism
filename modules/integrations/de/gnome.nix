# ft-nixlaunch — GNOME Desktop integration
#
# Registers ft-nixlaunch as a custom GNOME keybinding via dconf.
# Uses GNOME's custom-keybindings mechanism under:
#   org.gnome.settings-daemon.plugins.media-keys.custom-keybindings
#
# Keybind format: GNOME accelerator string
#   Examples: "<Super>space", "<Control><Alt>t", "<Super>r"
#
# NOTE: If you already declare custom GNOME keybindings elsewhere in your
# Home Manager config, set `integrations.gnome.manageBindingsList = false`
# and add the binding path to your own custom-keybindings list manually:
#
#   dconf.settings."org/gnome/settings-daemon/plugins/media-keys" = {
#     custom-keybindings = [
#       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ft-nixlaunch/"
#       # … your other bindings …
#     ];
#   };
{ config, lib, ... }:

let
  cfg  = config.programs.ft-nixlaunch;
  gCfg = cfg.integrations.gnome;

  bindingPath =
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ft-nixlaunch/";
in
{
  options.programs.ft-nixlaunch.integrations.gnome = {

    keybind = lib.mkOption {
      type    = lib.types.str;
      default = "<Super>space";
      description = ''
        GNOME accelerator string used to open ft-nixlaunch.

        Uses GNOME's keybinding format:
          "<Super>space"      → Super + Space
          "<Control><Alt>t"   → Ctrl + Alt + T
          "<Super>r"          → Super + R

        The binding is registered as a custom shortcut under
        org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.
      '';
      example = "<Super>r";
    };

    manageBindingsList = lib.mkOption {
      type    = lib.types.bool;
      default = true;
      description = ''
        Whether ft-nixlaunch should write the `custom-keybindings` list entry
        in dconf itself.

        When `true` (default), the module sets:
          org.gnome.settings-daemon.plugins.media-keys.custom-keybindings
            = [ "…/ft-nixlaunch/" ]

        This REPLACES any existing value at that dconf key.  If you already
        manage custom GNOME keybindings in your Home Manager config, set this
        to `false` and add the ft-nixlaunch path to your own list manually
        (see the comment at the top of this file).
      '';
    };

  };

  config = lib.mkIf (cfg.enable && cfg.integrations.de == "GNOME") (lib.mkMerge [

    # ── Keybinding definition ──────────────────────────────────────────────
    {
      dconf.settings = {
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ft-nixlaunch" = {
          binding = gCfg.keybind;
          command  = "ft-nixlaunch";
          name     = "ft-nixlaunch";
        };
      };
    }

    # ── Register path in the custom-keybindings list ───────────────────────
    (lib.mkIf gCfg.manageBindingsList {
      dconf.settings = {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [ bindingPath ];
        };
      };
    })

  ]);
}
