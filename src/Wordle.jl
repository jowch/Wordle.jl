module Wordle

import Base: show, ∈

using Crayons.Box
using Dates
using HTTP
using REPL

export

# game
WordleGame, nguess, guess, guess!,
available_letters, print_available_letters


const CORRECT, PRESENT, INCORRECT, UNGUESSED = :🟩, :🟨, :⬛️, :⬜
const WORDLE_URL = "https://www.nytimes.com/games/wordle"
const WORDLE_START_DATE = Date(2021, 6, 19)

include("util.jl")
include("guess.jl")
include("game.jl")
include("fetch.jl")

function __init__()
    global LATEST_WORDLE_NUMBER = today() - WORDLE_START_DATE |> Dates.value
    global WORDLE_LIST, VALID_WORD_LIST = download_word_lists()
    if isinteractive()
        global IN_REPL = isinteractive()
        global REPL_HAS_COLOR = REPL.hascolor(Base.active_repl)
    end
end

end # module
