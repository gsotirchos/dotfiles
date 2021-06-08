#
# ~/.julia/config/starup.jl
#

using FileWatching
using LinearAlgebra
using UnicodePlots
#using PyPlot
#using SymEngine
#using ControlSystems

# function to execute script when it is changed
include("watcher.jl")
