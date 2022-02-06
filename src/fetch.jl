"""
    download_word_lists()

Downloads and parses Wordle game code for word lists. Returns the list of known
Wordles and the list of valid words.

**Important!** This function will never return future Wordles to prevent
*spoilers (even though they are present in the game code).

# Examples

```julia-repl
wordles, valid_words = download_word_lists()
```
"""
function download_word_lists()
    js_url = let
        html = HTTP.request(:GET, WORDLE_URL).body |> String

        filename = match(r"src=\"(main.\w+.js)\"", html) |> only
        joinpath(WORDLE_URL, filename)
    end

    js = replace(HTTP.request(:GET, js_url).body |> String, "\n" => "")

    # find array of words
    matches = eachmatch(r"\[([\"\w,]+)\]", js) |> collect .|> only .|> String
    matches = replace.(matches, "\"" => "")
    matches = split.(matches, ',')

    # There are several arrays in the game source, but there are two criteria we
    # can use to identify the list answers. First, the number of words in the
    # list must be longer than the number of wordles we've had. Second, the list
    # of words is not in alphabetical order. I happen to know that the first
    # five words are enough to tell if the word list is in alphabetical order.
    target_lists = begin
        lists = filter(matches) do candidate_list
            length(candidate_list) > LATEST_WORDLE_NUMBER
        end
        
        map(lists) do list
            string.(list)
        end
    end

    is_sorted = map(target_lists) do list
        first_five = list[1:5]
        all(sort(first_five) .== first_five)
    end

    valid_words = target_lists[findall(is_sorted) |> only]

    # the original game code started with the second word in the list
    wordles = target_lists[findall(.!(is_sorted)) |> only][2:LATEST_WORDLE_NUMBER + 1]

    wordles, valid_words
end
