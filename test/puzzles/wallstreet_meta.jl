# http://web.mit.edu/puzzle/www/2011/puzzles/civilization/meta/wall_street.html
@testset "wallstreet meta" begin
    results = evaluate(model, ["autumn", "badminton", "trafficpylon", "american", "ingrid", "mercury", "corncake", "gooier", "triskelion", "wandering"])
    @test "Number of repeated letters" in description.(filter(all_identical, results)[1:2])
end
