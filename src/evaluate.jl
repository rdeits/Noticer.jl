struct EvaluationResult
    feature::Feature
    test::PowerDivergenceTest
end

observed(r::EvaluationResult) = vec(r.test.observed)
expected(r::EvaluationResult) = vec(r.test.expected)
description(r::EvaluationResult) = r.feature.description

HypothesisTests.pvalue(r::EvaluationResult) = pvalue(r.test)

Base.isless(r1::EvaluationResult, r2::EvaluationResult) =
    pvalue(r1) < pvalue(r2)

# Inspired by BenchmarkTools.jl (although our implementation is slightly different)
function asciihist(bins, height=1)
    histbars = ['_', '▁', '▂', '▃', '▄', '▅', '▆', '▇']
    join((i -> histbars[i]).(1 .+ round.(Int, bins ./ maximum(bins) .* (length(histbars) - 1))))
end

function Base.show(io::IO, r::EvaluationResult)
    print(io, "EvaluationResult($(r.feature.description), p=$(@sprintf("%.2g", pvalue(r))),\n\tobs: $(asciihist(observed(r))),\n\texp: $(asciihist(expected(r))))")
end

function evaluate(model::Model, samples)
    results = EvaluationResult[]
    sizehint!(results, length(model.features))
    for (feature, frequencies) in zip(model.features, model.frequencies)
        counts = zeros(Int, length(frequencies))
        for word in samples
            output = feature.f(word)
            if output + 1 > length(counts)
                old_size = length(counts)
                resize!(counts, output + 1)
                counts[old_size:end] .= 0
                resize!(frequencies, output + 1)
                # If we've never observed this value in the corpus, then set its probability to a small but nonzero value.
                frequencies[old_size:end] .= 1 / model.corpus_size
            end
            counts[output + 1] += 1
        end
        normalize!(frequencies, 1)
        push!(results, EvaluationResult(feature, ChisqTest(counts, frequencies)))
    end
    sort!(results)
    results
end
