# 🚀 ft-nixlaunch

A modern, polished Rofi application launcher for Wayland.
Inspired by macOS Spotlight and KDE KRunner — centered, blurred, and fully configurable via Home Manager options.

> **Home Manager only.** ft-nixlaunch is configured entirely through Home Manager.
> There is no NixOS system-level module.

---

## Features

- **Centered launcher** — floats in the middle of your screen with real transparency
- **Blurred background** — works with Hyprland and other Wayland compositors
- **Rounded corners** — 20 px radius by default, fully configurable
- **Large app icons** — clean list layout with icons and names
- **Multiple modes** — press `Tab` to switch between:
  - 🚀 **Apps** (`drun`) — launch applications from `.desktop` entries
  - ⌨️  **Run** — execute shell commands
  - 📁 **Files** — search and open files (powered by `fd`)
  - 🌐 **Web** — search the web or jump to NixOS quick-links
- **ft-nixpalette integration** — colors auto-derived from your ft-nixpalette theme via Stylix
- **Stylix integration** — respects any Stylix base16 scheme
- **Fully configurable** — colors, fonts, sizes, keybindings, all via Nix options

---

## Installation

### Via ft-nixpkgs (recommended)

If you already use [ft-nixpkgs](https://github.com/FT-nixforge/ft-nixpkgs) you need
**no extra flake input** — ft-nixlaunch is already bundled:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    ft-nixpkgs.url   = "github:FT-nixforge/ft-nixpkgs";
  };
}
```

```nix
# home.nix
{ inputs, ... }:
{
  imports = [ inputs.ft-nixpkgs.homeModules.default ];

  programs.ft-nixlaunch = {
    enable = true;
  };
}
```

### As a standalone flake input

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url   = "github:nix-community/home-manager";
    ft-nixlaunch.url   = "github:FT-nixforge/ft-nixlaunch";
  };
}
```

```nix
# home.nix
{ inputs, ... }:
{
  imports = [ inputs.ft-nixlaunch.homeModules.default ];

  programs.ft-nixlaunch = {
    enable = true;
  };
}
```

### Standalone package (no module)

```nix
{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.ft-nixlaunch.packages.${pkgs.system}.default ];
}
```

Add a keybinding manually in your Hyprland config:

```conf
bind = SUPER, space, exec, ft-nixlaunch
```

---

## Configuration

All options live under `programs.ft-nixlaunch`.

### Minimal example

```nix
programs.ft-nixlaunch = {
  enable               = true;
  hyprlandIntegration  = true;   # adds keybind + blur layer rules
  nixpaletteIntegration = true;  # follow your ft-nixpalette / Stylix theme
};
```

---

### Color integration

#### ft-nixpalette (recommended)

