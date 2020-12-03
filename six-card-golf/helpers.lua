local helpers = {}

function helpers.getScore(board, unflippedCardValue)
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
        else 
            score = score + (unflippedCardValue or 0)
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
function helpers.defineBestAction(board, pile, gap) 
    bestIndex = -1
    FLIPPED_VALUE = 6 -- 6 is approx the average or the sum of a new deck, could changed based on passed cards
    
    bestScore = helpers.getScore(board, FLIPPED_VALUE) - gap 

    for index,value in ipairs(board) do
        tempBoard = table.clone(board)
        table.remove( tempBoard, index)
        table.insert( tempBoard, pile)
        
        tempScore = helpers.getScore(tempBoard, FLIPPED_VALUE)
        if (tempScore < bestScore) then
            bestScore = tempScore
            bestIndex = index
        end
    end

    return bestIndex
end

-- Arrow keys helpers

function helpers.indexSwitch(pKey, up, down, right, left)
    if pKey == 'up' then
        return up
    elseif pKey == 'down' then
        return down
    elseif pKey == 'right' then
        return right
    else
        return left
    end
end

function helpers.fixIndex(pDrawnCard, pIndex)
    if (#pDrawnCard > 0) then
        if pIndex == 7 or pIndex == 8 then
            return 9
        end
    elseif pIndex == 9 then
        return 7
    end
    return pIndex
end

function helpers.handleArrowSelection(pKey,sIndex)
    newIndex = sIndex
    
    -- TODO: Refactor with images middle point coords
    if helpers.hasValue({'up','down','right','left'},pKey) then 
        if sIndex == 1 then
            newIndex = helpers.indexSwitch(pKey, sIndex, 2, 4, sIndex)
        elseif sIndex == 2 then
            newIndex = helpers.indexSwitch(pKey,1 ,3 ,5 ,sIndex)
        elseif sIndex == 3 then
            newIndex = helpers.indexSwitch(pKey,2 ,sIndex ,6 ,sIndex)
        elseif sIndex == 4 then
            newIndex = helpers.indexSwitch(pKey,sIndex ,5 ,7 ,1)
        elseif sIndex == 5 then
            newIndex = helpers.indexSwitch(pKey,4 ,6 ,7 ,2)
        elseif sIndex == 6 then
            newIndex = helpers.indexSwitch(pKey,5 ,sIndex ,7 ,3)
        elseif sIndex == 7 then -- Pile OR drawCard
            newIndex = helpers.indexSwitch(pKey,sIndex ,sIndex ,8 ,5)
        elseif sIndex == 8 then -- Discard
            newIndex = helpers.indexSwitch(pKey,sIndex ,sIndex ,sIndex ,7)
        elseif sIndex == 9 then -- Draw Card
            newIndex = helpers.indexSwitch(pKey,sIndex ,sIndex ,sIndex ,5)
        end

        newIndex = helpers.fixIndex(drawnCard,newIndex)
    end

    return newIndex
end

function helpers.nonFlippedCards(board) 
    nfIndexes = {}
    for key, card in ipairs(board) do
        if (not card.flipped) then
            table.insert(nfIndexes, key)
        end
    end

    return nfIndexes
end

function helpers.isRoundOver(pBoard) 
    for i,v in ipairs(pBoard) do
        if (not v.flipped) then
            return false
        end
    end

    return true
end

function helpers.sum(pScoreArray)
    total = 0
    for i,v in ipairs(pScoreArray) do
        total = total + v
    end
    
    return total
end

function table.clone(org)
    return {unpack(org)} -- use table.unpack when running tests.
end

return helpers