@testset "last resort" begin
    # http://www.maths.usyd.edu.au/ub/sums/puzzlehunt/2016/puzzles/A2S1_Last_Resort.pdf
    results = evaluate(model, ["advent", "achilles", "binary", "norway", "bubbly", "yacht", "anchor"])
    @test "Number of reverse alphabetical bigrams" in description.(results[1:2])
end
