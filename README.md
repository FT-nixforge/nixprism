# 🔮 Prism

A modern, polished Rofi application launcher for NixOS and Wayland.

Inspired by macOS Spotlight, KDE KRunner, and Ulauncher — Prism transforms Rofi
into a beautiful, centered launcher with blurred transparency, rounded corners,
and clean typography.

## ✨ Features

- **Centered launcher** — floats in the middle of your screen
- **Blurred transparency** — works with Hyprland and other Wayland compositors
- **Rounded corners** — 20 px radius by default, fully configurable
- **Large app icons** — clean list with icons and names, no terminal-style clutter
- **Multiple modes** — press `Tab` to switch:
  - 🚀 **Apps** (drun) — launch applications
  - ⌨️  **Run** — execute shell commands
  - 📁 **Files** — search and open files
  - 🌐 **Web** — search the web
- **Stylix integration** — respects your system colour scheme
- **Fully configurable** — colours, fonts, sizes, keybindings, all via Nix options

## 📦 Installation

### As a flake input

Add Prism to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    prism.url = "github:youruser/prism"; # or "path:./prism"
  };

  outputs = { nixpkgs, home-manager, prism, ... }: {
    # …your config
  };
}
```

### Home Manager module

In your Home Manager configuration:

```nix
{ inputs, ... }:
{
  imports = [ inputs.prism.homeManagerModules.default ];

  programs.prism = {
    enable = true;

    # Optional: auto-bind SUPER+Space in Hyprland
    hyprlandIntegration = true;

    # Optional: pull colours from Stylix
    stylixIntegration = true;
  };
}
```

### Standalone package (no module)

```nix
{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.prism.packages.${pkgs.system}.default ];
}
```

Then add a keybinding manually in your Hyprland config:

```conf
bind = SUPER, space, exec, prism
```

## ⚙️ Configuration

All options live under `programs.prism`.

### Colours

```nix
programs.prism = {
  colors = {
    background    = "#1e1e2e";  # Primary background
    backgroundAlt = "#313244";  # Input bar / selection
    foreground    = "#cdd6f4";  # Primary text
    foregroundAlt = "#a6adc8";  # Placeholders / muted text
    accent        = "#89b4fa";  # Highlights and prompts
    urgent        = "#f38ba8";  # Urgent items
  };
  opacity = "dd"; # Hex alpha (00–ff)
};
```

### Typography & Layout

```nix
programs.prism = {
  font = {
    name = "Inter";
    size = 13;
  };
  window = {
    width        = 680;
    borderRadius = 20;
  };
  iconSize   = 36;
  maxResults = 7;
  padding    = 24;
  spacing    = 12;
};
```

### Web Search

```nix
programs.prism = {
  searchEngine = "https://duckduckgo.com/?q=";
  browser      = "firefox"; # null → xdg-open
};
```

### Keybinding

```nix
programs.prism = {
  hyprlandIntegration = true;   # Adds bind + blur layer rules
  keybind             = "SUPER, space"; # Hyprland format
};
```

### Stylix Integration

If you use [Stylix](https://github.com/danth/stylix) for system-wide theming:

```nix
programs.prism.stylixIntegration = true;
# Colours are auto-derived from the active base16 scheme.
```

### Extra Theme Customisation

Append raw rasi rules for advanced overrides:

```nix
programs.prism.extraConfig = ''
  window {
    width: 800px;
  }
'';
```

## 🚀 Usage

### Launch from the command line

```bash
prism           # App launcher (default)
prism run       # Command runner
prism files     # File search
prism web       # Web search
prism --help    # Show help
```

### Keyboard shortcuts inside the launcher

| Key           | Action                   |
|---------------|--------------------------|
| `Tab`         | Switch to next mode      |
| `Shift+Tab`   | Switch to previous mode  |
| `Alt+A`       | Jump to Apps mode        |
| `Alt+R`       | Jump to Run mode         |
| `Alt+F`       | Jump to Files mode       |
| `Alt+W`       | Jump to Web mode         |
| `Enter`       | Open / execute selection |
| `Escape`      | Close the launcher       |
| Arrow keys    | Navigate results         |

### Modes

1. **Apps** — searches `.desktop` entries; shows icons and names
2. **Run** — execute any shell command
3. **Files** — searches files under `$HOME` (powered by `fd`)
4. **Web** — type a query and press Enter; includes NixOS quick links

## 🖌️ Compositor Setup

### Hyprland

For the blurred background effect add these layer rules to your Hyprland
config (the module sets these automatically when `hyprlandIntegration = true`):

```conf
layerrule = blur, rofi
layerrule = ignorezero, rofi
```

Optional — dim everything behind the launcher for a spotlight effect:

```conf
layerrule = dimaround, rofi
```

### Sway (swayfx)

SwayFX supports blur:

```conf
blur enable
layer_effects "rofi" blur enable
```

### Other Wayland Compositors

Prism uses `transparency: "real"` in the theme. Enable blur for
Rofi / layer-shell surfaces in your compositor's settings.

## 📂 Project Structure

```
prism/
├── flake.nix              Nix flake entry point
├── package.nix            Package derivation
├── module.nix             Home Manager module with options
├── scripts/
│   ├── prism-launcher.sh  Main launcher wrapper
│   ├── file-search.sh     File search mode (rofi script)
│   └── web-search.sh      Web search mode (rofi script)
├── themes/
│   └── prism.rasi         Default theme (Catppuccin Mocha)
└── README.md
```

## 📄 Licence

MIT
