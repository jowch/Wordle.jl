
struct WordleGuess
    guess::String
    result::Vector{Symbol}

    WordleGuess(guess::String, result::Vector{Symbol}) = let 
        invalid_results = setdiff(result, [CORRECT, PRESENT, INCORRECT])

        if !isempty(invalid_results)
            message = strip("""
            The following result symbols are invalid: $(join(invalid_results .|> String, ", "))
            """)

            error(message)
        end

        if length(result) != 5
            error("Results must have length 5")
        end

        new(guess, result)
    end
end

function show(io::IO, guess::WordleGuess)
    if IN_REPL && REPL_HAS_COLOR
        print(io, color_letters(guess.guess, guess.result))
    else # show emojis
        print(io, guess.result |> join)
    end
end
