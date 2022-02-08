using DataStructures: SortedSet

"""
    WordleGame

A struct tracking the state of a game of Wordle.
"""
struct WordleGame
    target::String
    number::Union{Int, Nothing}
    guesses::Vector{WordleGuess}
    hard::Bool

    function WordleGame(target::String, number::Union{Int, Nothing} = nothing,
               guesses::Vector{WordleGuess} = WordleGuess[]; hard = false)

        target = lowercase(target)

        if target ∉ VALID_WORD_LIST
            error("""Target word "$target" is not a valid word""")
        end

        if !isnothing(number) && !(0 < number <= LATEST_WORDLE_NUMBER)
            error("Given Wordle number is too large ($number).")
        end

        if length(guesses) > 6
            error("There are too many guesses ($(length(guesses))")
        end

        new(target, number, guesses, hard)
    end
end

WordleGame(number::Int; hard = false) = WordleGame(WORDLE_LIST[number], number; hard = hard)
WordleGame(; hard = false) = WordleGame(LATEST_WORDLE_NUMBER; hard = hard)

nguess(game::WordleGame) = length(game.guesses)
target(game::WordleGame) = game.target

function show(io::IO, game::WordleGame)
    header = ["Wordle"]

    if !isnothing(game.number)
        print(io, "Wordle $(game.number) $(nguess(game))/6")
        push!(header, game.number)
    end

    if game.hard
        # add * for hard mode
        push!(header, "$(nguess(game))/6*")
    else
        push!(header, "$(nguess(game))/6")
    end

    print(io, join(header, ' '))

    if nguess(game) > 0
        println(io)
        println(io)

        for (i, guess) in enumerate(game.guesses)
            if i < nguess(game)
                println(guess)
            else
                print(guess)
            end
        end
    end
end

function (∈)(word::String, game::WordleGame)
    word in getproperty.(game.guesses, :guess)
end

function guess(game::WordleGame, word::String)
    word = lowercase(word)

    if length(word) > 5 || word ∉ VALID_WORD_LIST
        error("$word is not a valid guess")
    end

    if target(game) ∈ game
        error("The game is already over!")
    end

    if game.hard
        letter_outcomes = available_letters(game)

        # might need to account for multiple occurrences of a letter
        required = Set(filter('a':'z') do l
            index = l - 'a' + 1
            letter_outcomes[index] ∈ (CORRECT, PRESENT)
        end)

        if !all(occursin.(required, word))
            error("Invalid guess for hard mode.")
        end
    end

    # initialize a results array to be all incorrect
    results = fill(INCORRECT, 5)

    # we only need to consider letters that are present in both target and guess
    for m in intersect(target(game), word)
        # find the sets of positions for each matched letter
        target_positions = SortedSet(findall(m, target(game)))
        guess_positions = SortedSet(findall(m, word))

        # for each exactly matching position, mark the letter as correct and
        # remove the position from the position sets
        for correct_position in intersect(target_positions, guess_positions)
            results[correct_position] = CORRECT
            delete!(target_positions, correct_position)  
            delete!(guess_positions, correct_position)  
        end

        # pair off the remainining positions and mark them as present
        # zip will stop after the last pair.
        for (_, guess_position) in zip(target_positions, guess_positions)
            results[guess_position] = PRESENT
        end
    end

	WordleGuess(word, results)
end

function guess!(game::WordleGame, word::String)
    if nguess(game) == 6
        error("The game is already over!")
    end

    push!(game.guesses, guess(game, word))
    game
end

function available_letters(game::WordleGame)
    outcomes = [UNGUESSED for _ in 'a':'z']

    for guess in game.guesses
        for (outcome, letter) in zip(guess.result, guess.guess)
            letter_index = letter - 'a' + 1

            if outcome == CORRECT
                outcomes[letter_index] = CORRECT
            elseif outcome == PRESENT && outcomes[letter_index] != CORRECT
                # if the outcome for a letter in a given guess is present but it
                # was previously correct, then it should still be marked as
                # correct in this list
                outcomes[letter_index] = PRESENT
            else # incorrect
                if outcomes[letter_index] ∉ (CORRECT, PRESENT)
                    outcomes[letter_index] = INCORRECT
                end
            end
        end
    end

    outcomes
end

function print_available_letters(game::WordleGame)
    print("""
    $(join('a':'z', ' '))
    $(available_letters(game) |> join)
    """)
end
