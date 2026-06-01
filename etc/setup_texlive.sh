#!/usr/bin/env bash
set -euo pipefail
if command -v "rg" &> /dev/null; then
    if [[ "$OS" == "macos" ]]; then
        brew install basictex
    # else
    #     TODO
    fi
fi
sudo tlmgr update --self
sudo tlmgr install \
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
    bbm \
    mathtools \
    csquotes \
    ebgaramond \
    courierten \
    fontaxes
