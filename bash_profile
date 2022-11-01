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

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# dark theme toggle (run in background)
(python ~/.dotfiles/etc/toggle_dark_mode.py &) &> /dev/null

# source bashrc
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi
