-- Initialize tables
local diceImages = {}
local diceButtons = {}
local diceFaces = {}
local results1 = {}
local results2 = {}

local cubeSizes = 200                               -- Size of the result roll (should be bigger!)
local buttonSize = 50                               -- Size of the buttons (width and height)
local buttonPadding = 10                            -- Padding between buttons
local dicePadding = 10                              -- Padding between dice images
local buttonSpacing = buttonSize + buttonPadding    -- Vertical spacing between butto

function love.load()

    -- Get list of image files in the 'resources' folder
    local files = love.filesystem.getDirectoryItems("resources")
    for _, file in ipairs(files) do
        if file:match("%.png$") or file:match("%.jpg$") then
            local imagePath = "resources/" .. file
            local image = love.graphics.newImage(imagePath)

            -- Resize image to match cubeSizes
            image = resizeImage(image, cubeSizes * 7, cubeSizes)
            table.insert(diceImages, image)
            splitImage(image)
        end
    end

    -- load font.
    pixellariSmall = love.graphics.newFont("resources/pixellari.ttf", 24)
    pixellariLarge = love.graphics.newFont("resources/pixellari.ttf", 34)
end

function love.resize(w, h)
  print(("Window resized to width: %d and height: %d."):format(w, h))
end

function love.draw()

    -- Set the font
    love.graphics.setFont(pixellariLarge)

    -- Calculate scaling factor for buttons
    local buttonScale = buttonSize / cubeSizes

    -- Player 1 buttons (Top-Left)
    for i, button in ipairs(diceButtons) do
        local yPos = i * buttonSpacing
        love.graphics.draw(button.image, button.quad, 10, yPos, 0, buttonScale, buttonScale)
        love.graphics.print(button.count1, 10 + buttonSize + 10, yPos + buttonSize / 4)
    end

    -- Player 2 buttons (Top-Right)
    for i, button in ipairs(diceButtons) do
        local btnX = love.graphics.getWidth() - 10 - buttonSize
        local yPos = i * buttonSpacing
        love.graphics.draw(button.image, button.quad, btnX, yPos, 0, buttonScale, buttonScale)
        love.graphics.print(button.count2, btnX - 20, yPos + buttonSize / 4)
    end
 
    -- Roll button (Center-Top)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 140, 10, 130, 50)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("ROLL", love.graphics.getWidth() / 2 - 120, 25)
    love.graphics.setColor(1, 1, 1)

    -- Reset button (Next to Roll button)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 + 10, 10, 130, 50)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("RESET", love.graphics.getWidth() / 2 + 30, 25)
    love.graphics.setColor(1, 1, 1)

    -- Calculate the starting Y position for the results
    local buttonAreaHeight = (#diceButtons) * buttonSpacing
    local startY = buttonAreaHeight + 80  -- Add some padding

    -- Number of dice per row
    local dicePerRow = 3

    -- Central divider.
    if (next(results1) ~= nil) or (next(results2) ~= nil) then
        love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 10, startY, 20, love.graphics.getHeight() - startY - 30)
    end

    -- Display Player 1 results
    for i, result in ipairs(results1) do
        local x = ((i - 1) % dicePerRow) * (cubeSizes + dicePadding) + 10
        local y = startY + math.floor((i - 1) / dicePerRow) * (cubeSizes + dicePadding)
        love.graphics.draw(result.image, result.quad, x, y)
    end

    -- Display Player 2 results
    for i, result in ipairs(results2) do
        local x = love.graphics.getWidth() - (((i - 1) % dicePerRow) * (cubeSizes + dicePadding) + cubeSizes + 10)
        local y = startY + math.floor((i - 1) / dicePerRow) * (cubeSizes + dicePadding)
        love.graphics.draw(result.image, result.quad, x, y)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button ~= 1 then return end  -- Only respond to left-click

    -- Check for Player 1 button clicks
    for i, btn in ipairs(diceButtons) do
        local yPos = i * buttonSpacing
        if x >= 10 and x <= 10 + buttonSize and y >= yPos and y <= yPos + buttonSize then
            btn.count1 = btn.count1 + 1
        end
    end

    -- Check for Player 2 button clicks
    for i, btn in ipairs(diceButtons) do
        local btnX = love.graphics.getWidth() - 10 - buttonSize
        local yPos = i * buttonSpacing
        if x >= btnX and x <= btnX + buttonSize and y >= yPos and y <= yPos + buttonSize then
            btn.count2 = btn.count2 + 1
        end
    end

    -- Check for Roll button click
    if x >= love.graphics.getWidth() / 2 - 140 and x <= love.graphics.getWidth() / 2 - 10 and y >= 10 and y <= 60 then
        rollDice()
    end

    -- Check for Reset button click
    if x >= love.graphics.getWidth() / 2 + 10 and x <= love.graphics.getWidth() / 2 + 140 and y >= 10 and y <= 60 then
        resetCounters()
    end

    -- -- Display Player 1 results
    -- for i, result in ipairs(results1) do
    --     local x = (i - 1) % 10 * 100 + 10
    --     local y = math.floor((i - 1) / 10) * 100 + 400
    --     love.graphics.draw(result.image, result.quad, x, y, 0, 0.5, 0.5)
    -- end

    -- -- Display Player 2 results
    -- for i, result in ipairs(results2) do
    --     local x = love.graphics.getWidth() - ((i - 1) % 10 * 100 + 60)
    --     local y = math.floor((i - 1) / 10) * 100 + 400
    --     love.graphics.draw(result.image, result.quad, x, y, 0, 0.5, 0.5)
    -- end
end

-- OTHER METHODS

function resizeImage(image, targetWidth, targetHeight)
    local canvas = love.graphics.newCanvas(targetWidth, targetHeight)
    love.graphics.setCanvas(canvas)
    love.graphics.draw(image, 0, 0, 0, targetWidth / image:getWidth(), targetHeight / image:getHeight())
    love.graphics.setCanvas()
    return love.graphics.newImage(canvas:newImageData())
end

function splitImage(image)
    local quads = {}
    for i = 0, 6 do
        local quad = love.graphics.newQuad(
            i * cubeSizes, 0, cubeSizes, cubeSizes,
            image:getWidth(), image:getHeight()
        )
        table.insert(quads, quad)
    end

    -- First quad is the button image
    table.insert(diceButtons, { image = image, quad = quads[1], count1 = 0, count2 = 0 })
    
    -- Next six quads are the dice faces
    table.insert(diceFaces, { image = image, quads = { unpack(quads, 2, 7) } })
end

function rollDice()
    results1 = {}
    results2 = {}

    for i, die in ipairs(diceFaces) do
        -- Player 1 rolls
        for j = 1, diceButtons[i].count1 do
            local faceIndex = love.math.random(1, 6)
            table.insert(results1, { image = die.image, quad = die.quads[faceIndex] })
        end
        -- Player 2 rolls
        for j = 1, diceButtons[i].count2 do
            local faceIndex = love.math.random(1, 6)
            table.insert(results2, { image = die.image, quad = die.quads[faceIndex] })
        end
    end
end

function resetCounters()
    -- Reset counts for both players
    for _, btn in ipairs(diceButtons) do
        btn.count1 = 0
        btn.count2 = 0
    end

    -- Clear the dice roll results
    results1 = {}
    results2 = {}
end