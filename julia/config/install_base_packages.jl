#!/usr/bin/env julia

#
# ~/julia-stuff/install_packages.jl
#

using Pkg

Pkg.update()
Pkg.add("LinearAlgebra")
Pkg.add("SymEngine")
Pkg.add("ControlSystems")
Pkg.add("UnicodePlots")
Pkg.add("Plots")

exit()
