struct Cluster
    words::Vector{String}
    best_feature::FeatureResult
end

words(c::Cluster) = c.words
feature(c::Cluster) = c.best_feature
p_value(c::Cluster) = p_value(feature(c))
Base.isless(c1::Cluster, c2::Cluster) = p_value(c1) < p_value(c2)

function clusters(model::Model, samples, size)
    results = @showprogress map(subsets(samples, size)) do sub_samples
        Cluster(sub_samples, first(evaluate(model, sub_samples)))
    end
    sort!(results)
end

