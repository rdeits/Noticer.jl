struct Model
    features::Vector{Feature}
    frequencies::Vector{Vector{Float64}}
    corpus_size::Int
end

function train(features::AbstractVector{Feature}, corpus)
    result = Model(features, [Float64[] for _ in features], length(corpus))
    @showprogress for (feature, frequencies) in zip(result.features, result.frequencies)
        for word in corpus
            output = feature.f(word)
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
        normalize!(frequencies, 1)
    end
    result
end
