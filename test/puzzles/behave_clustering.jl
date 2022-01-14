# http://web.mit.edu/puzzle/www/2012/puzzles/william_s_bergman/behave/
#
# TODO: too slow for now

# @testset "behave clusters" begin
#     answers = [
#             "hugoweaving",
#             "mountaindew",
#             "mozambique",
#             "sequoia",
#             "annotation",
#             "artificial",
#             "individual",
#             "omnivorous",
#             "onlocation",
#             "almost",
#             "biopsy",
#             "chimp",
#             "films",
#             "ghost",
#             "tux",
#             "balked",
#             "highnoon",
#             "posted"]
#     cluster = first(clusters(model, answers, 6))
#     @test sort(cluster.words) == ["almost", "biopsy", "chimp", "films", "ghost", "tux"]
#     @test description(feature(cluster)) == "Number of reverse alphabetical bigrams"
# end
