using Wordle
using Dates
using TOML
using SHA


package_version = begin
    TOML.parsefile(joinpath(@__DIR__(), "..", "..", "Project.toml"))["version"]
end

data = Dict(
    "version" => package_version,
    "wordle" => Wordle.LATEST_WORDLE_NUMBER,
    "data" => Dict(
        "known-wordles" => join(Wordle.WORDLE_LIST, ',') |> sha256 |> bytes2hex,
        "valid-words" => join(Wordle.VALID_WORD_LIST, ',') |> sha256 |> bytes2hex,
    )
)

open(joinpath(@__DIR__(), "..", "Data.toml"), "w") do io
    TOML.print(io, data)
end
