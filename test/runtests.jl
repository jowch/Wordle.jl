using Wordle
using Test

tests = [
]

@testset "Wordle" begin
    for t in tests
        @info "Testing $t"
        tp = joinpath(dirname(@__FILE__), "$(t).jl")
        include(tp)
    end
end