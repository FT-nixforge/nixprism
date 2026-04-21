self:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkMerge
    types
    ;

  cfg = config.programs.ft-nixlaunch;

  # Check if Stylix is available and enabled
  stylixAvailable =
    (config ? stylix)
    && (config.stylix.enable or false)
    && (config ? lib.stylix.colors);

  stylixColors = if stylixAvailable then config.lib.stylix.colors else null;

  # Check if ft-nixpalette is available (via ft-nixpkgs.homeModules.ft-nixpalette)
  ft-nixpaletteAvailable =
    (config ? programs.ft-nixpalette)
    && (config.programs.ft-nixpalette.enable or false)
    && (config.programs.ft-nixpalette.colors != { });

  ft-nixpaletteColors = if ft-nixpaletteAvailable then config.programs.ft-nixpalette.colors else null;

  # Resolve colors: priority — ft-nixpalette > Stylix > manual config
  resolvedColors =
    if cfg.ft-nixpaletteIntegration && ft-nixpaletteColors != null then
      {
        background = nixpaletteColors.base00 or cfg.colors.background;
        backgroundAlt = nixpaletteColors.base01 or cfg.colors.backgroundAlt;
        foreground = nixpaletteColors.base05 or cfg.colors.foreground;
        foregroundAlt = nixpaletteColors.base04 or cfg.colors.foregroundAlt;
        accent = nixpaletteColors.base0D or cfg.colors.accent;
        urgent = nixpaletteColors.base08 or cfg.colors.urgent;
      }
    else if cfg.stylixIntegration && stylixColors != null then
      {
        background = "#${stylixColors.base00}";
        backgroundAlt = "#${stylixColors.base01}";
        foreground = "#${stylixColors.base05}";
        foregroundAlt = "#${stylixColors.base04}";
        accent = "#${stylixColors.base0D}";
        urgent = "#${stylixColors.base08}";
      }
    else
      {
        inherit (cfg.colors)
          background
          backgroundAlt
          foreground
          foregroundAlt
          accent
          urgent
          ;
      };

  alphaHex = cfg.opacity;

  # Generate the theme from module options
  generatedTheme = ''
    /* ft-nixlaunch — generated theme (do not edit; configure via Nix module) */

    * {
        bg:          ${resolvedColors.background}${alphaHex};
        bg-alt:      ${resolvedColors.backgroundAlt}${alphaHex};
        fg:          ${resolvedColors.foreground};
        fg-alt:      ${resolvedColors.foregroundAlt};
        accent:      ${resolvedColors.accent};
        urgent:      ${resolvedColors.urgent};
        transparent: #00000000;

        font: "${cfg.font.name} ${toString cfg.font.size}";

        background-color: transparent;
        text-color:       @fg;
    }

    window {
        transparency:     "real";
        location:         center;
        anchor:           center;
        fullscreen:       false;
        width:            ${toString cfg.window.width}px;
        border-radius:    ${toString cfg.window.borderRadius}px;
        background-color: @bg;
        border:           0px;
        cursor:           "default";
    }

    mainbox {
        background-color: transparent;
        children:         [ inputbar, message, listview, mode-switcher ];
        spacing:          ${toString cfg.spacing}px;
        padding:          ${toString cfg.padding}px;
    }

    inputbar {
        background-color: @bg-alt;
        border-radius:    ${toString (cfg.window.borderRadius - 8)}px;
        padding:          14px 20px;
        children:         [ prompt, textbox-prompt-colon, entry ];
        spacing:          12px;
    }

    prompt {
        background-color: transparent;
        text-color:       @accent;
        font:             "${cfg.font.name} Bold ${toString cfg.font.size}";
    }

    textbox-prompt-colon {
        expand:           false;
        str:              "";
        background-color: transparent;
        text-color:       @fg-alt;
    }

    entry {
        background-color: transparent;
        text-color:       @fg;
        placeholder:      "Type to search...";
        placeholder-color: @fg-alt;
        cursor:           text;
    }

    listview {
        background-color: transparent;
        columns:          1;
        lines:            ${toString cfg.maxResults};
        scrollbar:        false;
        fixed-height:     true;
        spacing:          4px;
        cycle:            true;
        dynamic:          true;
        layout:           vertical;
    }

    element {
        background-color: transparent;
        padding:          10px 16px;
        border-radius:    ${toString (cfg.window.borderRadius - 10)}px;
        spacing:          14px;
        cursor:           pointer;
        orientation:      horizontal;
    }

    element normal.normal,
    element alternate.normal {
        background-color: transparent;
    }

    element selected.normal {
        background-color: @bg-alt;
        text-color:       @fg;
    }

    element normal.urgent,
    element alternate.urgent {
        text-color: @urgent;
    }

    element selected.urgent {
        background-color: @urgent;
        text-color:       @bg;
    }

    element normal.active,
    element alternate.active {
        text-color: @accent;
    }

    element selected.active {
        background-color: @accent;
        text-color:       @bg;
    }

    element-icon {
        size:             ${toString cfg.iconSize}px;
        background-color: transparent;
        cursor:           inherit;
    }

    element-text {
        background-color: transparent;
        vertical-align:   0.5;
        cursor:           inherit;
    }

    message {
        background-color: transparent;
        padding:          0px 4px;
    }

    textbox {
        background-color: transparent;
        text-color:       @fg-alt;
        font:             "${cfg.font.name} ${toString (cfg.font.size - 3)}";
    }

    mode-switcher {
        background-color: transparent;
        spacing:          8px;
        padding:          0px 8px 0px 8px;
    }

    button {
        background-color: transparent;
        text-color:       @fg-alt;
        padding:          8px 16px;
        border-radius:    ${toString (cfg.window.borderRadius - 10)}px;
        cursor:           pointer;
        font:             "${cfg.font.name} ${toString (cfg.font.size - 2)}";
    }

    button selected {
        background-color: @bg-alt;
        text-color:       @accent;
    }
  '';

  ft-nixlaunchPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.default;

