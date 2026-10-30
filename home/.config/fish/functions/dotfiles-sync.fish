function dotfiles-sync --description 'Relink dotfiles and rebuild AI config from ~/code/configs'
    ~/code/configs/install.sh --links-only $argv
end
