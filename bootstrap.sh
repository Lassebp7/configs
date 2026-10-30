#!/usr/bin/env bash
# One-line setup for a fresh WSL/Ubuntu machine:
#   curl -fsSL https://raw.githubusercontent.com/Lassebp7/configs/main/bootstrap.sh | bash -s -- --lego
# Clones the repo to ~/code/configs and runs install.sh with the given arguments.
set -euo pipefail

repo_dir="$HOME/code/configs"

if ! command -v git >/dev/null; then
  sudo apt-get update -y
  sudo apt-get install -y git
fi

if [[ ! -d "$repo_dir/.git" ]]; then
  mkdir -p "$(dirname "$repo_dir")"
  git clone https://github.com/Lassebp7/configs.git "$repo_dir"
fi

# stdin is the curl pipe, so hand the terminal to install.sh for its prompts
exec bash "$repo_dir/install.sh" "$@" </dev/tty
