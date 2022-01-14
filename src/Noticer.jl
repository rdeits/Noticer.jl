module Noticer

using Combinatorics: multiexponents
using IterTools: subsets, chain
using Base.Iterators: cycle
using DelimitedFiles: readdlm
using Distributions: Multinomial, pdf
using LinearAlgebra: LinearAlgebra, normalize!
using Printf: @sprintf
using ProgressMeter: @showprogress
using StaticArrays: SVector, setindex
using Statistics: median

export Model,
       Report,
       all_features,
       all_identical,
       all_unusual,
       clusters,
       description,
       evaluate,
       expected,
       feature,
       observed

include("tallies.jl")
include("features.jl")
include("model.jl")
include("evaluate.jl")
include("clustering.jl")

end
