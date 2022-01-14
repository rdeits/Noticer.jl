using Noticer
using Test

const words = Set{String}(Noticer.normalize.(open(readlines, joinpath(@__DIR__, "../data/113809of.fic"))))
open("/usr/share/dict/words") do f
    for line in readlines(f)
        push!(words, Noticer.normalize(line))
    end
end

const features = all_features()
const model = Model(features, words)

const PUZZLES_FOLDER = "puzzles"

@testset "Puzzles" begin
    for file in Base.Filesystem.readdir(PUZZLES_FOLDER)
        if endswith(file, ".jl")
            include(joinpath(PUZZLES_FOLDER, file))
        end
    end
end
