# Based on http://web.mit.edu/puzzle/www/2015/puzzle/ukacd/

@testset "ukacd" begin
    clues = ["hip-flask","infamise","facade","furnaced","ill fame","loofah","odoriferously","focalisation","deceitful","modify","defoliate","definabilities","exemplification","unfeminine","icefield","boastfulness","cuttlefishes","zinckification","folkland","unfeeling","flanges","have a short fuse","pelletifying","fable","efts","state of play","fangled","fitchews","fasciated","soulful","flaunchings","rust-proofing","Mustafa","carfuffle","far-out","goff","quinquefoliate","usufruct","denazified","thoughtfulness","pacificists","calves'-foot jelly","field of view","sweet flag","fandangos","sail-fish","Cadfael","fag","The Return of the Native","gold-foil","feldspathoid","caftan","road-fund licence","purfling","febrifugal","fish eagle","old-fogey","heffalump","confutation","flimping","sell-off","defuzed","battle fatigue","effluences","chaudfroid","flavorous","floury","elf","fusses","dog-faced","felt","law of excluded middle","Schottky effect","faddy","superficializes","tuner amplifiers","off-plan","counter-flory","unselfishness","sound effects","Fawkes","Mafikeng","Laffer curve","felines","foundering","fixed assets","foins","flatlets","dog-fights","lift-off","Fluellen","pouf","suffused","Aesop's Fables","manful","falsifying","kifs","custard coffin","officials","vote of no confidence"]

    map!(clues, clues) do w
        replace(lowercase(w), r"[^a-z]" => "")
    end
    results = evaluate(model, clues)
    @test description(first(results))== "Number of occurrences of 'f'"
    @test all(r -> !isnan(pvalue(r.test)), results)
end