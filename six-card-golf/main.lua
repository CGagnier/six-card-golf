function love.load()

    local MAX_ROUNDS = 9

    -- Take Card
    function takeCard(hand)
        table.insert( hand, table.remove( deck, love.math.random(#deck) ) )
    end

    -- Calculate the score for the round
    function getScore(board)
        local score = 0
    end

    function roundOver()
        currentRound = currentRound + 1
        getScore(playerBoard)
        getScore(npcBoard)
    end

    -- Will reset the 2 players board and reprepare the deck
    function resetRound()
        playerTurn = true

        playerBoard = {} 
        npcBoard = {}
        discardPile = {} -- Need to become the deck once emptied
        drawCard = {} -- Array to hold the current card (maximum 1 at the time)

        -- Distribute 6 cards
        for i=1,6 do
            takeCard(playerBoard)
            takeCard(npcBoard)
        end

    end

    function resetGame()
        currentRound = 0
    end

end

function love.draw()

end