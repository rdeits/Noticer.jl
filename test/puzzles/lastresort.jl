@testset "last resort" begin
    # http://www.maths.usyd.edu.au/ub/sums/puzzlehunt/2016/puzzles/A2S1_Last_Resort.pdf
    results = evaluate(model, ["advent", "achilles", "binary", "norway", "bubbly", "yacht", "anchor"])
    @test description(first(results)) == "Number of reverse alphabetical bigrams"
end