[ft-nixpalette](https://github.com/FT-nixforge/ft-nixpalette) is a NixOS-level module
that configures Stylix system-wide. Stylix then exposes the active base16 palette to
Home Manager through `config.lib.stylix.colors`. Set `nixpaletteIntegration = true` to
read those colors automatically:

```nix
# NixOS configuration.nix (or nixos module)
{
  imports = [ inputs.ft-nixpkgs.nixosModules.default ];

  ft-nixpalette = {
    enable = true;
    theme  = "builtin:base/catppuccin-mocha";
  };
}
```

```nix
# home.nix
{
  programs.ft-nixlaunch = {
    enable                = true;
    nixpaletteIntegration = true; # reads colors from config.lib.stylix.colors
  };
}
```

#### Stylix (without ft-nixpalette)

If you use [Stylix](https://github.com/danth/stylix) directly:

```nix
programs.ft-nixlaunch = {
  enable           = true;
  stylixIntegration = true;
};
```

Both `nixpaletteIntegration` and `stylixIntegration` use the same underlying path
(`config.lib.stylix.colors`). Choose the name that better reflects your intent.

#### Manual colors

```nix
programs.ft-nixlaunch = {
  enable  = true;
  colors = {
    background    = "#1e1e2e";
    backgroundAlt = "#313244";
    foreground    = "#cdd6f4";
    foregroundAlt = "#a6adc8";
    accent        = "#89b4fa";
    urgent        = "#f38ba8";
  };
  opacity = "dd"; # hex alpha appended to background colors (00–ff)
};
```

---

### Font

```nix
programs.ft-nixlaunch = {
  font = {
    name = "JetBrainsMono Nerd Font";
    size = 13;
  };
};
```

---

### Window

```nix
programs.ft-nixlaunch = {
  window = {
    width        = 680; # pixels
    borderRadius = 20;  # pixels
  };
};
```

---

### Layout

```nix
programs.ft-nixlaunch = {
  iconSize   = 36;  # application icon size (px)
  maxResults = 7;   # visible results in the list
  padding    = 24;  # inner window padding (px)
  spacing    = 12;  # gap between sections (px)
};
```

---

### Web search

```nix
programs.ft-nixlaunch = {
  searchEngine = "https://duckduckgo.com/?q="; # default: Google
  browser      = "firefox";                    # null → xdg-open
};
```

---

### Hyprland integration

```nix
programs.ft-nixlaunch = {
  hyprlandIntegration = true;
  keybind             = "SUPER, space"; # modifier, key
};
```

When `hyprlandIntegration = true` the module automatically adds:

```conf
bind      = SUPER, space, exec, ft-nixlaunch
layerrule = blur, rofi
layerrule = ignorezero, rofi
```

For an optional spotlight-style dim behind the launcher, add this manually:

```conf
layerrule = dimaround, rofi
```

---

### Advanced / escape hatch

```nix
programs.ft-nixlaunch.extraConfig = ''
  window {
    width: 800px;
  }
'';
```

Raw rasi rules in `extraConfig` are appended verbatim after the generated theme.

---

### Terminal (Run mode)

```nix
programs.ft-nixlaunch.terminal = "foot"; # null → rofi built-in default
```

---

## Usage

### From the command line

```bash
ft-nixlaunch          # App launcher (default)
ft-nixlaunch run      # Command runner
ft-nixlaunch files    # File search
ft-nixlaunch web      # Web search
ft-nixlaunch --help   # Show help
```

### Keyboard shortcuts inside the launcher

| Key          | Action                  |
|--------------|-------------------------|
| `Tab`        | Next mode               |
| `Shift+Tab`  | Previous mode           |
| `Alt+A`      | Jump to Apps mode       |
| `Alt+R`      | Jump to Run mode        |
| `Alt+F`      | Jump to Files mode      |
| `Alt+W`      | Jump to Web mode        |
| `Enter`      | Open / execute          |
| `Escape`     | Close launcher          |
| Arrow keys   | Navigate results        |

---

## Compositor setup

### Hyprland

```conf
layerrule = blur, rofi
layerrule = ignorezero, rofi
```

These are added automatically when `hyprlandIntegration = true`.

### Sway (swayfx)

```conf
blur enable
layer_effects "rofi" blur enable
```

### Other Wayland compositors

ft-nixlaunch uses `transparency: "real"` in the theme. Enable blur for
Rofi / layer-shell surfaces in your compositor's settings.

---

## Project structure

```
ft-nixlaunch/
├── flake.nix                          Nix flake entry point
├── modules/
│   └── home.nix                       Home Manager module (options + config)
├── pkgs/
│   └── default.nix                    Package derivation
├── scripts/
│   ├── ft-nixlaunch-launcher.sh       Main launcher binary
│   ├── file-search.sh                 File search mode (rofi script protocol)
│   └── web-search.sh                  Web search mode (rofi script protocol)
├── themes/
│   └── ft-nixlaunch.rasi              Default fallback theme (Catppuccin Mocha)
└── README.md
```

---

## Contributing to ft-nixpkgs

ft-nixlaunch is already registered in
[ft-nixpkgs](https://github.com/FT-nixforge/ft-nixpkgs) and included in its
`homeModules.default` aggregation. The registry entry lives at
`flakes/ft-nixlaunch/default.nix` in the ft-nixpkgs repo.

---

## Licence

MIT