in
{
  options.programs.ft-nixlaunch = {
    enable = mkEnableOption "ft-nixlaunch, a modern Rofi application launcher";

    nixpaletteIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Derive colors from ft-nixpalette base16 scheme.
        Requires ft-nixpkgs.homeModules.ft-nixpalette to be imported and configured.
      '';
    };

    stylixIntegration = mkOption {
      type = types.bool;
      default = false;
      description = "Derive colors from Stylix base16 scheme. Requires Stylix to be configured.";
    };

    colors = {
      background = mkOption {
        type = types.str;
        default = "#1e1e2e";
        description = "Primary background color.";
      };
      backgroundAlt = mkOption {
        type = types.str;
        default = "#313244";
        description = "Secondary background (input bar, selections).";
      };
      foreground = mkOption {
        type = types.str;
        default = "#cdd6f4";
        description = "Primary text color.";
      };
      foregroundAlt = mkOption {
        type = types.str;
        default = "#a6adc8";
        description = "Muted text / placeholder color.";
      };
      accent = mkOption {
        type = types.str;
        default = "#89b4fa";
        description = "Accent color for highlights and prompts.";
      };
      urgent = mkOption {
        type = types.str;
        default = "#f38ba8";
        description = "Urgent/error color.";
      };
    };

    opacity = mkOption {
      type = types.str;
      default = "dd";
      description = "Hex alpha value appended to background colors (00 = transparent, ff = opaque).";
    };

    font = {
      name = mkOption {
        type = types.str;
        default = "Inter";
        description = "Font family name.";
      };
      size = mkOption {
        type = types.int;
        default = 13;
        description = "Font size in points.";
      };
    };

    window = {
      width = mkOption {
        type = types.int;
        default = 680;
        description = "Launcher window width in pixels.";
      };
      borderRadius = mkOption {
        type = types.int;
        default = 20;
        description = "Window corner radius in pixels.";
      };
    };

    iconSize = mkOption {
      type = types.int;
      default = 36;
      description = "Application icon size in pixels.";
    };

    maxResults = mkOption {
      type = types.int;
      default = 7;
      description = "Maximum visible results in the list.";
    };

    padding = mkOption {
      type = types.int;
      default = 24;
      description = "Inner padding of the launcher window (px).";
    };

    spacing = mkOption {
      type = types.int;
      default = 12;
      description = "Spacing between launcher sections (px).";
    };

    searchEngine = mkOption {
      type = types.str;
      default = "https://www.google.com/search?q=";
      description = "URL prefix for web search queries.";
    };

    browser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Browser command for web search. Null uses xdg-open.";
    };

    terminal = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Terminal emulator for run mode. Null uses rofi's default.";
    };

    hyprlandIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Add SUPER+Space keybinding and blur layer rules for Hyprland.
        Requires the Hyprland home-manager module to be imported.
      '';
    };

    keybind = mkOption {
      type = types.str;
      default = "SUPER, space";
      description = "Hyprland keybinding for launching ft-nixlaunch (modifier, key format).";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra rasi rules appended to the generated theme.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # ── Base configuration ────────────────────────────────────────────
    {
      home.packages = [ ft-nixlaunchPackage ];

      # Generated theme
      xdg.configFile."ft-nixlaunch/theme.rasi".text = generatedTheme + cfg.extraConfig;

      # Runtime config consumed by the launcher script
      xdg.configFile."ft-nixlaunch/config".text = ''
        ft-nixlaunch_SEARCH_ENGINE="${cfg.searchEngine}"
        ft-nixlaunch_BROWSER="${if cfg.browser != null then cfg.browser else ""}"
        ft-nixlaunch_TERMINAL="${if cfg.terminal != null then cfg.terminal else ""}"
      '';

      # Point the launcher at the generated theme + config
      home.sessionVariables = {
        ft-nixlaunch_THEME = "${config.xdg.configHome}/ft-nixlaunch/theme.rasi";
        ft-nixlaunch_CONFIG = "${config.xdg.configHome}/ft-nixlaunch/config";
      };
    }

    # ── Hyprland integration ──────────────────────────────────────────
    (mkIf cfg.hyprlandIntegration {
      wayland.windowManager.hyprland.settings = {
        bind = [ "${cfg.keybind}, exec, ft-nixlaunch" ];
        layerrule = [
          "blur, rofi"
          "ignorezero, rofi"
        ];
      };
    })
  ]);
}
