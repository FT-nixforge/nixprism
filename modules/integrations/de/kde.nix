# ft-nixlaunch — KDE Plasma integration
#
# Registers ft-nixlaunch as a global shortcut in KDE Plasma.
#
# KDE stores global shortcuts in ~/.config/kglobalshortcutsrc.
# The file format is an INI-style file where each application group
# holds key=shortcut,defaultShortcut,friendlyName entries.
#
# We use `home.activation` with `kwriteconfig6` (KDE 6) / `kwriteconfig5`
# (KDE 5) rather than managing the file directly — writing the file directly
# would clobber ALL other shortcuts the user has configured in that section.
# The activation script is re-run on every `home-manager switch`, which means
# the shortcut is re-registered whenever the config changes.
#
# Keybind format: KDE uses "Meta+Space" notation.
#   Meta   → Super / Windows key
#   Ctrl   → Control
#   Alt    → Alt
#   Shift  → Shift
#   Example: "Meta+Space", "Ctrl+Alt+Space"
{ config, lib, pkgs, ... }:

let
  cfg  = config.programs.ft-nixlaunch;
  kCfg = cfg.integrations.kde;

  # Prefer kwriteconfig6 (KDE 6); fall back to kwriteconfig5 (KDE 5).
  kwriteconfig = pkgs.kdePackages.kconfig or pkgs.libsForQt5.kconfig;
in
{
  # ── Options ─────────────────────────────────────────────────────────────────
  options.programs.ft-nixlaunch.integrations.kde = {

    keybind = lib.mkOption {
      type        = lib.types.str;
      default     = "Meta+Space";
      example     = "Ctrl+Alt+Space";
      description = ''
        Global shortcut to launch ft-nixlaunch in KDE Plasma.

        Uses KDE's "Meta+Key" notation:
          Meta  → Super / Windows key
          Ctrl  → Control
          Alt   → Alt
          Shift → Shift

        Examples: "Meta+Space", "Ctrl+Alt+Space", "Meta+R"

        The shortcut is written to
        ~/.config/kglobalshortcutsrc via kwriteconfig6 (or kwriteconfig5
        on KDE 5) during `home-manager switch`.  You may also need to
        restart KDE's global shortcuts daemon:
          systemctl --user restart plasma-kglobalaccel
      '';
    };

  };

  # ── Config ──────────────────────────────────────────────────────────────────
  config = lib.mkIf (cfg.enable && cfg.integrations.de == "KDE") {

    # Ensure kwriteconfig is available during activation.
    home.packages = [ kwriteconfig ];

    # Write the shortcut entry into kglobalshortcutsrc.
    # Format per entry:
    #   _launch=<shortcut>,none,<friendly-name>
    #   <key>=<active-shortcut>,<default-shortcut>,<friendly-name>
    #
    # Using "none" as the default shortcut prevents KDE from
    # auto-assigning a conflicting default.
    home.activation.ft-nixlaunch-kde-shortcut =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        _kwrite="${kwriteconfig}/bin/kwriteconfig6"
        # Fall back to kwriteconfig5 if kwriteconfig6 is not available.
        if ! command -v "$_kwrite" &>/dev/null; then
          _kwrite="${kwriteconfig}/bin/kwriteconfig5"
        fi

        $DRY_RUN_CMD "$_kwrite" \
          --file "$HOME/.config/kglobalshortcutsrc" \
          --group "ft-nixlaunch.desktop" \
          --key "_launch" \
          "${kCfg.keybind},none,ft-nixlaunch"

        # Ask KDE's shortcut daemon to reload its configuration if it is
        # running.  Errors are silenced so the activation never fails on a
        # minimal or non-KDE system.
        $DRY_RUN_CMD qdbus org.kde.kglobalaccel \
          /component/ft-nixlaunch \
          org.kde.kglobalaccel.Component.invokeShortcut \
          "_launch" 2>/dev/null || true
      '';

    # Install a .desktop entry so KDE can associate the shortcut with the app.
    # Without this, kglobalshortcutsrc has nowhere to anchor the shortcut.
    xdg.dataFile."applications/ft-nixlaunch-kde.desktop".text = ''
      [Desktop Entry]
      Name=ft-nixlaunch
      Comment=Modern Rofi application launcher
      Exec=ft-nixlaunch
      Icon=application-menu
      Type=Application
      Categories=Utility;
      Keywords=launcher;search;run;applications;rofi;
      NoDisplay=true
      X-KDE-GlobalAccel=true
    '';

  };
}
