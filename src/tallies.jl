struct LetterTallies
    tallies::SVector{26, Int8}

    LetterTallies(tallies::AbstractVector) = new(tallies)

    function LetterTallies(word::AbstractString)
        data = zero(SVector{26, Int8})
        for char in word
            index = char - 'a' + 1
            data = setindex(data, data[index] + 1, index)
        end
        new(data)
    end
end

function Base.:+(t::LetterTallies, c::Char)
    index = c - 'a' + 1
    LetterTallies(setindex(t.tallies, t.tallies[index] + 1, index))
end

function Base.:-(t::LetterTallies, c::Char)
    index = c - 'a' + 1
    LetterTallies(setindex(t.tallies, t.tallies[index] - 1, index))
end

