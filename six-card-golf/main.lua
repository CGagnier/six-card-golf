function love.load()

    local MAX_ROUNDS = 9

    
    actionMessage = '...'

    -- Take Card
    function takeCard(hand)
        table.insert( hand, table.remove( deck, love.math.random(#deck) ) )
    end

    -- Calculate the score for a player hand
    function getScore(board)
        local score = 0


        -- "pop" jokers and kings and add to the score
        -- count number of duplicates
        -- add regular cards score

        return score

    end

    function roundOver()
        currentRound = currentRound + 1
        getScore(playerBoard)
        getScore(npcBoard)
    end

    -- Will reset the 2 players board and reprepare the deck
    function resetRound()
        playerTurn = true
        roundOver = false


        mainTurnAction = ''
        lastKeyPressed = ''

        playerBoard = {} 
        npcBoard = {}
        discardPile = {} -- Need to become the deck once emptied
        drawCard = {} -- Array to hold the current card (maximum 1 at the time)

        -- filling the deck with regular cards + 2 jokers
        deck = {}
        for suitIndex, suit in ipairs({'heart', 'spade', 'club', 'diamond'}) do
            for rank = 1, 13 do
                table.insert(deck, {suit = suit, rank = rank, flipped = false})
            end
        end

        table.insert( deck, { suit = 'joker', rank = 0, flipped = false} )
        table.insert( deck, { suit = 'joker', rank = 1, flipped = false} )

        -- Distribute 6 cards for
        for i=1,6 do
            takeCard(playerBoard)
            takeCard(npcBoard)
        end

        takeCard(discardPile)

    end

    function resetGame()
        currentRound = 0
    end

    resetRound()

    print("...")

end

function love.draw()

    local output = {}

    table.insert( output, 'OPPONENT')

    table.insert( output, 'Score: ' .. getScore(npcBoard) )
    table.insert( output, '')
    for cardIndex,card in ipairs(npcBoard) do
        if (card.flipped) then
            table.insert( output,'suit: '..card.suit..', rank: '..card.rank)
        else
            table.insert( output,'suit: ?, rank: ?')
        end

    end
    table.insert( output, '' ) 

    table.insert( output, 'Discard Pile: ' )
    table.insert( output, 'Deck: ' )

    table.insert( output, '' )

    table.insert( output, 'YOU' )
    table.insert( output, 'Score: ' .. getScore(playerBoard) )
    table.insert( output, '')
    for cardIndex,card in ipairs(playerBoard) do
        if (card.flipped) then
            table.insert( output,cardIndex.. ' - suit: '..card.suit..', rank: '..card.rank)
        else
            table.insert( output,cardIndex.. ' - suit: ?, rank: ?')
        end

    end
    table.insert( output, '' ) 

    table.insert( output, 'Press T to turn a card, D to draw' ) 

    table.insert( output, actionMessage ) 


    love.graphics.print(table.concat( output, '\n' ))
end

function has_value (tab, val)
    print("Check with "..val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end