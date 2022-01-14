struct Cluster
    words::Vector{String}
    best_feature::FeatureResult
end

words(c::Cluster) = c.words
feature(c::Cluster) = c.best_feature
p_value(c::Cluster) = p_value(feature(c))
Base.isless(c1::Cluster, c2::Cluster) = p_value(c1) < p_value(c2)

function clusters(model::Model, samples, size)
    samples .= normalize.(samples)
    results = @showprogress map(subsets(samples, size)) do sub_samples
        Cluster(sub_samples, first(evaluate(model, sub_samples)))
    end
    sort!(results)
end

function clusters(model::Model, samples)
    n = length(samples)
    cluster_sizes = filter(i -> n % i == 0, 2:div(n, 2))
    sort(reduce(vcat, (clusters(model, samples, size) for size in cluster_sizes)))
end

