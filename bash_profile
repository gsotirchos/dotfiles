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
source ~/.dotfiles/bin/append_paths ~/.dotfiles/extra_paths

# auto-completion
source ~/.dotfiles/bin/source_dirs_list ~/.dotfiles/completion_dirs
