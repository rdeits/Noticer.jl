function js_divergence(p, q)
    m = 0.5 .* p .+ 0.5 .* q
    0.5 * (kldivergence(p, m) + kldivergence(q, m))
end

struct FeatureResult
    feature::Feature
    observed::Vector{Float64}
    expected::Vector{Float64}
    divergence::Float64

    FeatureResult(feature::Feature, observed, expected) = new(feature, observed, expected, js_divergence(observed, expected))
end


observed(r::FeatureResult) = vec(r.observed)
expected(r::FeatureResult) = vec(r.expected)
description(r::FeatureResult) = r.feature.description

all_identical(r::FeatureResult) = count(!iszero, observed(r)) == 1

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
    _, mode_index = findmax(expected(r))
    observed(r)[mode_index] == 0
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
    print(io, "FeatureResult(\n\t$(r.feature.description), KL=$(@sprintf("%.2g", divergence(r))),\n\tobs: $(asciihist(observed(r))),\n\texp: $(asciihist(expected(r))))")
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
                <td><pre>$(asciihist(observed(result)))</pre></td>
                <td><pre>$(asciihist(expected(result)))</pre></td>
            </tr>""")
    end
    print(io, "</table>")
end

function evaluate(model::Model, samples)
    results = FeatureResult[]
    sizehint!(results, length(model.features))
    length_range = minimum(length, samples):maximum(length, samples)
    for (feature, feature_freq) in zip(model.features, frequencies(model, length_range))
        observed = zeros(length(feature_freq))
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
        normalize!(observed, 1)
        push!(results, FeatureResult(feature, observed, feature_freq))
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
                <td><pre>$(asciihist(observed(result)))</pre></td>
                <td><pre>$(asciihist(expected(result)))</pre></td>
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
                <td><pre>$(asciihist(observed(result)))</pre></td>
                <td><pre>$(asciihist(expected(result)))</pre></td>
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
                <td><pre>$(asciihist(observed(result)))</pre></td>
                <td><pre>$(asciihist(expected(result)))</pre></td>
            </tr>""")
    end

    print(io, "</table>")
end
