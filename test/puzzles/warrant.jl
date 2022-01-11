# http://web.mit.edu/puzzle/www/1999/puzzles/1Gumshoe/Warrants1/w1.2/w1.2.html
@testset "warrant 1.2" begin
    for (names, common_letter) in [
        (["racerx", "americanmaid", "kodachi", "ladyjane"], 'a'),
        (["brain", "judyjetson", "jonnyquest", "jeannette"], 'n'),
        (["kenshin", "lisasimpson", "michiganjfrog", "sheila"], 'i'),
        (["bedtimebear", "sherman", "stimpy", "mrmagoo"], 'm'),
        # (["bettyboop", "sweetpollypurebred", "skeletor", "firefly"], 'e')
        ]
        results = evaluate(model, names)

        # These answer sets are a bit short to achieve high statistical power,
        # but we'll call this correct if we see the correct answer in the report
        @test "Number of occurrences of '$common_letter'" in description.(results[1:10])
    end
end
