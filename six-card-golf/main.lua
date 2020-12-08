helpers = require("helpers")

function love.load()

    local MAX_ROUNDS = 9
    SCALE = .5
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

    INDEX_COORDS = {
        {x = 69.5,y = 101},
        {x = 69.5,y = 234.5},
        {x = 69.5,y = 368},
        {x = 167.5,y = 101},
        {x = 167.5,y = 234.5},
        {x = 167.5,y = 368},
        {x = 332.75,y = 265},
        {x = 458,y = 265},
        {x = 395,y = 206},
    }

    selected_index = 7
    final_turn = false

    currentMessage = {}
    MESSAGE_WRAP = 310 * SCALE

    love.window.setMode(SCREEN_WIDTH * SCALE,SCREEN_HEIGHT * SCALE)
    love.graphics.setFont(love.graphics.newFont(FONT_SIZE * SCALE))

    FONT = love.graphics.getFont()

    images = {}
    for i, name in ipairs({
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
        'card', 'card_face_down','card_filled', 'deck_empty',
        'title', 'title_filled', 'message', 'message_filled', "hand", "hand_filled"
    }) do 
        images[name] = love.graphics.newImage('images/'..name..'.png')
    end

    cardWidth = images.card_face_down:getWidth()
    cardHeight = images.card_face_down:getHeight()

    love.graphics.setBackgroundColor(WHITE)

    function takeCard(hand,flipped)
        if (#deck<1) then
            -- TODO: Add animation
            deck = discardPile
            discardPile = {}
        end

        table.insert( hand, table.remove( deck, love.math.random(#deck) ) )
        hand[#hand].flipped = flipped or false
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
            local endMessage

            totPlayerScore = helpers.sum(playerScore)
            totCpuScore = helpers.sum(cpuScore)

            if totPlayerScore < totCpuScore then
                endMessage = "You won!"
            elseif totPlayerScore > totCpuScore then
                endMessage = "CPU won!"
            else
                endMessage = "It's a tie!"
            end

            endMessage = endMessage .. " Press escape to quit or any key to start again"

            pushTextToMessage(endMessage)
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

        takeCard(discardPile,true)
    end

    function resetGame()
        currentRound = 0
        gameOver = false

        playerScore = {}
        cpuScore = {}

        resetRound()
    end

    -- Take care of splitting message in displayable chunk on the message
    function pushTextToMessage(text)
        local displayText = {}
        width, wrap = FONT:getWrap(text, MESSAGE_WRAP)
        while #wrap > 1 do
            -- TODO: Should add icon to say they have more to read, ... or the key blinking
            local toInsert = ""
            toInsert = toInsert.. table.remove(wrap,1)
            toInsert = toInsert.. table.remove(wrap,1)
            table.insert(displayText, toInsert)
        end

        if #wrap > 0 then
            table.insert(displayText, wrap[1])
        end
        
        currentMessage = displayText
    end

    resetGame()

end

function love.draw()

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

    local function displayMessage(text)

        if #currentMessage > 0 then 

            messageX = 236 * SCALE
            messageY = (SCREEN_HEIGHT - 86) * SCALE
    
            drawFilledImages(images.message, images.message_filled, messageX, messageY, SCALE)
            love.graphics.printf(currentMessage[1],messageX + (15 * SCALE), messageY + (10 * SCALE), MESSAGE_WRAP, "left")
        end
    end

    local function drawCard(card, x, y,scale)

        local function drawCorner(image, offsetX, offsetY)
            love.graphics.draw(
                image,
                x + offsetX,
                y + offsetY,
                0,
                SCALE,
                SCALE
            )
            love.graphics.draw(
                image, 
                x + (cardWidth * SCALE) - offsetX,
                y + (cardHeight * SCALE) - offsetY,
                0,
                -1 * SCALE)
        end

        local scaling = scale or 1

        if card then
            if not card.flipped then  
                drawFilledImages(images.card_face_down, images.card_filled, x, y, scaling * SCALE)   
            else
                drawFilledImages(images.card, images.card_filled, x, y, scaling * SCALE)
                drawCorner(images[card.rank],8 * SCALE ,8 * SCALE)
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

    drawCardBoard(playerBoard, 29)
    drawCardBoard(npcBoard, 582)

    -- Score drawing
    local scoreMarginX = 224

    drawScore(playerScore, scoreMarginX * SCALE, "left", "YOU")
    drawScore(cpuScore, (scoreMarginX + 242) * SCALE, "right")

    -- Pile, Discard and holding card
    local middleMarginY = 206 * SCALE
    local deckPosX = 296 * SCALE

    if #deck > 0 then
        drawCard(
            {flipped = false},
            deckPosX,
            middleMarginY)
    else
        love.graphics.setColor(BLACK)    
        love.graphics.draw(images.deck_empty, deckPosX, middleMarginY, 0, SCALE, SCALE)
    end

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
    handX = INDEX_COORDS[selected_index].x * SCALE
    handY = INDEX_COORDS[selected_index].y * SCALE

    drawFilledImages(images.hand, images.hand_filled, handX, handY, SCALE)

    -- Selected element logic
    if selected_index == 7 then
        local cardsLeft = #deck
        love.graphics.printf(cardsLeft,315 * SCALE, 344 * SCALE,50 * SCALE, "center")
    end

    displayMessage()
end

function love.keypressed(key)

    local function handleCPUTurn() 

        -- Gathering information
        nonFlippedCardsIndexes = helpers.nonFlippedCards(npcBoard)  
        topDiscardPile = discardPile[#discardPile]
        optimalIndex = helpers.defineBestAction(npcBoard ,topDiscardPile, #nonFlippedCardsIndexes) 
    
        if (#nonFlippedCardsIndexes <= 1 or roundOver) then
    
            -- TODO: If score is much lower than the player, it should end turn
            if (optimalIndex == -1) then -- The discard pile isn't good
                takeCard(drawnCard,true)
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
                end
                table.insert( discardPile , table.remove(drawnCard,#drawnCard))
            else
                -- We have something good to flip
                npcBoard[indexToFlip].flipped = true 
                table.insert( discardPile , table.remove(npcBoard,indexToFlip))
                table.insert( npcBoard, indexToFlip, table.remove(drawnCard,#drawnCard) )
                npcBoard[indexToFlip].flipped = true 
            end
    
        else
            if (optimalIndex ~= -1) then
                indexToFlip = optimalIndex
    
                table.insert( drawnCard, table.remove(discardPile,#discardPile))
                npcBoard[indexToFlip].flipped = true 
                table.insert( discardPile , table.remove(npcBoard,indexToFlip))
                table.insert( npcBoard, indexToFlip, table.remove(drawnCard,#drawnCard) )
            else
                indexToFlip = nonFlippedCardsIndexes[love.math.random(#nonFlippedCardsIndexes)]
            end
            npcBoard[indexToFlip].flipped = true
           
        end
        
        playerTurn = true
    end

    local function handlePlayerAction(pKey) 
        if pKey == 'x' then 
            if #drawnCard > 0 then 
                if helpers.hasValue({1,2,3,4,5,6},selected_index) then -- Replacing card on board
                    table.insert( discardPile , table.remove(playerBoard,selected_index))
                    discardPile[#discardPile].flipped = true
                    table.insert( playerBoard, selected_index, table.remove(drawnCard,#drawnCard) )
                else
                    table.insert( discardPile , table.remove(drawnCard,#drawnCard))
                end
                playerTurn = false
                final_turn = false
            else
                -- flipping card on board
                if helpers.hasValue({1,2,3,4,5,6},selected_index) then
                    if (playerBoard[selected_index].flipped) then
                        pushTextToMessage("Already flipped, pick another card.")
                    else
                        playerBoard[selected_index].flipped = true
                        playerTurn = false
                        final_turn = false
                    end
    
                else -- Drawing discard or pile
                    if selected_index == 7 then
                        takeCard(drawnCard,true)
                    else
                        table.insert( drawnCard, table.remove(discardPile,#discardPile))
                    end
                    pushTextToMessage("Select a card to be replaced by this card, or discard it by clicking it.")
                end
            end
    
            selected_index = helpers.fixIndex(drawnCard,selected_index)
        end
    end

    local function handleMessageBox(pKey)
        if pKey == 'z' then
            if #currentMessage > 0 then 
                table.remove( currentMessage,1 )
            end
        end
    end

    handleMessageBox(key)

    if not gameOver then
        selected_index = helpers.handleArrowSelection(key, selected_index)

        if playerTurn then
            handlePlayerAction(key)
        end

        if not (playerTurn or roundOver) then
            roundOver = helpers.isRoundOver(playerBoard)
            handleCPUTurn()
        end

        if roundOver and not final_turn then 
            roundIsOver()
        end

        roundOver = helpers.isRoundOver(npcBoard)
        if roundOver then
            if not final_turn then
                pushTextToMessage("CPU finished, this is your final turn")
            end
            final_turn = true
        end
    else
        if key == "escape" then
            love.event.quit()
        elseif key == "x" then
            resetGame()
        end
    end
end