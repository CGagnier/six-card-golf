function love.load()

    local MAX_ROUNDS = 9
    actionMessage = '...'

    ROUND_STEP_ENUM = {
        BASE=1,
        DRAW=2,
        PICK=3,
        HOLD=4,
    }

    function takeCard(hand)
        table.insert( hand, table.remove( deck, love.math.random(#deck) ) )
    end

    -- Calculate the score for a player hand
    function getScore(board)
        local score = 0

        -- "pop" jokers (-5) and kings (0) and add to the score
        -- Remove any card that is there more than once
        -- add regular cards rank to the score

        return score
    end

    function roundOver()
        currentRound = currentRound + 1

        table.insert( playerScore, getScore(playerBoard) )
        table.insert( playerScore, getScore(npcBoard) )

        resetRound()
    end

    -- Will reset the 2 players board and reprepare the deck
    function resetRound()
        playerTurn = true
        roundOver = false

        round_step = ROUND_STEP_ENUM.BASE;

        playerBoard = {} 
        npcBoard = {}

        discardPile = {} -- Need to become the deck once it has been emptied
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

        playerScore = {}
        cpuScore = {}
    end

    resetRound()
end

function drawPlayer(pOutput, pBoard, isOpponent)
    name = "YOU"
    if isOpponent then
        name = "OPPONENT"
    end

    table.insert( pOutput, name)
    table.insert( pOutput, 'Score: ' .. getScore(pBoard) )
    table.insert( pOutput, '')
    for cardIndex,card in ipairs(pBoard) do
        if (card.flipped) then
            table.insert( pOutput, cardIndex.. ' - ' ..printCard(card))
        else
            table.insert( pOutput, cardIndex.. ' - ' ..'S: ?, R: ?')
        end

    end
    table.insert( pOutput, '' )
end

function love.draw()

    local output = {}

    drawPlayer(output, npcBoard, true)

    table.insert( output, 'Discard Pile: '..printCard(discardPile[#discardPile]) )
    table.insert( output, 'Deck:' )
    table.insert( output, '' )

    drawPlayer(output, playerBoard, false)

    table.insert( output, 'Holding card: '.. printCard(drawCard[#drawCard]))
    table.insert( output, '')

    table.insert( output, 'Press T to turn a card, D to draw' ) 

    table.insert( output, actionMessage ) 

    love.graphics.print(table.concat( output, '\n' ))
end

function love.keypressed(key)

    if not roundOver then
        if playerTurn then
            print("Keep on playing")
            handlePlayerInput(key)
        end

        if not playerTurn then
            print("CPU turn")
        end
    else
        roundOver()
    end
end

function hasValue (tab, val)
    print("Check with "..val)
    for index, value in ipairs(tab) do
        print("index: ".. index .. " value: "..value .." check with: ".. val)
        print(value == val)
        if value == val then
            return true
        end
    end

    return false
end

function printCard(pCard)
    if (pCard ~= nil) then
        return 'S: '..pCard.suit..', R: '..pCard.rank
    else
        return '-'
    end
end

function handlePlayerInput(pKey) 
    if round_step == ROUND_STEP_ENUM.BASE then 

        if pKey == 't' then
            actionMessage = "Select card using 1 to 6 on your keyboard"
            round_step = ROUND_STEP_ENUM.PICK
        elseif pKey == 'd' then
            actionMessage = "Where do you want to draw a card? D: Discard pile OR P: Pile"
            round_step = ROUND_STEP_ENUM.DRAW
        end
    elseif round_step == ROUND_STEP_ENUM.DRAW then

        if hasValue({'d','p'},pKey) then 
            actionMessage = "Press D to discard it or R to replace a card from your board"

            if pKey == 'd' then
                table.insert( drawCard, table.remove(discardPile,#discardPile))
                round_step = ROUND_STEP_ENUM.HOLD
            elseif pKey == 'p' then
                takeCard(drawCard)
                round_step = ROUND_STEP_ENUM.HOLD
            end
        end
    elseif round_step == ROUND_STEP_ENUM.PICK then
        numberKey = tonumber(pKey)

        if numberKey ~= nil and hasValue({1,2,3,4,5,6},numberKey) then
            if #drawCard > 0 then -- Selecting a card to replace
                -- remove card from the table and replace by the one holded
                actionMessage = "Replacing card on position: ".. numberKey .. " by holded card"
                table.insert( discardPile , table.remove(playerBoard,numberKey))
                table.insert( playerBoard, numberKey, table.remove(drawCard,#drawCard) )
                playerBoard[numberKey].flipped = true
                playerTurn = false
            else -- Selecting a card to flip
                if (playerBoard[numberKey].flipped) then
                    actionMessage = "Already flipped, select another card"
                else
                    actionMessage = "Flipped card no. "..numberKey
                    playerBoard[numberKey].flipped = true
                    -- check if all cards are flipped
                    playerTurn = false
                end
            end
        end
    elseif round_step == ROUND_STEP_ENUM.HOLD then
        -- Player is "holding" a card and can either discard it, or replace a card from it board

        if pKey == 'd' then
            actionMessage = "Discarded holded card"
            table.insert( discardPile , table.remove(drawCard,#drawCard))
            playerTurn = false
        elseif pKey == 'r' then
            actionMessage = "Replace one of your card using 1 to 6 on your keyboard"
            round_step = ROUND_STEP_ENUM.PICK
        end
    end
end