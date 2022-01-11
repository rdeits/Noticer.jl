# MIT Mystery Hunt 2014 puzzle Venntersections
# http://www.mit.edu/~puzzle/2014/puzzle/venntersections/


@testset "ventersections" begin
    function best_feature(answers)
        # display(answers)
        results = evaluate(model, answers)
        # display(Report(results))
        description(first(results))
    end

    @testset "diagram 1" begin
        # # Set 1
        # f1 = best_feature(["lowered", "levitate", "inanimate", "paradise", "leveraged", "sizes", "tuxedo"])
        # @test f1.description == "alternates consonant vowel"

        # Set 2
        f2 = best_feature(["leveraged", "sizes", "tuxedo", "lynx", "lightly", "crocodile", "triumph"]) 
        @test f2 == "Scrabble score"

        # Set 3
        f3 = best_feature(["lowered", "levitate", "leveraged", "lynx", "lightly", "lengths", "legislator"])
        @test f3 == "Has 'l' at index 1"

        # Set 4
        @test "Number of repeated consonants" in description.(evaluate(model, ["levitate", "inanimate", "sizes", "lightly", "crocodile", "legislator", "carousels"])[1:2])

        # # Intersection
        # checks = (f1, f2, f3, f4, word -> length(word) == 9)
        # for word in words
        #     if all(c(word) for c in checks)
        #         @test word == "lakesides"
        #         break
        #     end
        # end

    end

    @testset "diagram 2" begin
        # Set 2
        f2 = best_feature(["questionable", "businesswoman", "exhaustion", "discouraged", "communicated", "hallucinogen", "sequoia"])
        @test f2 == "Number of unique vowels"

        # Set 3
        f3 = best_feature(["grimaced", "formally", "questionable", "discouraged", "communicated", "chrysalis", "saccharin"])
        @test f3 == "Has 'a' at index 4 from the end"

        # Set 4
        f4 = best_feature(["formally", "thinnest", "businesswoman", "communicated", "hallucinogen", "saccharin", "cellophane"])
        @test f4 == "Number of double letters"
    end

    @testset "diagram 3" begin
        # # Set 1
        # f1 = best_feature(["thumbtacks", "monologue", "frigidities", "statuesque", "testimony", "satirizing", "flawed"])
        # @test f1.description == "contains a day of the week abbreviation"

        # Set 3
        f3 = best_feature(["thumbtacks", "monologue", "testimony", "camel", "meteorology", "trampoline", "achievement"])
        @test f3 == "Number of occurrences of 'm'"

        # Set 4
        f4 = best_feature(["monologue", "frigidities", "satirizing", "meteorology", "avalance", "achievement", "constitute"])
        @test f4 == "Number of letters repeated at least 3 times"
    end

    @testset "diagram 4" begin
        # # Set 1
        # f1 = best_feature(["philharmonic", "mischievous", "alphabet", "restaurant", "leeching", "mushroom", "pioneer"])
        # @test f1.description == "contains a greek letter"
        
        # Set 2
        @test "Number of double letters" in description.(evaluate(model, ["leeching", "mushroom", "pioneer", "loophole", "toothpaste", "seventeenth", "kneeling"])[1:2])

        # Set 3
        f3 = best_feature(["philharmonic", "mischievous", "leeching", "loophole", "toothpaste", "alcoholic", "narwhal"])
        @test f3 == "Has 'h' at index 5"

        # # Set 4
        # # Note: it turns out that the "most unlikely" feature of all of the words
        # # in this set of the puzzle is just that they contain an 'h'. However, the
        # # puzzle actually expects you to choose "has 3 consonants in a row" instead.
        # # So I've added a dummy word which does not contain an 'h' to the end of the
        # # list.
        # f4 = best_feature(["mischievous", "alphabet", "mushroom", "toothpaste", "seventeenth", "narwhal", "chromosome", "aardvark"])
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
