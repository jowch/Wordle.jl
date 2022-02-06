
struct WordleGuess
    guess::String
    result::Vector{Symbol}

    WordleGuess(guess::String, result::Vector{Symbol}) = let 
        invalid_results = setdiff(result, [CORRECT, PRESENT, INCORRECT])

        if !isempty(invalid_results)
            message = strip("""
            The following result symbols are invalid: $(join(invalid_results .|> String, ", "))
            """)

            throw(ArgumentError(message))
        end

        new(guess, result)
    end
end

show(io::IO, guess::WordleGuess) = print(io, guess.result |> join)

# count(guess::WordleGuess)::NamedTuple{Symbol} = let 
#     outcomes = [CORRECT, PRESENT, INCORRECT]
#     counts = map(outcomes) do outcome
#         count(guess.result .== outcome)
#     end

#     (; zip(outcomes, counts)...)
# end
