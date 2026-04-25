# ft-nixlaunch — behavior options
#
# Covers the top-level enable switch and all runtime behavior:
# web search engine, browser command, terminal emulator, and the
# raw rasi escape hatch.
{ lib, ... }:

{
  options.programs.ft-nixlaunch = {

    enable = lib.mkEnableOption "ft-nixlaunch, a modern Rofi application launcher";

    # ── Web search ──────────────────────────────────────────────────────────
    searchEngine = lib.mkOption {
      type    = lib.types.str;
      default = "https://www.google.com/search?q=";
      example = "https://duckduckgo.com/?q=";
      description = ''
        URL prefix used for web search queries typed in the Web mode.
        The URL-encoded query string is appended directly to this value.
      '';
    };

    browser = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = null;
      example = "firefox";
      description = ''
        Browser command used to open web search results and bookmarks.
        When `null`, `xdg-open` is used instead.
      '';
    };

    # ── Terminal ────────────────────────────────────────────────────────────
    terminal = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = null;
      example = "foot";
      description = ''
        Terminal emulator command passed to Rofi for the Run mode.
        When `null`, Rofi uses its built-in default terminal.
      '';
    };

    # ── Escape hatch ────────────────────────────────────────────────────────
    extraConfig = lib.mkOption {
      type    = lib.types.lines;
      default = "";
      example = ''
        window {
          width: 800px;
        }
      '';
      description = ''
        Raw rasi rules appended verbatim after the generated theme block.
        Use this for one-off overrides that are not exposed as module options.
        The content is not validated — invalid rasi will cause Rofi to fall
        back to its default theme at runtime.
      '';
    };

  };
}
