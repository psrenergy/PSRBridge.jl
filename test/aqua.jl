function test_aqua()
    @testset "Ambiguities" begin
        Aqua.test_ambiguities(PSRBridge, recursive = false)
    end
    Aqua.test_all(PSRBridge, ambiguities = false)

    return nothing
end
