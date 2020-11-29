helpers = require("helpers")

function love.load()

    local MAX_ROUNDS = 9
    SCALE = 0.5
    ROUND_STEP_ENUM = {
        BASE=1,
        DRAW=2,
        PICK=3,
        HOLD=4,
    }
    BLACK = {.196,.184,.16,1}
    WHITE = {.694,.682,.659,1}
    FONT_SIZE = 32
    SCREEN_WIDTH = 800 
    SCREEN_HEIGHT = 480

    actionMessage = '...'
    selected_index = -1

    love.window.setMode(SCREEN_WIDTH * SCALE,SCREEN_HEIGHT * SCALE)
    love.graphics.setFont(love.graphics.newFont(FONT_SIZE * SCALE))

    images = {}
    for i, name in ipairs({
        'card', 'card_face_down','card_filled', 
        'title', 'title_filled', 'message', 'message_filled', "hand", "hand_filled"
    }) do 
        images[name] = love.graphics.newImage('images/'..name..'.png')
    end

    cardWidth = images.card_face_down:getWidth()
    cardHeight = images.card_face_down:getHeight()

    love.graphics.setBackgroundColor(WHITE)

    function takeCard(hand)
        table.insert( hand, table.remove( deck, love.math.random(#deck) ) )
    end

    function roundIsOver()
        for i=1,6 do
            playerBoard[i].flipped = true
            npcBoard[i].flipped = true 
        end

        currentRound = currentRound + 1

        table.insert( playerScore, helpers.getScore(playerBoard) )
        table.insert( cpuScore, helpers.getScore(npcBoard) )

        if (currentRound >= MAX_ROUNDS) then
            gameOver = true

            totPlayerScore = helpers.sum(playerScore)
            totCpuScore = helpers.sum(cpuScore)

            if totPlayerScore < totCpuScore then
                actionMessage = "You won!"
            elseif totPlayerScore > totCpuScore then
                actionMessage = "CPU won!"
            else
                actionMessage = "It's a tie!"
            end

            actionMessage = actionMessage .. " Press escape to quit or any key to start again"

        else
            resetRound()
        end
    end

    function resetRound()
        playerTurn = true
        roundOver = false

        round_step = ROUND_STEP_ENUM.BASE;

        playerBoard = {} 
        npcBoard = {}

        discardPile = {} -- TODO: Need to become the deck once it has been emptied
        drawnCard = {}

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

        actionMessage = '...'
    end

    function resetGame()
        currentRound = 0
        gameOver = false

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

    -- Text display

    drawPlayer(output, npcBoard, true)

    table.insert( output, 'Discard Pile: '..printCard(discardPile[#discardPile]) )
    table.insert( output, 'Deck:' )
    table.insert( output, '' )

    drawPlayer(output, playerBoard, false)

    table.insert( output, 'Holding card: '.. printCard(drawnCard[#drawnCard]))
    table.insert( output, '')

    table.insert( output, 'Press T to turn a card, D to draw' ) 

    table.insert( output, actionMessage ) 

    --love.graphics.print(table.concat( output, '\n' ))

    drawScoreBoard(scoreBoard, playerScore, cpuScore)

    -- love.graphics.print(table.concat( scoreBoard, '\n' ),200)

    -- Images display
    love.graphics.setColor(BLACK)
    love.graphics.rectangle('fill',0,10 * SCALE,SCREEN_WIDTH * SCALE,10 * SCALE)
    love.graphics.rectangle('fill',0,25 * SCALE,SCREEN_WIDTH * SCALE,10 * SCALE)
    love.graphics.rectangle('fill',0,(SCREEN_HEIGHT - 30) * SCALE,SCREEN_WIDTH * SCALE,10 * SCALE)
    love.graphics.rectangle('fill',0,(SCREEN_HEIGHT - 15) * SCALE,SCREEN_WIDTH * SCALE,10 * SCALE)

    love.graphics.setColor(WHITE)
    love.graphics.draw(images.title_filled, 252 * SCALE, 0, 0, SCALE, SCALE)

    love.graphics.setColor(BLACK)
    love.graphics.draw(images.title, 252 * SCALE, 0, 0, SCALE, SCALE)

    local function drawFilledImages(normal, filled, x, y, scale)
        love.graphics.setColor(WHITE)    
        love.graphics.draw(filled, x, y, 0, scale, scale)
        love.graphics.setColor(BLACK)
        love.graphics.draw(normal, x, y, 0, scale, scale)
    end

    local function drawMessage(text)
        -- TODO: Use getWrap to know if the text is overflowing
        messageX = 236 * SCALE
        messageY = (SCREEN_HEIGHT - 86) * SCALE

        drawFilledImages(images.message, images.message_filled, messageX, messageY, SCALE)
        love.graphics.printf(text,messageX + (15 * SCALE), messageY + (10 * SCALE), 310 * SCALE, "left")
    end

    local function drawCard(card, x, y,scale)
        local scaling = scale or 1

        if card then
            if not card.flipped then  
                drawFilledImages(images.card_face_down, images.card_filled, x, y, scaling * SCALE)   
            else
                drawFilledImages(images.card, images.card_filled, x, y, scaling * SCALE)
            end
        end
    end

    local function drawScore(pScore,posX, align, player)
        local scoreSpacingY = (FONT_SIZE + 4) * SCALE
        local scoreMarginY = 35 * SCALE
        
        love.graphics.setColor(BLACK)

        for i=1,10 do
            y = (i * scoreSpacingY + scoreMarginY)
            if (i == 1) then
                love.graphics.printf(player or "CPU",posX,y,110 * SCALE, align)
            else
                playerS = pScore[i-1] or "   "
                love.graphics.printf(playerS,posX,y,110 * SCALE, align)
            end

        end
    end

    local function drawCardBoard(board, marginX)
        local cardSpacingX = (8 + cardWidth) * SCALE
        local cardSpacingY = (4 + cardHeight) * SCALE
        local marginY = 43.5 * SCALE
        
        for i, card in ipairs(board) do 
            local margeX = marginX * SCALE 
    
            drawCard(
                card,
                (math.floor(i/4) * cardSpacingX) + margeX,
                (((i-1)%3) * cardSpacingY) + marginY)
        end
    end

    drawCardBoard(playerBoard, 29 * SCALE)
    drawCardBoard(npcBoard, 582 * SCALE)

    -- Score drawing
    local scoreMarginX = 224

    drawScore(playerScore, scoreMarginX * SCALE, "left", "YOU")
    drawScore(cpuScore, (scoreMarginX + 242) * SCALE, "right")

    -- Pile, Discard and holding card
    local middleMarginY = 206 * SCALE
    drawCard(
        {flipped = false},
        296 * SCALE,
        middleMarginY)

    drawCard(
        discardPile[#discardPile],
        417.5 * SCALE,
        middleMarginY)

    if (drawnCard[#drawnCard]) then
        drawCard(
            drawnCard[#drawnCard],
            331.66 * SCALE,
            106 * SCALE,
            1.61)
    end

    -- Hand Selector 
    handX = 160 * SCALE
    handY = 350 * SCALE

    drawFilledImages(images.hand, images.hand_filled, handX, handY, SCALE)

    drawMessage("Lorem ipsum dolor sit amet, consectetur adipiscing elit")

    -- END game logic  
    if gameOver then
        -- draw menu with the winner, play again or quit
        totPlayerScore = helpers.sum(playerScore)
        totCpuScore = helpers.sum(cpuScore)
        love.graphics.print("Total: "..totPlayerScore.. " | ".. totCpuScore,175,160)
    end
end

function drawScoreBoard(pOutput, player, cpu) 
    table.insert( pOutput, '  Score')
    table.insert( pOutput, 'YOU | CPU ')
    for i=1,9 do
        playerS = player[i] or "   "
        cpuS = cpu[i] or "   "

        table.insert( pOutput, '   '..playerS..' | '..cpuS..' ')
    end
end

function love.keypressed(key)

    handleArrowSelection(key)

    if not gameOver then

        if playerTurn then
            handlePlayerInput(key)
        end

        if not (playerTurn or roundOver) then
            roundOver = isRoundOver(playerBoard)
            handleCPUTurn()
        end

        if roundOver then 
            roundIsOver()
        end

        roundOver = isRoundOver(npcBoard)
        if roundOver then
            actionMessage = "CPU finished, this is your final turn"
        end
    else
        handleMenuPlayerInput(key)
    end
end

function handleMenuPlayerInput(key)
    if key == "escape" then
        love.event.quit()
    else
        resetGame()
    end
end

function handleCPUTurn() 

    -- Gathering information
    nonFlippedCardsIndexes = nonFlippedCards(npcBoard)  
    topDiscardPile = discardPile[#discardPile]
    optimalIndex = helpers.defineBestAction(npcBoard ,topDiscardPile, #nonFlippedCardsIndexes) 

    if (#nonFlippedCardsIndexes <= 1 or roundOver) then

        opponentScore = helpers.getScore(playerBoard)
        ownScore = helpers.getScore(npcBoard)

        if (optimalIndex == -1) then -- The discard pile isn't good
            takeCard(drawnCard)
            potentialIndex = helpers.defineBestAction(npcBoard ,drawnCard[#drawnCard], 0)
            indexToFlip = potentialIndex
        else
            table.insert( drawnCard, table.remove(discardPile,#discardPile))
            indexToFlip = optimalIndex
        end

        if (indexToFlip == -1) then
            -- We have nothing good to flip, should discard draw card and end turn
            if roundOver then 
                -- Better flip a card than nothing      
                indexToFlip = nonFlippedCardsIndexes[love.math.random(#nonFlippedCardsIndexes)]        
                npcBoard[indexToFlip].flipped = true 
            else
                -- discard cards
                table.insert( discardPile , table.remove(drawnCard,#drawnCard))
            end
        else
            -- We have something good to flip
            table.insert( discardPile , table.remove(npcBoard,indexToFlip))
            table.insert( npcBoard, indexToFlip, table.remove(drawnCard,#drawnCard) )
            npcBoard[indexToFlip].flipped = true 
        end

    else
        if (optimalIndex ~= -1) then
            indexToFlip = optimalIndex

            table.insert( drawnCard, table.remove(discardPile,#discardPile))
            table.insert( discardPile , table.remove(npcBoard,indexToFlip))
            table.insert( npcBoard, indexToFlip, table.remove(drawnCard,#drawnCard) )
        else
            indexToFlip = nonFlippedCardsIndexes[love.math.random(#nonFlippedCardsIndexes)]
        end
        npcBoard[indexToFlip].flipped = true
       
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
                table.insert( drawnCard, table.remove(discardPile,#discardPile))
                round_step = ROUND_STEP_ENUM.HOLD
            elseif pKey == 'p' then
                takeCard(drawnCard)
                round_step = ROUND_STEP_ENUM.HOLD
            end
        end
    elseif round_step == ROUND_STEP_ENUM.PICK then
        numberKey = tonumber(pKey)

        if numberKey ~= nil and helpers.hasValue({1,2,3,4,5,6},numberKey) then
            if #drawnCard > 0 then
                -- remove card from the table and replace by the one holded
                actionMessage = "Replacing card on position: ".. numberKey .. " by holded card"
                table.insert( discardPile , table.remove(playerBoard,numberKey))
                discardPile[#discardPile].flipped = true
                table.insert( playerBoard, numberKey, table.remove(drawnCard,#drawnCard) )
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
            table.insert( discardPile , table.remove(drawnCard,#drawnCard))
            discardPile[#discardPile].flipped = true
            playerTurn = false
            round_step = ROUND_STEP_ENUM.BASE
        elseif pKey == 'r' then
            actionMessage = "Replace one of your card using 1 to 6 on your keyboard"
            round_step = ROUND_STEP_ENUM.PICK
        end
    end
end

function handleArrowSelection(pKey)
    if helpers.hasValue({'up','down','right','left'},pKey) then 

    end
end