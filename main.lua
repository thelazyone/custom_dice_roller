-- Initialize tables
local diceImages = {}
local diceButtons = {}
local diceFaces = {}
local results1 = {}
local results2 = {}

function love.load()
    
    -- Get list of image files in the 'resources' folder
    local files = love.filesystem.getDirectoryItems("resources")
    for _, file in ipairs(files) do
        if file:match("%.png$") or file:match("%.jpg$") then
            local imagePath = "resources/" .. file
            local image = love.graphics.newImage(imagePath)

            -- Resize image to 700x100 if necessary
            image = resizeImage(image, 700, 100)
            table.insert(diceImages, image)
            splitImage(image)
        end
    end
end

function love.draw()
    -- Player 1 buttons (Top-Left)
    for i, button in ipairs(diceButtons) do

        -- Scale down the button image to 50x50 by using a scaling factor of 0.5
        love.graphics.draw(button.image, button.quad, 10, i * 60, 0, 0.5, 0.5)

        -- Display only the count number
        love.graphics.print(button.count1, 70, i * 60 + 15)
    end

    -- Player 2 buttons (Top-Right)
    for i, button in ipairs(diceButtons) do

        -- Scale down the button image to 50x50
        local btnX = love.graphics.getWidth() - 60
        love.graphics.draw(button.image, button.quad, btnX, i * 60, 0, 0.5, 0.5)

        -- Display only the count number
        love.graphics.print(button.count2, btnX - 20, i * 60 + 15)
    end

    -- Roll button (Center-Top)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 50, 10, 100, 50)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("ROLL", love.graphics.getWidth() / 2 - 20, 25)
    love.graphics.setColor(1, 1, 1)

    -- Calculate the starting Y position for the results
    local buttonAreaHeight = (#diceButtons) * 75 
    local startY = buttonAreaHeight + 50

    -- Sets the max results shown per row.
    local dicePerRow = 3

    -- For Player 1 results:
    for i, result in ipairs(results1) do
        local x = ((i - 1) % dicePerRow) * 110 + 10
        local y = startY + math.floor((i - 1) / dicePerRow) * 110
        love.graphics.draw(result.image, result.quad, x, y)
    end

    -- For Player 2 results:
    for i, result in ipairs(results2) do
        local x = love.graphics.getWidth() - (((i - 1) % dicePerRow) * 110 + 110)
        local y = startY + math.floor((i - 1) / dicePerRow) * 110
        love.graphics.draw(result.image, result.quad, x, y)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button ~= 1 then return end  -- Only respond to left-click

    -- Check for Player 1 button clicks
    for i, btn in ipairs(diceButtons) do
        if x >= 10 and x <= 60 and y >= i * 60 and y <= i * 60 + 50 then
            btn.count1 = btn.count1 + 1
        end
    end

    -- Check for Player 2 button clicks
    for i, btn in ipairs(diceButtons) do
        local btnX = love.graphics.getWidth() - 60
        if x >= btnX and x <= btnX + 50 and y >= i * 60 and y <= i * 60 + 50 then
            btn.count2 = btn.count2 + 1
        end
    end

    -- Check for Roll button click
    if x >= love.graphics.getWidth() / 2 - 50 and x <= love.graphics.getWidth() / 2 + 50 and y >= 10 and y <= 60 then
        rollDice()
    end

    -- Display Player 1 results
    for i, result in ipairs(results1) do
        local x = (i - 1) % 10 * 50 + 10
        local y = math.floor((i - 1) / 10) * 50 + 400
        love.graphics.draw(result.image, result.quad, x, y, 0, 0.5, 0.5)
    end

    -- Display Player 2 results
    for i, result in ipairs(results2) do
        local x = love.graphics.getWidth() - ((i - 1) % 10 * 50 + 60)
        local y = math.floor((i - 1) / 10) * 50 + 400
        love.graphics.draw(result.image, result.quad, x, y, 0, 0.5, 0.5)
    end
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
            i * 100, 0, 100, 100,
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

    -- Reset counts
    for _, btn in ipairs(diceButtons) do
        btn.count1 = 0
        btn.count2 = 0
    end
end