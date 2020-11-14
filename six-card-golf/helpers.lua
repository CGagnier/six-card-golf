local helpers = {}

function helpers.getScore(board)
    local score = 0
    local normalCard = {}

    -- Count jokers (-5) and kings (0) and add to the score
    for _, card in ipairs(board)
    do
        if (card.flipped) then 
            if (card.suit == 'joker') then
                score = score - 5
            elseif card.rank ~= 13 then
                table.insert(normalCard, card.rank )          
            end
        end
    end

    -- Now we iterate on the regular cards and skip duplicates
    table.sort( normalCard )
    for i = 1, #normalCard do
        if normalCard[i-1] ~= normalCard[i] and normalCard[i+1] ~= normalCard[i] then
            score = score + normalCard[i]
        end
    end

    return score
end

function helpers.hasValue (tab, val)
    for index, value in ipairs(tab) do
        print(value == val)
        if value == val then
            return true
        end
    end

    return false
end

return helpers