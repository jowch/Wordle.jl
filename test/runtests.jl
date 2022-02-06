using Wordle
using Test
using TOML
using SHA
using Suppressor


data = TOML.parsefile(joinpath(@__DIR__(), "Data.toml"))

@testset "Wordle" begin
    include("fetch.jl")
    include("game.jl")
    include("guess.jl")
end