#!/usr/bin/env bash

#
# ~/.bash_profile
#

# if not running interactively, don't do anything
case $- in
    *i*) ;;

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

# dark theme toggle (run in background)
(python ~/.dotfiles/etc/toggle_dark_mode.py &) &> /dev/null
