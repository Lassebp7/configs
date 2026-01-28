
source ~/.config/fish/aliases.fish

mise activate fish | source
starship init fish | source

set fish_greeting

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/lassebp7/anaconda3/bin/conda
    eval /home/lassebp7/anaconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/lassebp7/anaconda3/etc/fish/conf.d/conda.fish"
        . "/home/lassebp7/anaconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/lassebp7/anaconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

set -x PYTHONPATH "/home/lassebp7/code/6.Semester/MAL" $PYTHONPATH

# pnpm
set -gx PNPM_HOME "/home/lassebp7/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
