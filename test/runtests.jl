using Wordle
using Test
using TOML
using SHA
using Suppressor


data = TOML.parsefile(joinpath(@__DIR__(), "Data.toml"))

tests = [
    "fetch",
    "game"
]

@testset "Wordle" begin
    for t in tests
        @info "Testing $t"
        tp = joinpath(dirname(@__FILE__), "$(t).jl")
        include(tp)
    end
end