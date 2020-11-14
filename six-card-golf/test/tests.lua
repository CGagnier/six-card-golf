helpers = require("helpers")

hand1 = {
    { suit = 'joker', rank = 1, flipped = false},
    { suit = 'heart', rank = 1, flipped = false},
    { suit = 'spade', rank = 3, flipped = false},
    { suit = 'spade', rank = 13, flipped = false},
    { suit = 'club', rank = 1, flipped = false},
    { suit = 'diamond', rank = 4, flipped = false},
}

hand2 = {
    { suit = 'spade', rank = 4, flipped = false},
    { suit = 'heart', rank = 5, flipped = false},
    { suit = 'spade', rank = 6, flipped = false},
    { suit = 'spade', rank = 7, flipped = false},
    { suit = 'club', rank = 1, flipped = false},
    { suit = 'diamond', rank = 4, flipped = false},
}

assert(helpers.getScore(hand1) == 2, "Test on Jokers and Kings failed")
assert(helpers.getScore(hand2) == 19, "Test on regular card failed")