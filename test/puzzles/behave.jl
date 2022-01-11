# http://web.mit.edu/puzzle/www/2012/puzzles/william_s_bergman/behave/

@testset "behave" begin
    results = evaluate(model, ["annieproulx", "commutative", "hugoweaving", "mountaindew", "mozambique", "sequoia"])
    @test "Number of unique vowels" in description.(results[1:2])

    results = evaluate(model, ["almost", "biopsy", "chimp", "films", "ghost", "tux"])
    @test description(first(results)) == "Number of reverse alphabetical bigrams"

    results = evaluate(model, ["balked", "barspoon", "highnoon", "klutzy", "onyx", "posted"])
    @test description(first(results)) == "Number of reverse sequential bigrams"
end
