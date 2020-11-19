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
        if value == val then
            return true
        end
    end

    return false
end

-- Will return the index of the card that should be replaced, OR -1 if nothing should be replaced. Gap is to prevent it from always changing card to gain 1 point
-- TODO: If the pile card is a king or joker, could it be "worth" to discard a flipped card?
function helpers.defineBestAction(board, pile, gap) 
    bestIndex = -1
    bestScore = helpers.getScore(board) - gap

    for index,value in ipairs(board) do
        tempBoard = table.clone(board)
        table.remove( tempBoard, index)
        table.insert( tempBoard, pile)
        
        tempScore = helpers.getScore(tempBoard)
        print("Current temp Score ".. tempScore.. " with index "..index)
        if (tempScore < bestScore) then
            bestScore = tempScore
            bestIndex = index
        end
    end

    return bestIndex
end

function table.clone(org)
    return {unpack(org)} -- use table.unpack when running tests.
end

return helpers