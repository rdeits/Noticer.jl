using Distributions: Multinomial, pdf
using HypothesisTests: HypothesisTests, ChisqTest, pvalue, PowerDivergenceTest
using Combinatorics: multiexponents

function js_divergence(p, q)
    m = 0.5 .* p .+ 0.5 .* q
    0.5 * (kldivergence(p, m) + kldivergence(q, m))
end

function multinomial_exact_test(dist::Multinomial, observed_counts::AbstractVector{<:Integer})
    observed_pdf = pdf(dist, observed_counts)
    permutations_to_consider = multiexponents(length(observed_counts), dist.n)
    sum(permutations_to_consider) do sample
        p = pdf(dist, sample)
        if p <= observed_pdf
            p
        else
            zero(typeof(p))
        end
    end
end

function multinomial_monte_carlo_test(dist::Multinomial, observed_counts::AbstractVector{<:Integer}, n_samples=1_000_000)
    observed_pdf = pdf(dist, observed_counts)
    n_more_extreme_samples = 0

    for i in 1:n_samples
        sample = rand(dist)
        if sample != observed_counts && pdf(dist, sample) <= observed_pdf
            n_more_extreme_samples += 1
        end
    end
    observed_pdf + n_more_extreme_samples / n_samples
end

function can_use_exact_test(m, n, max_num_samples)
    try
        return length(multiexponents(m, n)) <= max_num_samples
    catch e
        if typeof(e) == OverflowError
            return false
        else
            rethrow(e)
        end
    end
end

function multinomial_test(dist::Multinomial, observed_counts)
    threshold = 1e5
    m = length(observed_counts)
    n = dist.n

    if can_use_exact_test(m, n, threshold)
        multinomial_exact_test(dist, observed_counts)
    else
        multinomial_monte_carlo_test(dist, observed_counts, threshold)
    end
end

struct FeatureResult
    feature::Feature
    observed_counts::Vector{Float64}
    expected_frequencies::Vector{Float64}
    divergence::Float64

    function FeatureResult(feature::Feature, observed, expected)
        # p = 1.0
        # if length(observed) > 1
        #     adjusted_expectation = copy(expected)
        #     adjusted_expectation .+= 1e-2
        #     normalize!(adjusted_expectation, 1)
        #     p = pvalue(ChisqTest(observed, adjusted_expectation))
        # end
        new(feature, observed, expected,
            -multinomial_test(Multinomial(sum(observed), expected), observed))
            # js_divergence(observed, expected))
                # -pdf(Multinomial(sum(observed), expected), observed))
    end
end


observed_counts(r::FeatureResult) = vec(r.observed_counts)
expected_frequencies(r::FeatureResult) = vec(r.expected_frequencies)
description(r::FeatureResult) = r.feature.description

all_identical(r::FeatureResult) = count(!iszero, observed_counts(r)) == 1

# function histogram_median(frequencies)::Int
#     @assert sum(frequencies) ≈ 1
#     cumulative_frequency = zero(eltype(frequencies))
#     for (i, individual_frequency) in enumerate(frequencies)
#         cumulative_frequency += individual_frequency
#         if cumulative_frequency >= 0.5
#             return i
#         end
#     end
# end

function all_unusual(r::FeatureResult)
    _, mode_index = findmax(expected_frequencies(r))
    observed_counts(r)[mode_index] == 0
end

divergence(r::FeatureResult) = r.divergence

Base.isless(r1::FeatureResult, r2::FeatureResult) =
    divergence(r1) < divergence(r2)

# Inspired by BenchmarkTools.jl (although our implementation is slightly different)
function asciihist(bins, height=1)
    histbars = ['_', '▁', '▂', '▃', '▄', '▅', '▆', '▇']
    join((i -> histbars[i]).(1 .+ round.(Int, bins ./ maximum(bins) .* (length(histbars) - 1))))
end

function Base.show(io::IO, r::FeatureResult)
    print(io, "FeatureResult(\n\t$(r.feature.description), KL=$(@sprintf("%.2g", divergence(r))),\n\tobs: $(asciihist(observed_counts(r))),\n\texp: $(asciihist(expected_frequencies(r))))")
