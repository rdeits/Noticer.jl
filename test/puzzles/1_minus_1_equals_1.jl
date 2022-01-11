# http://web.mit.edu/puzzle/www/2007/puzzles/1_1_1/
@testset "1-1=1" begin
    results = evaluate(model, split("""
        STRIFE
        SEAMAN
        NIX
        ETCH
        POST
        QUEERART
        FOO
        TALKS
        REPAYS
        STU
        HUMF
        UNDERHID
        SIXTEENS
        BOWMEN
        """))
    @test description(first(perfect_matches(results))) == "Has a 1-letter transdeletion"
end
