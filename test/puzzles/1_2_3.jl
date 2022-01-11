# https://puzzles.mit.edu/2016/puzzle/1_2_3/solution/
@testset "1, 2, 3" begin
    clues = ["season", "saveup", "ecowas", "ignore", "sluice", "hosni", "inbed", "barbeau", "museum", "tobiah", "unsew", "dolce", "anaphia", "teenage"]
    results = evaluate(model, clues)
    @test description(first(results)) == "Number of consonants"
end