end

function Base.show(io::IO, ::MIME"text/html", results::AbstractVector{FeatureResult})
    print(io, """
        <table>
            <tr>
                <th>Description</th>
                <th>Divergence</th>
                <th>Observed</th>
                <th>Expected</td>
            </tr>""")
    for result in results
        print(io, """
            <tr>
                <td>$(description(result))</td>
                <td>$(@sprintf("%.2g", divergence(result)))</td>
                <td><pre>$(asciihist(observed_counts(result)))</pre></td>
                <td><pre>$(asciihist(expected_frequencies(result)))</pre></td>
            </tr>""")
    end
    print(io, "</table>")
end

function evaluate(model::Model, samples)
    results = FeatureResult[]
    sizehint!(results, length(model.features))
    length_range = minimum(length, samples):maximum(length, samples)
    for (feature, feature_freq) in zip(model.features, frequencies(model, length_range))
        observed = zeros(Int, length(feature_freq))
        for word in samples
            word = normalize(word)
            output = feature.f(word)
            if output + 1 > length(observed)
                old_size = length(observed)
                resize!(observed, output + 1)
                observed[old_size:end] .= 0
                resize!(feature_freq, output + 1)
                feature_freq[(old_size + 1):end] .= 0
            end
            observed[output + 1] += 1
        end
        # Our corpus underestimates the likelihood of weird events (like having
        # a long answer with more than the expected number of consonants).
        # Bumping all the probabiliies up a bit helps avoid over-emphasizing
        # those results when the inevitably come up in answers
        probability_fudge_factor = 1e-3
        push!(results, FeatureResult(feature, observed,
            LinearAlgebra.normalize(feature_freq .+ probability_fudge_factor, 1)))
    end
    sort!(results; rev=true)
    results
end

struct Report
    results::Vector{FeatureResult}
    identical_matches::Vector{FeatureResult}
    unusual_matches::Vector{FeatureResult}

    function Report(results::AbstractVector{FeatureResult})
        sort!(results; rev=true)
        new(results, filter(all_identical, results), filter(all_unusual, results))
    end
end

function Base.show(io::IO, ::MIME"text/html", report::Report)
    print(io, """
        <table>
            <tr>
                <th colspan="4">All Features</th>
            </tr>
            <tr>
                <th>Description</th>
                <th>Divergence</th>
                <th>Observed</th>
                <th>Expected</td>
            </tr>""")
    for result in Base.Iterators.take(report.results, 10)
        print(io, """
            <tr>
                <td>$(description(result))</td>
                <td>$(@sprintf("%.2g", divergence(result)))</td>
                <td><pre>$(asciihist(observed_counts(result)))</pre></td>
                <td><pre>$(asciihist(expected_frequencies(result)))</pre></td>
            </tr>""")
    end
    print(io, """
            <tr>
                <th colspan="4">Identical Matches</th>
            </tr>
            <tr>
                <th>Description</th>
                <th>Divergence</th>
                <th>Observed</th>
                <th>Expected</td>
            </tr>""")
    for result in Base.Iterators.take(report.identical_matches, 10)
        print(io, """
            <tr>
                <td>$(description(result))</td>
                <td>$(@sprintf("%.2g", divergence(result)))</td>
                <td><pre>$(asciihist(observed_counts(result)))</pre></td>
                <td><pre>$(asciihist(expected_frequencies(result)))</pre></td>
            </tr>""")
    end
    print(io, """
            <tr>
                <th colspan="4">Unusual Matches</th>
            </tr>
            <tr>
                <th>Description</th>
                <th>Divergence</th>
                <th>Observed</th>
                <th>Expected</td>
            </tr>""")
    for result in Base.Iterators.take(report.unusual_matches, 10)
        print(io, """
            <tr>
                <td>$(description(result))</td>
                <td>$(@sprintf("%.2g", divergence(result)))</td>
                <td><pre>$(asciihist(observed_counts(result)))</pre></td>
                <td><pre>$(asciihist(expected_frequencies(result)))</pre></td>
            </tr>""")
    end

    print(io, "</table>")
end
