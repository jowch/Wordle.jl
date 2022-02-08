const COLORMAP = Dict(
    CORRECT => GREEN_BG * WHITE_FG,
    PRESENT => YELLOW_BG * BLACK_FG,
    INCORRECT => BLACK_BG * WHITE_FG,
    UNGUESSED => DEFAULT_BG * DEFAULT_FG
)

function color_letters(letters, outcomes)
    join(map(zip(letters, outcomes)) do (l, outcome)
        BOLD * COLORMAP[outcome](" $(uppercase(l)) ")
    end)
end
