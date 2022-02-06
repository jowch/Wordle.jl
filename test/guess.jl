
@testset "WordleGuess" begin
    WordleGuess = Wordle.WordleGuess

    @test all(hasfield.(Wordle.WordleGuess, [:guess, :result]))
    @test_throws ErrorException WordleGuess("", [:some, :random, :symbols])
    @test_throws ErrorException WordleGuess("", [:🟩, :🟩, :🟩])
    @test (@capture_out print(WordleGuess("", fill(Wordle.CORRECT, 5)))) == "🟩🟩🟩🟩🟩"
end
