function normalize(phrase)
    replace(lowercase(phrase), r"[^a-z ]" => "")
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

scrabble_score(char::Char) = SCRABBLE_SCORES[char]

scrabble_score(word::String) = sum(scrabble_score, word)

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

struct Feature
    f::Function
    description::String
end

function all_features()
    features = Feature[]
    for char in 'a':'z'
        push!(features, Feature(w -> count(isequal(char), w), "Number of occurrences of '$char'"))
        # push!(features, Feature(w -> char in w, "Contains '$char'"))
    end
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
    push!(features, Feature(is_palindrome, "Is a palindrome"))
    push!(features, Feature(is_hill, "Is a hill word"))
    push!(features, Feature(is_valley, "Is a valley word"))

    # for char in 'a':'z'
    #     push!(features, Feature(w -> has_transaddition(LetterTallies(w), char), "Has a transaddition with letter '$char'"))
    # end
    push!(features, Feature(w -> has_transaddition(LetterTallies(w)), "Has a 1-letter transaddition"))

    # for char in 'a':'z'
    #     push!(features, Feature(w -> has_transdeletion(LetterTallies(w), char), "Has a transdeletion with letter '$char'"))
    # end
    push!(features, Feature(w -> has_transdeletion(LetterTallies(w)), "Has a 1-letter transdeletion"))

    features
end

