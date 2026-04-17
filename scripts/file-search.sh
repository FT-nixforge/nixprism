#!/usr/bin/env bash
# Prism — File Search Mode (rofi script protocol)
#
# Lists files from the home directory using fd.
# Rofi handles filtering as the user types.
# Selected files are opened with xdg-open.

if [[ "${ROFI_RETV:-0}" == "1" || "${ROFI_RETV:-0}" == "2" ]]; then
    selected="$1"
    if [[ -n "$selected" && -e "$selected" ]]; then
        xdg-open "$selected" &>/dev/null &
        disown
    fi
    exit 0
fi

# Prompt and options
echo -en "\0prompt\x1f Files\n"
echo -en "\0message\x1fType to filter — Enter to open\n"
echo -en "\0markup-rows\x1ffalse\n"
echo -en "\0no-custom\x1ffalse\n"

# List files using fd (fast, respects .gitignore by default)
fd --type f \
    --hidden \
    --no-ignore \
    --exclude '.cache' \
    --exclude '.local/share/Trash' \
    --exclude '.local/share/Steam' \
    --exclude 'node_modules' \
    --exclude '.git' \
    --exclude '.nix-defexpr' \
    --exclude '.nix-profile' \
    --exclude '.cargo/registry' \
    --exclude '.rustup' \
    --max-depth 5 \
    . "${HOME}" 2>/dev/null | head -500
