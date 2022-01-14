# MIT Mystery Hunt 2014 puzzle Venntersections
# http://www.mit.edu/~puzzle/2014/puzzle/venntersections/


@testset "ventersections" begin
    @testset "diagram 1" begin
        # Set 1
        f1 = first(evaluate(model, ["lowered", "levitate", "inanimate", "paradise", "leveraged", "sizes", "tuxedo"]))
        @test description(f1) == "Alternates consonant/vowel"

        # Set 2
        f2 = first(filter(all_identical, evaluate(model, ["leveraged", "sizes", "tuxedo", "lynx", "lightly", "crocodile", "triumph"])))
        @test description(f2) == "Scrabble score"

        # Set 3
        f3 = first(evaluate(model, ["lowered", "levitate", "leveraged", "lynx", "lightly", "lengths", "legislator"]))
        @test description(f3) == "Character at index 1"

        # Set 4
        f4 = first(filter(all_identical, evaluate(model, ["levitate", "inanimate", "sizes", "lightly", "crocodile", "legislator", "carousels"])))
        @test description(f4) == "Number of repeated consonants"

        # Intersection
        c1, c2, c3, c4 = feature.((f1, f2, f3, f4))
        function check(word)
            c1(word) == 1 && c2(word) == c2("leveraged") && c3(word) == c3("lowered") && c4(word) == c4("levitate") && length(word) == 9
        end
        intersections = filter(check, model.corpus)
        @test length(intersections) < 10 && "lakesides" in intersections
    end

    @testset "diagram 2" begin
        # Set 2
        f2 = first(evaluate(model, ["questionable", "businesswoman", "exhaustion", "discouraged", "communicated", "hallucinogen", "sequoia"]))
        @test description(f2) == "Number of unique vowels"

        # Set 3
        f3 = first(filter(all_identical, evaluate(model, ["grimaced", "formally", "questionable", "discouraged", "communicated", "chrysalis", "saccharin"])))
        @test description(f3) == "Character at index 4 from the end"

        # Set 4
        f4 = first(evaluate(model, ["formally", "thinnest", "businesswoman", "communicated", "hallucinogen", "saccharin", "cellophane"]))
        @test description(f4) == "Number of double letters"
    end

    @testset "diagram 3" begin
        # # Set 1
        # f1 = first(evaluate(model, ["thumbtacks", "monologue", "frigidities", "statuesque", "testimony", "satirizing", "flawed"]))
        # @test description(f1) == "contains a day of the week abbreviation"

        # Set 3
        f3 = first(evaluate(model, ["thumbtacks", "monologue", "testimony", "camel", "meteorology", "trampoline", "achievement"]))
        @test description(f3) == "Number of occurrences of 'm'"

        # Set 4
        f4 = first(evaluate(model, ["monologue", "frigidities", "satirizing", "meteorology", "avalance", "achievement", "constitute"]))
        @test description(f4) == "Number of letters repeated at least 3 times"
    end

    @testset "diagram 4" begin
        # # Set 1
        # f1 = first(evaluate(model, ["philharmonic", "mischievous", "alphabet", "restaurant", "leeching", "mushroom", "pioneer"]))
        # @test description(f1.description) == "contains a greek letter"
        
        # Set 2
        @test "Number of double letters" in description.(evaluate(model, ["leeching", "mushroom", "pioneer", "loophole", "toothpaste", "seventeenth", "kneeling"])[1:2])

        # Set 3
        f3 = first(evaluate(model, ["philharmonic", "mischievous", "leeching", "loophole", "toothpaste", "alcoholic", "narwhal"]))
        @test description(f3) == "Character at index 5"

        # # Set 4
        # # Note: it turns out that the "most unlikely" feature of all of the words
        # # in this set of the puzzle is just that they contain an 'h'. However, the
        # # puzzle actually expects you to choose "has 3 consonants in a row" instead.
        # # So I've added a dummy word which does not contain an 'h' to the end of the
        # # list.
        # f4 = first(evaluate(model, ["mischievous", "alphabet", "mushroom", "toothpaste", "seventeenth", "narwhal", "chromosome", "aardvark"]))
        # @test f4.description == "has 3 consonants in a row"

        # # Intersection
        # checks = (f1, f2, f3, f4, word -> length(word) == 12)
        # for word in words
        #     if all(c(word) for c in checks)
        #         @test word == "neighborhood"
        #         break
        #     end
        # end
    end
end
