module Noticer

using LinearAlgebra: normalize!
using HypothesisTests: HypothesisTests, ChisqTest, pvalue, PowerDivergenceTest
using Printf: @sprintf

export all_features,
       description,
       evaluate,
       expected,
       observed,
       pvalue,
       train

include("features.jl")
include("model.jl")
include("evaluate.jl")

end
