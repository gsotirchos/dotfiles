#!/usr/bin/env bash

mkdir -p ~/.julia/config

ln -sfv "${DOTFILES}"/config/*.jl ~/.julia/config

julia --startup-file=no ~/.julia/config/install_base_packages.jl
