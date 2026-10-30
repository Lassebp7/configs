#!/usr/bin/env bash
# LEGO-specific setup, run by install.sh after the dotfiles are linked.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

env_file="$HOME/.config/opencode/.env"
if [[ ! -f "$env_file" ]]; then
  info "Creating $env_file"
  read -rsp "LEGO_GENAI_KEY (leave empty to fill in later): " key
  echo
  printf 'LEGO_GENAI_KEY=%s\n' "$key" >"$env_file"
  chmod 600 "$env_file"
fi

brew="/home/linuxbrew/.linuxbrew/bin/brew"
if [[ ! -x "$brew" ]]; then
  info "Installing Homebrew"
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! "$brew" list lego/tap/lego-cli >/dev/null 2>&1; then
  info "Installing the LEGO CLI"
  # The tap is a private LEGO repo, so this needs an SSH key authorized for the LEGO GitHub org
  if "$brew" tap lego/tap git@github.com:LEGO/homebrew-tap && "$brew" install lego/tap/lego-cli; then
    :
  else
    warn "LEGO CLI install failed. Authorize your SSH key for the LEGO org, then run: brew tap lego/tap git@github.com:LEGO/homebrew-tap && brew install lego/tap/lego-cli"
  fi
fi
