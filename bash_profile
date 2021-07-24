#
# ~/.bash_profile
#

# vim: set ft=sh:

# if not running interactively, don't do anything
case $- in
    *i*)
        ;;
    *)
        return
        ;;
esac

# homebrew path
if [[ -z "${HOMEBREW_PREFIX}" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# source bash extra
if [[ -f ~/.bash_extra ]]; then
    source ~/.bash_extra
fi

# append extra paths from files
source ~/.dotfiles/etc/append_paths.sh ~/.dotfiles/extra_paths

# auto-completion
source ~/.dotfiles/etc/source_dirs_list.sh ~/.dotfiles/completion_dirs

# dark theme toggle (run in background)
(python ~/.dotfiles/etc/toggle_dark_mode.py &) &> /dev/null
