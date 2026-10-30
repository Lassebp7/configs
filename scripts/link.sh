#!/usr/bin/env bash
# Symlinks home/ and profiles/<profile>/home/ into $HOME with GNU stow.
# Anything in the way is moved to ~/.dotfiles-backup/ first.
# Usage: link.sh <profile> [previous-profile]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

profile="${1:?profile required}"
previous="${2:-}"

command -v stow >/dev/null || die "GNU stow is not installed (sudo apt install stow)"

# Clears the way for stow: backs up symlinked parent folders and any file that isn't already our link
clear_targets() {
  local package="$1" src rel dir target
  while IFS= read -r -d '' src; do
    rel="${src#"$package"/}"

    dir="$(dirname "$rel")"
    local ancestor=""
    IFS=/ read -ra parts <<<"$dir"
    for part in "${parts[@]}"; do
      [[ "$part" == "." ]] && continue
      ancestor="${ancestor:+$ancestor/}$part"
      if [[ -L "$HOME/$ancestor" ]]; then backup "$HOME/$ancestor"; fi
    done

    target="$HOME/$rel"
    if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$src")" ]]; then continue; fi
    if [[ -e "$target" || -L "$target" ]]; then backup "$target"; fi
  done < <(find "$package" \( -type f -o -type l \) -print0)
}

stow_package() {
  local stow_dir="$1"
  clear_targets "$stow_dir/home"
  # stow 2.3.1 (Ubuntu 24.04) prints a harmless "BUG in find_stowed_path" for absolute symlinks in ~, like ~/.aws -> /mnt/c/...
  stow --no-folding --restow --dir "$stow_dir" --target "$HOME" home 2> >(grep -v 'BUG in find_stowed_path' >&2)
}

if [[ -n "$previous" && "$previous" != "$profile" && -d "$REPO/profiles/$previous/home" ]]; then
  info "Unlinking previous profile '$previous'"
  stow --delete --dir "$REPO/profiles/$previous" --target "$HOME" home
fi

info "Linking shared config"
stow_package "$REPO"

if [[ -d "$REPO/profiles/$profile/home" ]]; then
  info "Linking profile '$profile'"
  stow_package "$REPO/profiles/$profile"
fi
