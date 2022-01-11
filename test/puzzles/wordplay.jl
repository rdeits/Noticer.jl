# MIT Mystery Hunt 2013 puzzle Wordplay 
# http://www.mit.edu/~puzzle/2013/coinheist.com/get_smart/wordplay/index.html

@testset "wordplay" begin

    # Set 1
    @test description(first(evaluate(model, ["ample", "adenoid", "music", "fifa"]))) == "Is a hill word"

    # Set 2
    # @test best_feature(["peeped", "isseis", "fee", "acacia", "salsas", "arrear"]).description == "is a pyramid word"

    # Set 3
    @test description(first(evaluate(model, ["skort", "sporty", "yolks", "peccadillo", "unknot", "rosy"]))) == "Is a valley word"

    # Set 4
    @test description(first(evaluate(model, ["testset", "lol", "tenet", "malayalam"]))) == "Is a palindrome"

    # Set 5
    @test "Number of double letters" in description.(evaluate(model, ["hitchhiker", "kaashoek", "jellystone", "kierkegaard", "metallica", "maastrict", "menschheit"])[1:3])

    # Set 6
    @test description(first(evaluate(model, ["aime", "eye", "eerie", "riaa", "oahu", "oeis"]))) == "Number of consonants"
end
