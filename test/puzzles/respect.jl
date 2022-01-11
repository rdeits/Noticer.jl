using Random: shuffle, seed!

seed!(42)

# http://web.mit.edu/puzzle/www/2012/puzzles/watson_2_0/r_e_s_p_e_c_t/
@testset "R.E.S.P.E.C.T" begin
    results = evaluate(model, join.(shuffle.(collect.(split("""
        ABMNOT
        AENORTY
        BCEKLORSTU
        BFLU
        CDEILNOTU
        CIK
        GIOPS
        ABCEKNO
        ABLMNOR
        ACEILMPR
        ACEILTUV
        HINOPSY
        ACDEIKLNST
        ACDEMY
        ACEMZ
        ACHIMNST
        DEIO
        GLNOTU
        ABCEGILORTY
        ABEINORTX
        ACRTUY
        AGHTUY
        CDEIMNOPU
        ACDILMOPT
        ACHILP
        BCEKUY
        MNOTU
        """)))))

    @test description(first(filter(all_identical, results))) == "Has a 1-letter transaddition"
end
