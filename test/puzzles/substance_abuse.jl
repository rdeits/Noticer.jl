# http://web.mit.edu/puzzle/www/2013/coinheist.com/rubik/substance_abuse/index.html
@testset "substance abuse" begin
    results = evaluate(model, split("""
            KBNSCSICRBNA
            PSICAFCRLIO
            CRLISCNCA
            LIKBBECALI
            NCABPARNSCBNA
            CABNEHBKNSCHESCP
            BCSIOCLNCBNA
            NEHBNATIHEBCASLIO
            BHESIPOSIPNCSICA
            SINASCNCLI
            NNALISCSICLI
            NAARCASIOSIMGSIOCR
            NEHNOSCAL
            NCRCRSICBN
            NASIOHCKHCR
            CAFLI
            PBSCNAARBECALICKLI
            NANPHENBNABC
            SCARFCRSICA
            HELIOSISCSICBC
            PHEBCASINAFBEBC
            LINAHESCNHEF
            SNCBCACABC"""))
    @test description(first(filter(all_identical, results))) == "Can be completely broken down into chemical element symbols"
end
