set -gx PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

fish_add_path "/mnt/c/Users/lasse/AppData/Local/Programs/Microsoft VS Code/bin"
fish_add_path "/mnt/c/Program Files/Rancher Desktop/resources/resources/linux/bin"
fish_add_path "/mnt/c/Program Files/Rancher Desktop/resources/resources/win32/bin"
fish_add_path "/mnt/c/Windows/System32"

alias code='/mnt/c/Users/lasse/AppData/Local/Programs/Microsoft\ VS\ Code/bin/code'

source ~/.config/fish/aliases.fish
source ~/.config/fish/abbreviations.fish

mise activate fish | source
starship init fish | source

set fish_greeting

# pnpm
set -gx PNPM_HOME "/home/lassebp7/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
