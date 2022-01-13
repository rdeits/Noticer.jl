function normalize(phrase)
    replace(lowercase(phrase), r"[^a-z]" => "")
end

const WORDS = Set{String}(normalize.(open(readlines, joinpath(@__DIR__, "../data/113809of.fic"))))
open("/usr/share/dict/words") do f
    for line in readlines(f)
        push!(WORDS, normalize(line))
    end
end

const LETTER_TALLIES = Set{LetterTallies}(LetterTallies.(WORDS))

const VOWELS = Set{Char}("aeiouy")
const CONSONANTS = Set{Char}("bcdfghjklmnpqrstvwxyz")

const SCRABBLE_SCORES = Dict{Char, Int}(
    'e' => 1,
    'a' => 1,
    'i' => 1,
    'o' => 1,
    'n' => 1,
    'r' => 1,
    't' => 1,
    'l' => 1,
    's' => 1,
    'u' => 1,
    'd' => 2,
    'g' => 2,
    'b' => 3,
    'c' => 3,
    'm' => 3,
    'p' => 3,
    'f' => 4,
    'h' => 4,
    'v' => 4,
    'w' => 4,
    'y' => 4,
    'k' => 5,
    'j' => 8,
    'x' => 8,
    'q' => 10,
    'z' => 10,
    )

const ELEMENT_DATA = readdlm(joinpath(@__DIR__, "..", "data", "elements.tsv"), '\t', String, skipstart=1)
const ELEMENTAL_SYMBOLS = lowercase.(strip.(ELEMENT_DATA[:,2]))
const STATES_DATA = readdlm(joinpath(@__DIR__, "..", "data", "states.tsv"), '\t', String, skipstart=1)
const STATE_ABBREVIATIONS = strip.(lowercase.(STATES_DATA[:,2]))

struct PreprocessedWord
    word::String
    characters::Vector{Char}
    tallies::LetterTallies

    PreprocessedWord(word) = new(word, collect(word), LetterTallies(word))
end

Base.length(w::PreprocessedWord) = length(w.characters)
Base.getindex(w::PreprocessedWord, i) = getindex(w.characters, i)
Base.firstindex(w::PreprocessedWord) = firstindex(w.characters)
Base.lastindex(w::PreprocessedWord) = lastindex(w.characters)
LetterTallies(w::PreprocessedWord) = w.tallies
Base.iterate(w::PreprocessedWord, args...) = iterate(w.characters, args...)
Base.reverse(w::PreprocessedWord) = PreprocessedWord(reverse(w.word))
Base.occursin(x, w::PreprocessedWord) = occursin(x, w.word)
Base.count(r::AbstractPattern, w::PreprocessedWord) = count(r, w.word)

scrabble_score(word) = sum(c -> SCRABBLE_SCORES[c], word)

num_unique_vowels(word) = count(in(word), VOWELS)

num_unique_consonants(word) = count(in(word), CONSONANTS)

num_consonants(word) = count(in(CONSONANTS), word)

num_vowels(word) = count(in(VOWELS), word)

num_unique_letters(word) = count(in(word), 'a':'z')

num_double_letters(word) = count(i -> word[i] == word[i + 1], 1:(length(word) - 1))

num_alpha_bigrams(word) = count(i -> word[i] < word[i + 1], 1:(length(word) - 1))

num_reverse_alpha_bigrams(word) = count(i -> word[i] > word[i + 1], 1:(length(word) - 1))

num_sequential_bigrams(word) = count(i -> word[i] + 1 == word[i + 1], 1:(length(word) - 1))

num_reverse_sequential_bigrams(word) = count(i -> word[i] - 1 == word[i + 1], 1:(length(word) - 1))

num_cardinal_directions(word) = count(in(('n', 'e', 's', 'w')), word)

function is_sequential(a::AbstractArray)
    for i in 1:(length(a) - 1)
        a[i+1] == a[i] + 1 || return false
    end
    true
end

"""
Letter tally is 1, 2, 3, etc.
"""
is_pyramid(word) = is_sequential(sort(filter(!iszero, LetterTallies(word).tallies)))

"""
Letters are alpha, then reverse alpha
"""
function is_hill(word)
    has_rise = false
    has_fall = false
    rising = true
    for i in 1:(length(word) - 1)
        if word[i + 1] > word[i]
            if !rising
                return false
            end
            has_rise = true
        elseif word[i + 1] < word[i]
            rising = false
            has_fall = true
        end
    end
    has_rise && has_fall
end

"""
Letters are reverse alpha, then alpha
"""
function is_valley(word)
    has_rise = false
    has_fall = false
    rising = false
    for i in 1:(length(word) - 1)
        if word[i + 1] < word[i]
            if rising
                return false
            end
            has_fall = true
        elseif word[i + 1] > word[i]
            rising = true
            has_rise = true
        end
    end
    has_rise && has_fall
end

has_transaddition(t::LetterTallies, c::Char) = (t + c) in LETTER_TALLIES
has_transaddition(t::LetterTallies) = any(c -> has_transaddition(t, c), 'a':'z')

