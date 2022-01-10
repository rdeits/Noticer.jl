using Noticer
using Test


function normalize(phrase)
    replace(lowercase(phrase), r"[^a-z ]" => "")
end

const words = Set{String}(normalize.(open(readlines, "../data/113809of.fic")))
open("/usr/share/dict/words") do f
    for line in readlines(f)
        push!(words, normalize(line))
    end
end

const features = all_features()
const model = train(features, words)

const PUZZLES_FOLDER = "puzzles"
for file in Base.Filesystem.readdir(PUZZLES_FOLDER)
    if endswith(file, ".jl")
        include(joinpath(PUZZLES_FOLDER, file))
    end
end
