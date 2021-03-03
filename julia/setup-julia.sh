#!/usr/bin/env bash

DIR=$(\
    builtin cd "$(\
    dirname "$(realpath "${BASH_SOURCE[0]}")")"\
    > /dev/null && pwd)

mkdir -p ~/.julia/config

ln -sfv ${DIR}/*.jl ~/.julia/config

julia .julia/config/install_base_packages.jl
