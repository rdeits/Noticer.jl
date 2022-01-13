module Noticer

using LinearAlgebra: LinearAlgebra, normalize!
using StatsBase: kldivergence
using Statistics: median
using Printf: @sprintf
using StaticArrays: SVector, setindex
using ProgressMeter: @showprogress
using DelimitedFiles: readdlm

export Model,
       Report,
       all_features,
       all_identical,
       all_unusual,
       description,
       evaluate,
       expected,
       observed

include("tallies.jl")
include("features.jl")
include("model.jl")
include("evaluate.jl")

end
