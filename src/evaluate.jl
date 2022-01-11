struct EvaluationResult
    feature::Feature
    test::PowerDivergenceTest
end

observed(r::EvaluationResult) = vec(r.test.observed)
expected(r::EvaluationResult) = vec(r.test.expected)
description(r::EvaluationResult) = r.feature.description
is_perfect_match(r::EvaluationResult) = count(!iszero, observed(r)) == 1

HypothesisTests.pvalue(r::EvaluationResult) = pvalue(r.test)

Base.isless(r1::EvaluationResult, r2::EvaluationResult) =
    pvalue(r1) < pvalue(r2)

# Inspired by BenchmarkTools.jl (although our implementation is slightly different)
function asciihist(bins, height=1)
    histbars = ['_', '▁', '▂', '▃', '▄', '▅', '▆', '▇']
    join((i -> histbars[i]).(1 .+ round.(Int, bins ./ maximum(bins) .* (length(histbars) - 1))))
end

function Base.show(io::IO, r::EvaluationResult)
    print(io, "EvaluationResult(\n\t$(r.feature.description), p=$(@sprintf("%.2g", pvalue(r))),\n\tobs: $(asciihist(observed(r))),\n\texp: $(asciihist(expected(r))))")
end

function Base.show(io::IO, ::MIME"text/html", results::AbstractVector{EvaluationResult})
    print(io, """
        <table>
            <tr>
                <th>Description</th>
                <th>P value</th>
                <th>Observed</th>
                <th>Expected</td>
            </tr>""")
    for result in results
        print(io, """
            <tr>
                <td>$(description(result))</td>
                <td>$(@sprintf("%.2g", pvalue(result)))</td>
                <td><pre>$(asciihist(observed(result)))</pre></td>
                <td><pre>$(asciihist(expected(result)))</pre></td>
            </tr>""")
    end
    print(io, "</table>")
end

function evaluate(model::Model, samples)
    results = EvaluationResult[]
    sizehint!(results, length(model.features))
    length_range = minimum(length, samples):maximum(length, samples)
    corpus_size = count(w -> length(w) in length_range, model.corpus)
    for (feature, feature_freq) in zip(model.features, frequencies(model, length_range))
        counts = zeros(Int, length(feature_freq))
        for word in samples
            word = normalize(word)
            output = feature.f(word)
            if output + 1 > length(counts)
                old_size = length(counts)
                resize!(counts, output + 1)
                counts[old_size:end] .= 0
                resize!(feature_freq, output + 1)
                # If we've never observed this value in the corpus, then set its probability to a small but nonzero value.
                feature_freq[old_size:end] .= 1 / corpus_size
            end
            counts[output + 1] += 1
        end
        normalize!(feature_freq, 1)
        push!(results, EvaluationResult(feature, ChisqTest(counts, feature_freq)))
    end
    sort!(results)
    results
end

perfect_matches(results::AbstractVector{EvaluationResult}) = filter(is_perfect_match, results)
