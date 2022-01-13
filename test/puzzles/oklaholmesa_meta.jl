# http://web.mit.edu/puzzle/www/2012/puzzles/okla_holmes_a/solution/

@testset "okla holmes-a meta" begin
    results = evaluate(model, split("""
        CARPAL
        THE SOUTH
        STERNO
        BYLINE
        SO CLOSE
        BUFFOON
        VESTIGE""", '\n'))
    @test description(first(results)) == "Can be completely broken down into chemical element symbols"
end
