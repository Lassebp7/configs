
source ~/.config/fish/aliases.fish

set -g fish_user_paths /home/lassebp7/.dotnet/tools

set -gx DOTNET_ROOT (mise where dotnet)

# pnpm
set -gx PNPM_HOME "/home/lassebp7/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

mise activate fish | source
starship init fish | source

set fish_greeting
