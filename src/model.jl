struct Model
    features::Vector{Feature}
    frequencies_by_length::Dict{UnitRange{Int}, Vector{Vector{Float64}}}
    corpus::Vector{String}

    function Model(features::AbstractVector{Feature}, corpus::AbstractVector{<:AbstractString})
        new(features, Dict(), corpus)
    end

    function Model(features::AbstractVector{Feature}, corpus=WORDS)
        new(features, Dict(), collect(corpus))
    end
end

function count_frequencies(func::F, corpus) where {F}
    frequencies = Float64[]
    for word in corpus
        output = func(word)
        if output + 1 > length(frequencies)
            prev_size = length(frequencies)
            resize!(frequencies, output + 1)
            frequencies[(prev_size + 1):end] .= 0
        end
        frequencies[output + 1] += 1
    end
    normalize!(frequencies, 1)
    frequencies
end

function frequencies(model::Model, length_range::UnitRange)
    get!(model.frequencies_by_length, length_range) do
        filtered_corpus = PreprocessedWord.(filter(w -> length(w) in length_range, model.corpus))
        [count_frequencies(feature.f, filtered_corpus) for feature in model.features]
    end
end
