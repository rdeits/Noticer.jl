# http://web.mit.edu/puzzle/www/2013/coinheist.com/rubik/clockwork_orange/index.html
@testset "rubik clockwork orange meta" begin
    results = evaluate(model, ["armoredrecon", "hypapante", "commemorativebats", "derricktruck", "brownrot", "attorneysgeneral", "sacrosanct", "impromptu"])
    @test "Number of repeated letters" in description.(results[1:3])
end
