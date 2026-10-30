#!/usr/bin/env bash
# Sets up a WSL/Ubuntu machine from this repo. Safe to run again.
#
#   ./install.sh --<profile>      e.g. --lego or --personal
#   ./install.sh                  reuse the saved profile, or pick one from a menu
#   ./install.sh --links-only     only relink dotfiles and rebuild AI config, no installs
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib.sh"

usage() {
  sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
  echo
  echo "Profiles: $(available_profiles | tr '\n' ' ')"
}

profile=""
links_only=false
for arg in "$@"; do
  case "$arg" in
    -h | --help) usage; exit 0 ;;
    --links-only) links_only=true ;;
    --*)
      name="${arg#--}"
      [[ -d "$REPO/profiles/$name" ]] || die "unknown profile '$name'. Available: $(available_profiles | tr '\n' ' ')"
      profile="$name"
      ;;
    *) die "unknown argument '$arg' (see --help)" ;;
  esac
done

previous="$(saved_profile || true)"
if [[ -z "$profile" ]]; then
  profile="$previous"
fi
if [[ -z "$profile" ]]; then
  echo "Pick a profile for this machine:"
  select profile in $(available_profiles); do
    [[ -n "$profile" ]] && break
  done
fi

install_packages() {
  info "Installing apt packages"
  sudo apt-get update -y
  sudo apt-get install -y git fish curl unzip build-essential stow
}

setup_ssh_key() {
  local key="$HOME/.ssh/id_ed25519"
  if [[ ! -f "$key" ]]; then
    info "Creating SSH key"
    local email
    email="$(git config --global user.email || true)"
    [[ -n "$email" ]] || read -rp "Email for the SSH key: " email
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$email" -f "$key"
    echo
    cat "$key.pub"
    echo
    echo "Add the key above at https://github.com/settings/keys"
    read -rp "Press Enter when done... "
  fi

  # Trust GitHub's host key up front, so git over SSH never stops at a hidden yes/no prompt
  if ! ssh-keygen -F github.com >/dev/null 2>&1; then
    info "Adding github.com to known_hosts"
    ssh-keyscan -t ed25519,ecdsa,rsa github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null
  fi

  if [[ "$(git -C "$REPO" remote get-url origin)" == https://github.com/* ]]; then
    info "Switching the repo remote to SSH"
    git -C "$REPO" remote set-url origin "$(git -C "$REPO" remote get-url origin | sed -E 's#https://github.com/#git@github.com:#')"
  fi
}

install_mise_tools() {
  local mise="$HOME/.local/bin/mise"
  if [[ ! -x "$mise" ]]; then
    info "Installing mise"
    curl -fsSL https://mise.run | sh
  fi
  info "Installing mise tools"
  "$mise" trust --yes "$HOME/.config/mise/config.toml"
  for file in "$HOME"/.config/mise/conf.d/*.toml; do
    [[ -e "$file" ]] && "$mise" trust --yes "$file"
  done
  "$mise" install --yes
}

install_ai_clis() {
  local opencode="$HOME/.opencode/bin/opencode" version=""
  [[ -x "$opencode" ]] && version="$("$opencode" --version 2>/dev/null || true)"
  if [[ ! "${version#v}" =~ ^([2-9]|[1-9][0-9]+)\. ]]; then
    info "Installing OpenCode 2"
    # opencode.ai/install only installs OpenCode 1
    curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path
  fi
  if [[ ! -x "$HOME/.local/bin/claude" ]]; then
    info "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
  fi
}

set_default_shell() {
  local fish
  fish="$(command -v fish)"
  if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$fish" ]]; then
    info "Setting fish as the default shell"
    chsh -s "$fish"
  fi
}

info "Using profile '$profile'"

if ! $links_only; then
  install_packages
  set_default_shell
  setup_ssh_key
fi

"$REPO/scripts/link.sh" "$profile" "$previous"
mkdir -p "$(dirname "$PROFILE_FILE")"
echo "$profile" >"$PROFILE_FILE"
"$REPO/scripts/build-ai.sh" "$profile"

if ! $links_only; then
  install_mise_tools
  install_ai_clis
  if [[ -x "$REPO/profiles/$profile/setup.sh" ]]; then
    info "Running setup for profile '$profile'"
    "$REPO/profiles/$profile/setup.sh"
  fi
fi

info "Done. Open a new terminal to load the config."
