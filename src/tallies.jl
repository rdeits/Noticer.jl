struct LetterTallies
    tallies::SVector{26, Int8}
    hash::UInt

    LetterTallies(tallies::AbstractVector{<:Number}) = new(tallies, hash(tallies, UInt(0)))
end

function LetterTallies(word::Union{AbstractString, AbstractVector{<:Char}})
    data = zero(SVector{26, Int8})
    for char in word
        index = char - 'a' + 1
        data = setindex(data, data[index] + 1, index)
    end
    LetterTallies(data)
end

function Base.:+(t::LetterTallies, c::Char)
    index = c - 'a' + 1
    LetterTallies(setindex(t.tallies, t.tallies[index] + 1, index))
end

function Base.:-(t::LetterTallies, c::Char)
    index = c - 'a' + 1
    LetterTallies(setindex(t.tallies, t.tallies[index] - 1, index))
end

Base.:(==)(t1::LetterTallies, t2::LetterTallies) = t1.tallies == t2.tallies
Base.hash(t::LetterTallies, h::UInt) = hash(t.hash, h)
