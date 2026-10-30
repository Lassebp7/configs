#!/usr/bin/env bash
# LEGO-specific setup, run by install.sh after the dotfiles are linked.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

env_file="$HOME/.config/opencode/.env"
if [[ ! -f "$env_file" ]]; then
  info "Creating $env_file"
  read -rsp "LEGO_GENAI_KEY (leave empty to fill in later): " key
  echo
  printf 'export LEGO_GENAI_KEY=%s\n' "$key" >"$env_file"
  chmod 600 "$env_file"
fi

brew="/home/linuxbrew/.linuxbrew/bin/brew"
if [[ ! -x "$brew" ]]; then
  info "Installing Homebrew"
  # Its closing PATH instructions are for bash; config.fish already loads brew
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

tap="git@github.com:LEGO/homebrew-tap"
if ! "$brew" list lego/tap/lego-cli >/dev/null 2>&1; then
  info "Installing the LEGO CLI"
  # The formula downloads from a private release with gh's token. gh comes from mise, which isn't activated in this shell
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  if command -v gh >/dev/null && ! gh auth status >/dev/null 2>&1; then
    info "Logging in to GitHub CLI"
    echo "  1. Press Enter at the prompt. gh only starts waiting for the browser after that."
    echo "  2. Paste the code in the browser, and authorize SSO for the LEGO org."
    echo "  3. The terminal continues by itself once GitHub says you're all set."
    # A fresh WSL distro has no browser launcher, so open the URL in the Windows default browser
    browser=""
    if [[ -z "${BROWSER:-}" ]] && ! command -v wslview >/dev/null && command -v explorer.exe >/dev/null; then
      browser="$(mktemp)"
      printf '#!/bin/sh\nexplorer.exe "$1"\nexit 0\n' >"$browser"
      chmod +x "$browser"
    fi
    BROWSER="${browser:-${BROWSER:-}}" gh auth login --hostname github.com --git-protocol ssh --skip-ssh-key --web || true
    if [[ -n "$browser" ]]; then rm -f "$browser"; fi
  fi
  # Fail instead of waiting for a password or host key prompt that brew hides
  export GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=15"
  if ! timeout 30 git ls-remote "$tap" HEAD >/dev/null 2>&1; then
    warn "No access to $tap. Authorize your SSH key for the LEGO org (https://github.com/settings/keys, Configure SSO), then run: brew tap lego/tap $tap && brew install lego/tap/lego-cli"
  elif ! { "$brew" tap lego/tap "$tap" && "$brew" install lego/tap/lego-cli; }; then
    warn "LEGO CLI install failed. Check that 'gh auth status' works and the token is SSO-authorized for LEGO, then run: brew install lego/tap/lego-cli"
  fi
fi
