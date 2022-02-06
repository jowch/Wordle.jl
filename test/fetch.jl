
@testset "Download Wordles" begin
    digest_wordle_number = data["wordle"]
    wordles, valid_words = Wordle.download_word_lists()

    @test begin
        wordle_digest = join(wordles[1:digest_wordle_number], ',') |> sha256 |> bytes2hex
        wordle_digest == data["data"]["known-wordles"]
    end

    @test begin
        wordle_digest = join(valid_words, ',') |> sha256 |> bytes2hex
        wordle_digest == data["data"]["valid-words"]
    end
end
