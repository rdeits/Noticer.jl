struct Feature
    f::Function
    description::String
end


function scrabble_score(word::String)
    score = 0
    for c in word
        score += scrabble_score(c)
    end
    score
end

scrabble_score(char::Char) = SCRABBLE_SCORES[char]

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

const VOWELS = Set{Char}("aeiouy")
const CONSONANTS = Set{Char}("bcdfghjklmnpqrstvwxyz")

num_unique_vowels(word) = count(in(word), VOWELS)

num_unique_consonants(word) = count(in(word), CONSONANTS)

num_unique_letters(word) = count(in(word), 'a':'z')

num_double_letters(word) = count(i -> word[i] == word[i + 1], 1:(length(word) - 1))

num_alpha_bigrams(word) = count(i -> word[i] < word[i + 1], 1:(length(word) - 1))

num_reverse_alpha_bigrams(word) = count(i -> word[i] > word[i + 1], 1:(length(word) - 1))

num_sequential_bigrams(word) = count(i -> word[i] + 1 == word[i + 1], 1:(length(word) - 1))

num_reverse_sequential_bigrams(word) = count(i -> word[i] - 1 == word[i + 1], 1:(length(word) - 1))

num_cardinal_directions(word) = count(in(('n', 'e', 's', 'w')), word)

function all_features()
    features = Feature[]
    for char in 'a':'z'
        push!(features, Feature(w -> count(isequal(char), w), "Number of occurrences of '$char'"))
    end
    push!(features, Feature(w -> scrabble_score(w), "Scrabble score"))
    push!(features, Feature(w -> num_unique_vowels(w), "Number of unique vowels"))
    push!(features, Feature(w -> num_unique_consonants(w), "Number of unique consonants"))
    push!(features, Feature(w -> num_unique_letters(w), "Number of unique letters"))
    push!(features, Feature(w -> num_double_letters(w), "Number of double letters"))
    push!(features, Feature(w -> num_alpha_bigrams(w), "Number of alphabetical bigrams"))
    push!(features, Feature(w -> num_reverse_alpha_bigrams(w), "Number of reverse alphabetical bigrams"))
    push!(features, Feature(w -> num_sequential_bigrams(w), "Number of sequential bigrams"))
    push!(features, Feature(w -> num_reverse_sequential_bigrams(w), "Number of reverse sequential bigrams"))
    push!(features, Feature(w -> num_cardinal_directions(w), "Number of cardinal directions (NESW)"))
    features
end

