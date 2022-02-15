# Wordle.jl

<img src="https://pbs.twimg.com/media/FK30JPXVQAM2rKo?format=jpg&name=medium" alt="pretty-repl-example">

Do you love Wordle? Do you live in the Julia REPL? Well now you can play Wordle in your REPL!

## What is Wordle?

[Wordle](https://www.nytimes.com/games/wordle/index.html) is a daily word guessing game where the objective is to guess the daily, five-letter "wordle" within six guesses. Each time you make a guess, you are given the following feedback:
- Letters that are in the correct position will be highlighted in green;
- Letters that are in the wordle but not in the correct position are highlighted in yellow;
- And, the rest are highlighted in gray.

Here are the instructions from the [game](https://www.nytimes.com/games/wordle/index.html):
![instructions-screenshot](https://images.squarespace-cdn.com/content/v1/50eca855e4b0939ae8bb12d9/80a523b2-edff-41ac-8a9e-d515285a0b74/How+to+play+original+Wordle.png?format=1000w)

The game went viral as friends would compete with each other to see who could guess the wordle with the fewest number of guesses.

## Fetching the Word Lists

It turns out that the full lists of valid words and wordles can be found in the game source code. Once extracted, we will be able to use these lists of words to do all sorts of fun stuff. Each time you load the package `using Wordle`, we download the list of words and only keep the ones that have been seen before (include today's; beware!).

However, we should take care in the way we do this extraction to avoid spoilers. Ideally, the code we write to do this extraction requires no explicit knowledge of past or future wordles. In this way, no wordles are specifically "hard-coded" into the extraction routines.


## Getting Started
At the moment, this package hasn't been published yet, but you can still play
around with it!
```julia
julia> ] add https://github.com/jowch/Wordle.jl.git
```

## Usage

### Play the daily Wordle
```julia
julia> game = WordleGame()
Wordle 231 0/6
```

### Play past Wordles
```julia
julia> game = WordleGame(1)
Wordle 1 0/6
```

### Play with your own word
```julia
julia> game = WordleGame("words")
Wordle 0/6

julia> guess!(game, "bored")
Wordle 1/6

⬛️🟩🟩⬛️🟨

julia> print_available_letters(game)
a b c d e f g h i j k l m n o p q r s t u v w x y z
⬜⬛️⬜🟨⬛️⬜⬜⬜⬜⬜⬜⬜⬜⬜🟩⬜⬜🟩⬜⬜⬜⬜⬜⬜⬜⬜
```

## Advanced Usage
The list of all valid words is also provided within this package for "research" purposes.
```julia
julia> Wordle.VALID_WORD_LIST
10657-element Vector{String}:
 ⋮
 # no spoilers!

julia> Wordle.WORDLE_LIST
231-element Vector{String}:
 ⋮
 # also no spoilers!
```
