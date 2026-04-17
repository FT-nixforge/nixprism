#!/usr/bin/env bash
# Prism — Modern Rofi Application Launcher
set -euo pipefail

PRISM_DIR="@out@/share/prism"
PRISM_THEME="${PRISM_THEME:-$PRISM_DIR/themes/prism.rasi}"
PRISM_CONFIG="${PRISM_CONFIG:-}"

# Load user config if available
if [[ -n "$PRISM_CONFIG" && -f "$PRISM_CONFIG" ]]; then
    # shellcheck disable=SC1090
    source "$PRISM_CONFIG"
fi

SEARCH_ENGINE="${PRISM_SEARCH_ENGINE:-https://www.google.com/search?q=}"
BROWSER="${PRISM_BROWSER:-}"

FILE_SEARCH="$PRISM_DIR/scripts/file-search.sh"
WEB_SEARCH="$PRISM_DIR/scripts/web-search.sh"

# Export for sub-scripts
export PRISM_SEARCH_ENGINE="$SEARCH_ENGINE"
export PRISM_BROWSER="$BROWSER"

MODE="${1:-drun}"

common_args=(
    -theme "$PRISM_THEME"
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
        echo "Prism — Modern Application Launcher"
        echo ""
        echo "Usage: prism [MODE]"
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
        echo "Run 'prism --help' for usage." >&2
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
