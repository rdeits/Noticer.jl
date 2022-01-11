struct Model
    features::Vector{Feature}
    frequencies_by_length::Dict{UnitRange{Int}, Vector{Vector{Float64}}}
    corpus::Vector{String}

    function Model(features::AbstractVector{Feature}, corpus::AbstractVector{<:AbstractString})
        new(features, Dict(), corpus)
    end

    function Model(features::AbstractVector{Feature}, corpus)
        new(features, Dict(), collect(corpus))
    end
end

function count_frequencies(func::F, corpus, length_range::UnitRange) where {F}
    frequencies = Float64[]
    for word in corpus
        if length(word) in length_range
            output = func(word)
            if output + 1 > length(frequencies)
                prev_size = length(frequencies)
                resize!(frequencies, output + 1)

                # This looks liike a bug: we're initializing the counts to 1
                # instead of 0. It's intentional, because the χ² statistic
                # becomes NaN for expected frequencies of exactly zero. By
                # initializing the count to 1 we ensure that all slots have a
                # small but nonzero exepcted frequency.
                frequencies[(prev_size + 1):end] .= 1
            end
            frequencies[output + 1] += 1
        end
    end
    normalize!(frequencies, 1)
    frequencies
end

function frequencies(model::Model, length_range::UnitRange)
    get!(model.frequencies_by_length, length_range) do
        @showprogress [count_frequencies(feature.f, model.corpus, length_range) for feature in model.features]
    end
end
