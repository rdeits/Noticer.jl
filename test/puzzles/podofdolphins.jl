@testset "pod of dolphins" begin
    # http://web.mit.edu/puzzle/www/2015/puzzle/pod_of_dolphins_meta/
    clues = ["citygates", "impulsive", "clickspam", "baptistry", "leviathan", "policecar", "coupdetat", "sforzando", "cartwheel"]
    results = evaluate(model, clues)
    @test description(first(results)) == "Number of unique letters"
end
