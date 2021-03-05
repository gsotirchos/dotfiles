#!/usr/bin/env julia

#
# ~/julia-stuff/install_packages.jl
#

using Pkg

Pkg.update()
Pkg.add("FileWatching")
Pkg.add("UnicodePlots")
Pkg.add("Plots")
Pkg.add("LinearAlgebra")
Pkg.add("SymPy")
Pkg.add("ControlSystems")

exit()y
