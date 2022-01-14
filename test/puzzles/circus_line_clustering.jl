# http://www.mit.edu/~puzzle/2012/puzzles/a_circus_line/solution/

@testset "circus line meta" begin
    answers = split("""
        BOOKWORM
        COCOON
        COSPONSORS
        ENTICING
        ENUMERATE
        MEDLEY
        OCTOPOD
        PINHEAD
        SUBSTITUTE
        TORCHWOOD
        """)
    cluster = first(clusters(model, answers))
    @test description(feature(cluster)) == "Number of occurrences of 'o'"
    @test sort(cluster.words) == ["bookworm","cocoon","cosponsors","octopod","torchwood"]
end