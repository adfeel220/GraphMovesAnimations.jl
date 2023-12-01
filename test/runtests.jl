using GraphMovesAnimations
using Test
using Aqua
using JET
using JuliaFormatter

@testset verbose = true "GraphMovesAnimations.jl" begin
    @testset "Code formatting" begin
        @test format(GraphMovesAnimations; verbose=false, overwrite=false)
    end

    if VERSION >= v"1.9"
        @testset "Code quality (Aqua.jl)" begin
            Aqua.test_all(GraphMovesAnimations; ambiguities=false)
        end
        @testset "Code linting (JET.jl)" begin
            JET.test_package(GraphMovesAnimations; target_defined_modules=true)
        end
    end
end
