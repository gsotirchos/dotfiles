#!/usr/bin/env bash
set -euo pipefail

# install basictex
if ! command -v "tlmgr" &> /dev/null; then
    if [[ "$OS" == "macos" ]]; then
        brew install basictex
    else
        apt install texlive-base
    fi
    eval "$(/usr/libexec/path_helper)"
fi

if [[ "$OS" == "macos" && -z "${TEXMFHOME:-}" ]]; then
    export TEXMFHOME="${HOME}/Library/texmf"
fi

if [[ ! -f "${TEXMFHOME}/tlpkg/texlive.tlpdb" ]]; then
    env tlmgr init-usertree
    mkdir -p "${TEXMFHOME}/tlpkg/backups"
fi

# update tlmgr and packages
if [[ "$OS" == "macos" ]]; then
    sudo env tlmgr update --self
    sudo env tlmgr update --all
else
    env tlmgr --usermode update --self
    env tlmgr --usermode update --all
fi

# NOTE: dvisvmg is needed for Org mode LaTeX fragments
if [[ "$OS" == "macos" ]]; then
    sudo env tlmgr install latexmk dvisvgm
else
    sudo apt install dvisvgm latexmk
    #sudo apt install ghostscript  # recommended for dvisvgm
fi

# install basic packages
env tlmgr --usermode install \
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
