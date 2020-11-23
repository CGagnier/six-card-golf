helpers = require("helpers")

function love.load()
    -- love.window.setMode(400,240)

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

    function roundIsOver()
        currentRound = currentRound + 1

        table.insert( playerScore, helpers.getScore(playerBoard) )
        table.insert( cpuScore, helpers.getScore(npcBoard) )

        resetRound()
    end

    function resetRound()
        print("Round was reset")
        playerTurn = true
        roundOver = false

        round_step = ROUND_STEP_ENUM.BASE;

        playerBoard = {} 
        npcBoard = {}

        discardPile = {} -- TODO: Need to become the deck once it has been emptied
        drawCard = {}

        deck = {}
        for suitIndex, suit in ipairs({'heart', 'spade', 'club', 'diamond'}) do
            for rank = 1, 13 do
                table.insert(deck, {suit = suit, rank = rank, flipped = false})
            end
        end

        table.insert( deck, { suit = 'joker', rank = 0, flipped = false} )
        table.insert( deck, { suit = 'joker', rank = 0, flipped = false} )

        for i=1,6 do
            takeCard(playerBoard)
            takeCard(npcBoard)
        end

        takeCard(discardPile)
        discardPile[#discardPile].flipped = true
    end

    function resetGame()
        currentRound = 0

        playerScore = {}
        cpuScore = {}

        resetRound()
    end

    resetGame()

end

function drawPlayer(pOutput, pBoard, isOpponent)
    name = "YOU"
    if isOpponent then
        name = "OPPONENT"
    end

    table.insert( pOutput, name)
    table.insert( pOutput, 'Score: ' .. helpers.getScore(pBoard) )
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
    local scoreBoard = {}

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

    drawScoreBoard(scoreBoard, playerScore, cpuScore)

    love.graphics.print(table.concat( scoreBoard, '\n' ),200)
end

function drawScoreBoard(pOutput, player, cpu) 
    table.insert( pOutput, '  Score')
    for i=1,9 do
        playerS = player[i] or "   "
        cpuS = cpu[i] or "   "

        table.insert( pOutput, ' '..playerS..' | '..cpuS..' ')
    end
end

function love.keypressed(key)

    roundOver = isRoundOver(npcBoard) -- did opponent finish his turn
    if playerTurn then
        print("Keep on playing")
        handlePlayerInput(key)
        roundOver = isRoundOver(playerBoard) -- if player flipped all cards then opponent will need to play their final turn
    end

    if not playerTurn then
        actionMessage = "..."
        print("CPU turn")
        handleCPUTurn()
    end

    if roundOver then 
        print("Round is over")
        roundIsOver()
    end
end

function handleCPUTurn() 

    -- Gathering information
    nonFlippedCardsIndexes = nonFlippedCards(npcBoard)  
    topDiscardPile = discardPile[#discardPile]
    optimalIndex = helpers.defineBestAction(npcBoard ,topDiscardPile, #nonFlippedCardsIndexes) 

    if (#nonFlippedCardsIndexes > 1 or true) then
        if (optimalIndex ~= -1) then
            indexToFlip = optimalIndex

            table.insert( drawCard, table.remove(discardPile,#discardPile))
            table.insert( discardPile , table.remove(npcBoard,indexToFlip))
            table.insert( npcBoard, indexToFlip, table.remove(drawCard,#drawCard) )
        else
            indexToFlip = nonFlippedCardsIndexes[love.math.random(#nonFlippedCardsIndexes)]
        end
        npcBoard[indexToFlip].flipped = true
    else
        -- Final step, optimise score. Should also be reached if cpu is in final turn (player turned all cards)
        print("Final card, if score is worst than opponent, it should draw until it can beat it.")
    end


    playerTurn = true
end

function nonFlippedCards(board) 
    count = {}
    for key, card in ipairs(board) do
        if (not card.flipped) then
            table.insert( count, key )
        end
    end

    return count
end

function isRoundOver(pBoard) 
    for i,v in ipairs(pBoard) do
        if (not v.flipped) then
            return false
        end
    end

    actionMessage = "Final round"
    return true
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

        if helpers.hasValue({'d','p'},pKey) then 
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

        if numberKey ~= nil and helpers.hasValue({1,2,3,4,5,6},numberKey) then
            if #drawCard > 0 then
                -- remove card from the table and replace by the one holded
                actionMessage = "Replacing card on position: ".. numberKey .. " by holded card"
                table.insert( discardPile , table.remove(playerBoard,numberKey))
                discardPile[#discardPile].flipped = true
                table.insert( playerBoard, numberKey, table.remove(drawCard,#drawCard) )
                playerBoard[numberKey].flipped = true
                playerTurn = false
                round_step = ROUND_STEP_ENUM.BASE
            else -- Selecting a card to flip
                if (playerBoard[numberKey].flipped) then
                    actionMessage = "Already flipped, select another card"
                else
                    actionMessage = "Flipped card no. "..numberKey
                    playerBoard[numberKey].flipped = true
                    playerTurn = false
                    round_step = ROUND_STEP_ENUM.BASE
                end
            end
        end
    elseif round_step == ROUND_STEP_ENUM.HOLD then
        -- Player is "holding" a card and can either discard it, or replace a card from it board

        if pKey == 'd' then
            actionMessage = "Discarded holded card"
            table.insert( discardPile , table.remove(drawCard,#drawCard))
            discardPile[#discardPile].flipped = true
            playerTurn = false
            round_step = ROUND_STEP_ENUM.BASE
        elseif pKey == 'r' then
            actionMessage = "Replace one of your card using 1 to 6 on your keyboard"
            round_step = ROUND_STEP_ENUM.PICK
        end
    end
end