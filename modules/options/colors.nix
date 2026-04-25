# ft-nixlaunch — color options
#
# Declares all color-related user-facing options:
#   - nixpaletteIntegration / stylixIntegration  (theme auto-derivation)
#   - colors.*                                    (manual hex overrides)
#   - opacity                                     (background alpha)
#
# Color priority at evaluation time (highest → lowest):
#   1. nixpaletteIntegration or stylixIntegration → config.lib.stylix.colors
#   2. Manual colors.* values
#
# NOTE: ft-nixpalette is a NixOS-level module; it configures Stylix system-wide.
# Stylix then propagates config.lib.stylix.colors into every Home Manager user
# automatically. Both integration flags read from that same attribute path —
# choose the name that better communicates your intent.
{ lib, ... }:

{
  options.programs.ft-nixlaunch = {

    # ── Theme integration ───────────────────────────────────────────────────

    nixpaletteIntegration = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = ''
        Derive launcher colors from ft-nixpalette via Stylix.

        ft-nixpalette is a NixOS-level module that configures Stylix system-wide.
        Stylix exposes the active base16 palette in Home Manager through
        `config.lib.stylix.colors`. Enabling this option reads those colors
        automatically, so the launcher always matches your system theme.

        Requires `ft-nixpalette.enable = true` in your NixOS configuration
        (or `ft-nixpkgs.nixosModules.default` imported with ft-nixpalette enabled).

        Equivalent to `stylixIntegration = true` under the hood — use whichever
        name better reflects your setup.
      '';
    };

    stylixIntegration = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = ''
        Derive launcher colors from Stylix base16 scheme.

        Reads `config.lib.stylix.colors`. When you use ft-nixpalette, prefer
        `nixpaletteIntegration = true` for clarity — both flags activate the
        same color path.

        Requires Stylix to be enabled in your NixOS configuration.
      '';
    };

    # ── Manual color palette ────────────────────────────────────────────────
    # Ignored when nixpaletteIntegration or stylixIntegration is true and
    # Stylix colors are available.  Defaults to Catppuccin Mocha.

    colors = {
      background = lib.mkOption {
        type    = lib.types.str;
        default = "#1e1e2e";
        description = ''
          Primary background color (base00).
          Used for the main launcher window.
          Defaults to Catppuccin Mocha base00.
        '';
        example = "#1e1e2e";
      };

      backgroundAlt = lib.mkOption {
        type    = lib.types.str;
        default = "#313244";
        description = ''
          Secondary background color (base01).
          Used for the input bar and selected list items.
          Defaults to Catppuccin Mocha base01.
        '';
        example = "#313244";
      };

      foreground = lib.mkOption {
        type    = lib.types.str;
        default = "#cdd6f4";
        description = ''
          Primary text color (base05).
          Defaults to Catppuccin Mocha base05.
        '';
        example = "#cdd6f4";
      };

      foregroundAlt = lib.mkOption {
        type    = lib.types.str;
        default = "#a6adc8";
        description = ''
          Muted text color (base04).
          Used for placeholders, secondary labels, and inactive mode buttons.
          Defaults to Catppuccin Mocha base04.
        '';
        example = "#a6adc8";
      };

      accent = lib.mkOption {
        type    = lib.types.str;
        default = "#89b4fa";
        description = ''
          Accent color (base0D).
          Used for the prompt, active list items, and selected mode buttons.
          Defaults to Catppuccin Mocha base0D.
        '';
        example = "#89b4fa";
      };

      urgent = lib.mkOption {
        type    = lib.types.str;
        default = "#f38ba8";
        description = ''
          Urgent / error color (base08).
          Used for urgent list items.
          Defaults to Catppuccin Mocha base08.
        '';
        example = "#f38ba8";
      };
    };

    # ── Opacity ─────────────────────────────────────────────────────────────

    opacity = lib.mkOption {
      type    = lib.types.str;
      default = "dd";
      description = ''
        Two-digit hex alpha value appended to `background` and `backgroundAlt`.
        Controls how transparent the launcher window is.

        `"00"` → fully transparent
        `"ff"` → fully opaque
        `"dd"` → ~87 % opaque (default)

        Only affects background colors; text and accent colors are always fully opaque.
        Requires a compositor with real transparency support (e.g. Hyprland, Sway).
      '';
      example = "cc";
    };
  };
}
