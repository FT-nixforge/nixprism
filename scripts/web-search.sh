#!/usr/bin/env bash
# ft-nixlaunch — Web Search Mode (rofi script protocol)
#
# Type a query and press Enter to search the web.
# Includes quick-access bookmarks for NixOS resources.

SEARCH_ENGINE="${ft_nixlaunch_SEARCH_ENGINE:-https://www.google.com/search?q=}"
BROWSER_CMD="${ft_nixlaunch_BROWSER:-}"

open_url() {
    local url="$1"
    if [[ -n "$BROWSER_CMD" ]]; then
        $BROWSER_CMD "$url" &>/dev/null &
    else
        xdg-open "$url" &>/dev/null &
    fi
    disown
}

# Simple URL encoding (spaces to +, basic special chars)
urlencode() {
    local str="$1"
    str="${str// /+}"
    str="${str//&/%26}"
    str="${str//#/%23}"
    str="${str//\?/%3F}"
    echo "$str"
}

# Bookmarks: label → URL
declare -A BOOKMARKS=(
    ["NixOS Packages"]="https://search.nixos.org/packages"
    ["NixOS Options"]="https://search.nixos.org/options"
    ["NixOS Wiki"]="https://wiki.nixos.org"
    ["GitHub"]="https://github.com"
    ["Nix Manual"]="https://nix.dev/manual/nix/latest"
)

if [[ "${ROFI_RETV:-0}" == "1" ]]; then
    selected="$1"
    # Check if it's a bookmark
    if [[ -v "BOOKMARKS[$selected]" ]]; then
        open_url "${BOOKMARKS[$selected]}"
    else
        # Treat as search query
        encoded=$(urlencode "$selected")
        open_url "${SEARCH_ENGINE}${encoded}"
    fi
    exit 0
fi

if [[ "${ROFI_RETV:-0}" == "2" ]]; then
    query="$1"
    if [[ -n "$query" ]]; then
        encoded=$(urlencode "$query")
        open_url "${SEARCH_ENGINE}${encoded}"
    fi
    exit 0
fi

# Initial display
echo -en "\0prompt\x1f Web\n"
echo -en "\0message\x1fType a query and press Enter to search\n"
echo -en "\0markup-rows\x1ffalse\n"
echo -en "\0no-custom\x1ffalse\n"

# Quick-access bookmarks
for label in "NixOS Packages" "NixOS Options" "NixOS Wiki" "GitHub" "Nix Manual"; do
    echo "$label"
done
