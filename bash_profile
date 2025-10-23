# shellcheck disable=SC1090

#
# ~/.bash_profile
#

# if not running interactively, don't do anything
case $- in
    *i*)
        ;;
    *)
        return
        ;;
esac

# homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# source bashrc
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi
