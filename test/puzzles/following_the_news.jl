# http://web.mit.edu/puzzle/www/2013/coinheist.com/get_smart/following_the_news/index.html
@testset  "following the news" begin
    results = evaluate(model, ["andrewlin",
                      "betatests",
                      "clockofthelongnow",
                      "decompressor",
                      "eugene",
                      "fungusproofsword",
                      "gleemen",
                      "hansardise",
                      "interpose"])
    @test description(first(perfect_matches(results))) == "Number of cardinal directions (NESW)"
end
