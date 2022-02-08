
@testset "Game" begin
    @test all(hasfield.(WordleGame, [:target, :number, :guesses]))

    @testset "Contructors" begin
        @testset "Valid Inputs" begin
            # target word must be in wordle list or in list of valid guesses
            @test_throws ErrorException WordleGame("aaaaa")
            @test_throws ErrorException WordleGame("AAAAA")

            # valid target word can be specified in capitalization agnostic form
            @test typeof(WordleGame("words")) == WordleGame
            @test typeof(WordleGame("Words")) == WordleGame
            @test typeof(WordleGame("WORDS")) == WordleGame
            @test typeof(WordleGame("wOrDs")) == WordleGame

            # target word must be five letters long
            @test typeof(WordleGame("words")) == WordleGame
            @test_throws ErrorException WordleGame("a")
            @test_throws ErrorException WordleGame("aaaaaaa")
            @test_throws ErrorException WordleGame("")
            
            # number can be specified
            @test typeof(WordleGame("words", 1, Wordle.WordleGuess[])) == WordleGame
           
            # 0 < number < LATEST_WORDLE_NUMBER
            @test_throws ErrorException WordleGame("words", 0, Wordle.WordleGuess[])
            @test_throws ErrorException WordleGame("words", -1, Wordle.WordleGuess[])
            @test begin
                typeof(WordleGame("words", Wordle.LATEST_WORDLE_NUMBER,
                                  Wordle.WordleGuess[])) == WordleGame
            end
            @test_throws ErrorException begin
                WordleGame("words", Wordle.LATEST_WORDLE_NUMBER + 1,
                           Wordle.WordleGuess[])
            end

            # number of guesses cannot be more than six
            for i = 1:7
                🤔 = Wordle.WordleGuess("words", fill(Wordle.CORRECT, 5))

                if i > 6
                    @test_throws ErrorException WordleGame("words", nothing, fill(🤔, i))
                else
                    @test @suppress typeof(WordleGame("words", nothing, fill(🤔, i))) == WordleGame
                end
            end
        end

        @testset "Convenience Constructors" begin
            @testset "Specify WordleGame by Wordle Number" begin
                @test typeof(WordleGame(1)) == WordleGame            

                game = WordleGame(1)
                @test game.target == first(Wordle.WORDLE_LIST)
                @test game.number == 1
            end

            @testset "Daily Wordle" begin
                @test typeof(WordleGame()) == WordleGame            

                game = WordleGame()
                also_game = WordleGame(Wordle.LATEST_WORDLE_NUMBER)

                @test game.target == also_game.target
                @test game.number == also_game.number
            end
        end

        @testset "Display" begin
            game = WordleGame("words")

            @test (@capture_out print(game)) == "Wordle 0/6"

            # make a really bad guess
            guess!(game, "quiet")

            @test begin
                (@capture_out print(game)) == strip("""
                Wordle 1/6

                ⬛️⬛️⬛️⬛️⬛️
                """)
            end

            # make a guess a present letter
            guess!(game, "dodge")

            @test begin
                (@capture_out print(game)) == strip("""
                Wordle 2/6
                
                ⬛️⬛️⬛️⬛️⬛️
                🟨🟩⬛️⬛️⬛️
                """)
            end

            # make a guess with two of the same, present letters. Should only
            # get feedback for one of the two.
            guess!(game, "looks")

            @test begin
                (@capture_out print(game)) == strip("""
                Wordle 3/6
                
                ⬛️⬛️⬛️⬛️⬛️
                🟨🟩⬛️⬛️⬛️
                ⬛️🟩⬛️⬛️🟩
                """)
            end
            
            # make a guess that changes a known letter to a correct letter
            guess!(game, "lords")

            @test begin
                (@capture_out print(game)) == strip("""
                Wordle 4/6
                
                ⬛️⬛️⬛️⬛️⬛️
                🟨🟩⬛️⬛️⬛️
                ⬛️🟩⬛️⬛️🟩
                ⬛️🟩🟩🟩🟩
                """)
            end

            # make a guess the word!
            guess!(game, "words")

            @test begin
                (@capture_out print(game)) == strip("""
                Wordle 5/6
                
                ⬛️⬛️⬛️⬛️⬛️
                🟨🟩⬛️⬛️⬛️
                ⬛️🟩⬛️⬛️🟩
                ⬛️🟩🟩🟩🟩
                🟩🟩🟩🟩🟩
                """)
            end
        end

        @testset "Guesses" begin
            game = WordleGame("words")

            for i = 1:6
                @test guess!(game, "bored") !== nothing
            end

            # can't guess more than 6 times
            @test_throws ErrorException guess!(game, "bored")

            # can't guess after target has been guessed
            game = WordleGame("words")
            @test @suppress guess!(game, "words") !== nothing
            @test_throws ErrorException guess!(game, "bored")

            game = WordleGame("seams")
            # if n is the number of times a letter appears in a wordle and a
            # guess has >n occurrences of that letter, only the first n occurrences
            # have feedback
            @test @capture_out(print(guess(game, "sissy"))) == "🟩⬛️🟨⬛️⬛️"
            @test @capture_out(print(guess(game, "beams"))) == "⬛️🟩🟩🟩🟩"
        end


        @testset "Hard Mode" begin
            game = WordleGame("words"; hard = true)
            guess!(game, "bored")
            
            # if in hard mode, your next guess must contain the letters you know
            # are in the wordle
            @test_throws ErrorException guess!(game, "cubic")
            @test typeof(guess!(game, "cords")) == WordleGame

            game = WordleGame("words")
            guess!(game, "bored")

            # but this sequences of guesses should be allowed in regular mode.
            @test typeof(guess!(game, "cubic")) == WordleGame
        end


        @testset "Available Letters" begin
            game = WordleGame("words")
            @test available_letters(game) == fill(Wordle.UNGUESSED, 26)
            @test (@capture_out print_available_letters(game)) == """
            a b c d e f g h i j k l m n o p q r s t u v w x y z
            ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
            """

            # printing available letters uses available letters and happens to
            # be a bit more compact so we will use its outputs as a surrogate
            guess!(game, "quiet")
            @test (@capture_out print_available_letters(game)) == """
            a b c d e f g h i j k l m n o p q r s t u v w x y z
            ⬜⬜⬜⬜⬛️⬜⬜⬜⬛️⬜⬜⬜⬜⬜⬜⬜⬛️⬜⬜⬛️⬛️⬜⬜⬜⬜⬜
            """

            guess!(game, "dodge")
            @test (@capture_out print_available_letters(game)) == """
            a b c d e f g h i j k l m n o p q r s t u v w x y z
            ⬜⬜⬜🟨⬛️⬜⬛️⬜⬛️⬜⬜⬜⬜⬜🟩⬜⬛️⬜⬜⬛️⬛️⬜⬜⬜⬜⬜
            """

            # if the outcome for a letter in a given guess is present but it
            # was previously correct, then it should still be marked as
            # correct in this list
            guess!(game, "quiet")
            @test (@capture_out print_available_letters(game)) == """
            a b c d e f g h i j k l m n o p q r s t u v w x y z
            ⬜⬜⬜🟨⬛️⬜⬛️⬜⬛️⬜⬜⬜⬜⬜🟩⬜⬛️⬜⬜⬛️⬛️⬜⬜⬜⬜⬜
            """

            # let's test going from "present" to "correct"
            guess!(game, "woods")
            @test (@capture_out print_available_letters(game)) == """
            a b c d e f g h i j k l m n o p q r s t u v w x y z
            ⬜⬜⬜🟩⬛️⬜⬛️⬜⬛️⬜⬜⬜⬜⬜🟩⬜⬛️⬜🟩⬛️⬛️⬜🟩⬜⬜⬜
            """
        end

        @testset "Utility Functions" begin
            game = WordleGame("words")
            
            @test Wordle.target(game) == "words"
            @test nguess(game) == 0

            for i = 1:6
                guess!(game, "bored")
                @test nguess(game) == i
                @test "bored" ∈ game
            end
        end

    end
end
