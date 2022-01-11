module Noticer

using LinearAlgebra: normalize!
using HypothesisTests: HypothesisTests, ChisqTest, pvalue, PowerDivergenceTest
using Printf: @sprintf
using StaticArrays: SVector, setindex
using ProgressMeter: @showprogress

export all_features,
       description,
       evaluate,
       expected,
       observed,
       perfect_matches,
       pvalue,
       train

include("tallies.jl")
include("features.jl")
include("model.jl")
include("evaluate.jl")

end
