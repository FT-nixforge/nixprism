#!/usr/bin/env bash
# ft-nixlaunch — Modern Rofi Application Launcher
set -euo pipefail

ft-nixlaunch_DIR="@out@/share/ft-nixlaunch"
ft-nixlaunch_THEME="${ft-nixlaunch_THEME:-$ft-nixlaunch_DIR/themes/ft-nixlaunch.rasi}"
ft-nixlaunch_CONFIG="${ft-nixlaunch_CONFIG:-}"

# Load user config if available
if [[ -n "$ft-nixlaunch_CONFIG" && -f "$ft-nixlaunch_CONFIG" ]]; then
    # shellcheck disable=SC1090
    source "$ft-nixlaunch_CONFIG"
fi

SEARCH_ENGINE="${ft-nixlaunch_SEARCH_ENGINE:-https://www.google.com/search?q=}"
BROWSER="${ft-nixlaunch_BROWSER:-}"

FILE_SEARCH="$ft-nixlaunch_DIR/scripts/file-search.sh"
WEB_SEARCH="$ft-nixlaunch_DIR/scripts/web-search.sh"

# Export for sub-scripts
export ft-nixlaunch_SEARCH_ENGINE="$SEARCH_ENGINE"
export ft-nixlaunch_BROWSER="$BROWSER"

MODE="${1:-drun}"

common_args=(
    -theme "$ft-nixlaunch_THEME"
    -show-icons
    -icon-theme "Adwaita"
    -drun-display-format "{name}"
    -matching fuzzy
    -sorting-method fzf
    -scroll-method 0
    -normalize-match
    -steal-focus
    -kb-mode-next "Tab"
    -kb-mode-previous "ISO_Left_Tab"
    -kb-remove-to-eol ""
    -kb-custom-1 "Alt+r"
    -kb-custom-2 "Alt+f"
    -kb-custom-3 "Alt+w"
    -kb-custom-4 "Alt+a"
)

display_args=(
    -display-drun " Apps"
    -display-run " Run"
    -display-files " Files"
    -display-web " Web"
)

launch_rofi() {
    local mode="$1"
    shift
    set +e
    rofi -show "$mode" \
        -modi "drun,run,files:$FILE_SEARCH,web:$WEB_SEARCH" \
        "${display_args[@]}" \
        "${common_args[@]}" \
        "$@"
    return $?
}

# Resolve initial mode
case "$MODE" in
    drun|apps)   MODE="drun" ;;
    run|cmd)     MODE="run" ;;
    files|file)  MODE="files" ;;
    web|search)  MODE="web" ;;
    help|--help|-h)
        echo "ft-nixlaunch — Modern Application Launcher"
        echo ""
        echo "Usage: ft-nixlaunch [MODE]"
        echo ""
        echo "Modes:"
        echo "  drun, apps    Application launcher (default)"
        echo "  run, cmd      Command runner"
        echo "  files, file   File search"
        echo "  web, search   Web search"
        echo ""
        echo "Inside the launcher:"
        echo "  Tab           Switch to next mode"
        echo "  Shift+Tab     Switch to previous mode"
        echo "  Alt+A         Jump to Apps mode"
        echo "  Alt+R         Jump to Run mode"
        echo "  Alt+F         Jump to Files mode"
        echo "  Alt+W         Jump to Web mode"
        echo "  Escape        Close launcher"
        exit 0
        ;;
    *)
        echo "Unknown mode: $MODE" >&2
        echo "Run 'ft-nixlaunch --help' for usage." >&2
        exit 1
        ;;
esac

# Main loop: handles mode-switching via Alt+key custom keybindings
# Rofi exits with codes 10-13 for kb-custom-1 through kb-custom-4
while true; do
    launch_rofi "$MODE"
    exit_code=$?

    case $exit_code in
        10) MODE="run"   ;; # Alt+R
        11) MODE="files" ;; # Alt+F
        12) MODE="web"   ;; # Alt+W
        13) MODE="drun"  ;; # Alt+A
        *)  break        ;; # 0=selected, 1=cancelled, other=error
    esac
done
