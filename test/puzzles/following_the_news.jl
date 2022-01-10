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
    @test "Number of cardinal directions (NESW)" in description.(results[1:5])
end
