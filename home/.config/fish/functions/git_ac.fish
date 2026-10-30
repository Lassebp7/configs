function git_ac --description 'Add all changes and commit with a message'
    if test (count $argv) -eq 0
        echo "Usage: git ac 'commit message'"
        return 1
    end

    git add .
    git commit -m "$argv"
end