has_transdeletion(t::LetterTallies, c::Char) = (t - c) in LETTER_TALLIES
has_transdeletion(t::LetterTallies) = any(c -> has_transdeletion(t, c), 'a':'z')

is_palindrome(word) = word == reverse(word)

num_repeated_letters(word) = count(>(1), LetterTallies(word).tallies)

num_letters_repeated_n_times(word, n) = count(==(n), LetterTallies(word).tallies)

parenwrap(s) = "($s)"
const SINGLE_ELEMENT_REGEX = Regex("$(join((parenwrap(s) for s in ELEMENTAL_SYMBOLS), '|'))")
const ENTIRELY_ELEMENTS_REGEX = Regex("^($(join((parenwrap(s) for s in ELEMENTAL_SYMBOLS), '|')))*\$")

const SINGLE_STATE_REGEX = Regex("$(join((parenwrap(s) for s in STATE_ABBREVIATIONS), '|'))")
const ENTIRELY_STATES_REGEX = Regex("^($(join((parenwrap(s) for s in STATE_ABBREVIATIONS), '|')))*\$")

struct Feature
    f::Function
    description::String
end

description(feature::Feature) = feature.description

function all_features()
    features = Feature[]
    for char in 'a':'z'
        push!(features, Feature(w -> count(isequal(char), w), "Number of occurrences of '$char'"))
        # push!(features, Feature(w -> char in w, "Contains '$char'"))
    end

    for i in 1:5
        push!(features, Feature("Character at index $i") do word
            if length(word) >= i
                word[i] - 'a' + 1
            else
                0
            end
        end)
        push!(features, Feature("Character at index $i from the end") do word
            if length(word) >= i
                word[end - i + 1] - 'a' + 1
            else
                0
            end
        end)
    end

    # for char in 'a':'z'
    #     for i in 1:5
    #         push!(features, Feature(w -> length(w) >= i && w[i] == char, "Has '$char' at index $i"))
    #         push!(features, Feature(w -> length(w) >= i && w[end - i + 1] == char, "Has '$char' at index $i from the end"))
    #     end
    # end

    push!(features, Feature(scrabble_score, "Scrabble score"))
    push!(features, Feature(num_vowels, "Number of vowels"))
    push!(features, Feature(num_consonants, "Number of consonants"))
    push!(features, Feature(num_unique_vowels, "Number of unique vowels"))
    push!(features, Feature(num_unique_consonants, "Number of unique consonants"))
    push!(features, Feature(num_unique_letters, "Number of unique letters"))
    push!(features, Feature(num_double_letters, "Number of double letters"))
    push!(features, Feature(num_alpha_bigrams, "Number of alphabetical bigrams"))
    push!(features, Feature(num_reverse_alpha_bigrams, "Number of reverse alphabetical bigrams"))
    push!(features, Feature(num_sequential_bigrams, "Number of sequential bigrams"))
    push!(features, Feature(num_reverse_sequential_bigrams, "Number of reverse sequential bigrams"))
    push!(features, Feature(num_cardinal_directions, "Number of cardinal directions (NESW)"))
    push!(features, Feature(num_repeated_letters, "Number of repeated letters"))
    for n in 2:3
        push!(features, Feature("Number of letters repeated at least $n times") do word
            count(>=(n), LetterTallies(word).tallies)
        end)
    end
    push!(features, Feature("Number of repeated vowels") do word
        tallies = LetterTallies(word).tallies
        count(VOWELS) do char
            tallies[char - 'a' + 1] > 1
        end
    end)
    push!(features, Feature("Number of repeated consonants") do word
        tallies = LetterTallies(word).tallies
        count(CONSONANTS) do char
            tallies[char - 'a' + 1] > 1
        end
    end)

    push!(features, Feature(is_palindrome, "Is a palindrome"))
    push!(features, Feature(is_hill, "Is a hill word"))
    push!(features, Feature(is_valley, "Is a valley word"))
    push!(features, Feature(is_pyramid, "Is a pyramid word"))

    push!(features, Feature(word -> occursin(ENTIRELY_ELEMENTS_REGEX, word), "Can be completely broken down into chemical element symbols"))
    push!(features, Feature(word -> occursin(ENTIRELY_STATES_REGEX, word), "Can be completely broken down into US state abbreviations"))
    push!(features, Feature(word -> count(SINGLE_STATE_REGEX, word), "Number of US state abbreviations"))
    push!(features, Feature(word -> count(SINGLE_ELEMENT_REGEX, word), "Number of chemical element symbols"))

    for char in 'a':'z'
        push!(features, Feature(w -> has_transaddition(LetterTallies(w), char), "Has a transaddition with letter '$char'"))
    end
    push!(features, Feature(w -> has_transaddition(LetterTallies(w)), "Has a 1-letter transaddition"))

    for char in 'a':'z'
        push!(features, Feature(w -> has_transdeletion(LetterTallies(w), char), "Has a transdeletion with letter '$char'"))
    end
    push!(features, Feature(w -> has_transdeletion(LetterTallies(w)), "Has a 1-letter transdeletion"))

    features
end

