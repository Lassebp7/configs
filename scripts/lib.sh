# Shared helpers for install.sh and the scripts in this folder. Source, don't run.

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_FILE="$HOME/.config/dotfiles/profile"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

available_profiles() {
  local dir
  for dir in "$REPO"/profiles/*/; do basename "$dir"; done
}

saved_profile() {
  [[ -f "$PROFILE_FILE" ]] && cat "$PROFILE_FILE"
}

# Moves a path in $HOME into the timestamped backup folder, keeping its relative location
backup() {
  local path="$1" rel="${1#"$HOME"/}"
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  mv "$path" "$BACKUP_DIR/$rel"
  warn "backed up ~/$rel to $BACKUP_DIR/$rel"
}
