source ~/.config/fish/aliases.fish

set fish_greeting

fish_add_path ~/.local/bin ~/.opencode/bin ~/.dotnet/tools ~/scripts

# pnpm
set -gx PNPM_HOME ~/.local/share/pnpm
fish_add_path $PNPM_HOME

if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
end

type -q mise; and mise activate fish | source
type -q starship; and starship init fish | source
type -q zoxide; and zoxide init fish | source
type -q kubectl; and kubectl completion fish | source

if type -q opencode; and not test -s ~/.config/fish/completions/opencode.fish
    opencode --completions fish >~/.config/fish/completions/opencode.fish
end

# Abbreviations
abbr -a k kubectl
abbr -a p pnpm
abbr -a cl claude
