#!/usr/bin/env bash
set -euo pipefail

# install basictex
if ! command -v "tlmgr" &> /dev/null; then
    if [[ "$OS" == "macos" ]]; then
        brew install basictex
        mkdir -p "${HOME}/Library/texmf/tlpkg/backups"
    else
        apt install texlive-base
    fi
    eval "$(/usr/libexec/path_helper)"
    tlmgr init-usertree
fi

# update basictex and packages
tlmgr --usermode update --self
tlmgr --usermode update --all

# install basic packages
tlmgr --usermode install \
    latexmk \
    babel-greek \
    greek-fontenc \
    cbfonts \
    subfiles \
    appendix \
    siunitx \
    cancel \
    extarrows \
    mleftright \
    bbm-macros \
    mathtools \
    csquotes \
    ebgaramond \
    courierten \
    fontaxes \
    titlesec \
    xhfill \
    xcharter \
    xstring
