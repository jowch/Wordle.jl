module Wordle

import Base: show, ∈

using Dates
using HTTP

export

# game
WordleGame, nguess, guess, guess!,
available_letters, print_available_letters


const CORRECT, PRESENT, INCORRECT, UNGUESSED = :🟩, :🟨, :⬛️, :⬜
const WORDLE_URL = "https://www.powerlanguage.co.uk/wordle/"
const WORDLE_START_DATE = Date(2021, 6, 19)


include("guess.jl")
include("game.jl")
include("fetch.jl")

function __init__()
    global LATEST_WORDLE_NUMBER = today() - WORDLE_START_DATE |> Dates.value
    global WORDLE_LIST, VALID_WORD_LIST = download_word_lists()
end

end # module
