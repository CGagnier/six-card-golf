helpers = require("helpers")

hand1 = {
    { suit = 'joker', rank = 0, flipped = true},
    { suit = 'heart', rank = 1, flipped = true},
    { suit = 'spade', rank = 3, flipped = true},
    { suit = 'spade', rank = 13, flipped = true},
    { suit = 'club', rank = 1, flipped = true},
    { suit = 'diamond', rank = 4, flipped = true},
}

hand2 = {
    { suit = 'spade', rank = 4, flipped = true},
    { suit = 'heart', rank = 5, flipped = true},
    { suit = 'spade', rank = 6, flipped = true},
    { suit = 'spade', rank = 7, flipped = true},
    { suit = 'club', rank = 1, flipped = true},
    { suit = 'diamond', rank = 4, flipped = true},
}

pile1 = { suit = 'joker', rank = 0, flipped = true}
pile2 = { suit = 'club', rank = 6, flipped = true}
pile3 = { suit = 'club', rank = 11, flipped = true}

assert(helpers.getScore(hand1) == 2, "Test on Jokers and Kings failed")
assert(helpers.getScore(hand2) == 19, "Test on regular card failed")
assert(helpers.defineBestAction(hand1,pile1,0) == 6, "Test on best action with joker failed")
assert(helpers.defineBestAction(hand2,pile2,0) == 4, "Test on best action with duplicate failed")
assert(helpers.defineBestAction(hand2,pile3,0) == -1, "Test on best action without any better action")