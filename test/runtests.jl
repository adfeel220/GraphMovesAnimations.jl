using GraphMovesAnimations
using Test
using Aqua
using JET

@testset "GraphMovesAnimations.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(GraphMovesAnimations)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(GraphMovesAnimations; target_defined_modules = true)
    end
    # Write your tests here.
end
