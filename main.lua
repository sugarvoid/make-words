--main.lua

require "scripts.load_media"

local font = love.graphics.newFont("Blazma-Regular.ttf", 64)
local text = ""
local debug =""
local utf8 = require("utf8")
local word_history = {}
local lettersToIgnore = {'x', 'q', 'u', 'z', 'w'}



local screenWidth, screenHeight = love.graphics.getDimensions()
local width, height = love.graphics.getDimensions()


function love.load()
    font:setFilter("nearest")
    love.graphics.setFont(font)
    love.keyboard.setKeyRepeat(true)
    love.mouse.setVisible(false)
end



function love.textinput(t)
    if (t:match("%a+")) then
        text = text .. t
    end
end

function love.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(text, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            text = string.sub(text, 1, byteoffset - 1)
        end
    end
    if key == "return" and text ~= "" then
        debug = "enter func"
        --play ding sound
        add_word_to_list(text)
        
    end
    if
        key == "escape" then
            love.event.quit()
    end
end


function love.update(dt)
    return
end


function love.draw()
    love.graphics.print(debug, 10, 10)
    --love.graphics.setFont(font)
    --love.graphics.print("Hello set font", 20, 20)
    love.graphics.printf(text, 0, screenHeight / 2 - font:getHeight() / 2, screenWidth, "center")
end

function add_word_to_list(word)
    debug = word
    table.insert(word_history, word)
    clear_current_word()
end

function clear_current_word()
    text = ""
end 


local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


function getRandomLetter()
    math.randomseed(os.clock()^5)
    return string.char(math.random(65, 65 + 25)):lower()
end