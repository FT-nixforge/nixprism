# Window geometry and layout options for ft-nixlaunch.
# Covers the launcher window dimensions, item sizing, and internal spacing.
{ lib, ... }:

{
  options.programs.ft-nixlaunch = {

    # ── Window ─────────────────────────────────────────────────────────────
    window = {
      width = lib.mkOption {
        type        = lib.types.int;
        default     = 680;
        description = ''
          Launcher window width in pixels.
          The window is always centered on screen regardless of this value.
        '';
        example = 800;
      };

      borderRadius = lib.mkOption {
        type        = lib.types.int;
        default     = 20;
        description = ''
          Corner radius of the launcher window in pixels.
          Inner elements (input bar, list items, mode buttons) are automatically
          scaled down from this value so the rounded hierarchy looks consistent.
        '';
        example = 12;
      };
    };

    # ── Icon ───────────────────────────────────────────────────────────────
    iconSize = lib.mkOption {
      type        = lib.types.int;
      default     = 36;
      description = ''
        Application icon size in pixels shown next to each result entry.
        Larger values produce a more prominent, KRunner-style list.
      '';
      example = 28;
    };

    # ── List ───────────────────────────────────────────────────────────────
    maxResults = lib.mkOption {
      type        = lib.types.int;
      default     = 7;
      description = ''
        Maximum number of result rows visible at once.
        The window does not grow past this many rows; items scroll instead.
      '';
      example = 10;
    };

    # ── Spacing ────────────────────────────────────────────────────────────
    padding = lib.mkOption {
      type        = lib.types.int;
      default     = 24;
      description = ''
        Inner padding around the edges of the launcher window in pixels.
        This is the gap between the window border and the content inside.
      '';
      example = 16;
    };

    spacing = lib.mkOption {
      type        = lib.types.int;
      default     = 12;
      description = ''
        Vertical gap between the major sections of the launcher
        (input bar, message, list, mode switcher) in pixels.
      '';
      example = 8;
    };

  };
}
