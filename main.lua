--main.lua

require "scripts.load_media"

local font = love.graphics.newFont("font/Blazma-Regular.ttf", 64)
local text = ""
local debug =""
local utf8 = require("utf8")
local word_history
local lettersToIgnore = {'x', 'q', 'u', 'z', 'w'}



local screenWidth, screenHeight = love.graphics.getDimensions()
local width, height = love.graphics.getDimensions()


function love.load()
    word_history = {}
    font:setFilter("nearest")
    love.graphics.setFont(font)
    love.keyboard.setKeyRepeat(true)
    love.mouse.setVisible(false)
    sounds = load_sounds()
end



function love.textinput(t)
    if (t:match("%a+")) then
        text = text .. t
        playSound(sounds.click)
    end
end

function love.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(text, -1)

        if byteoffset then
            if string.len(text) > 1 
                then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                text = string.sub(text, 1, byteoffset - 1)
                playSound(sounds.erase)
                end
        end
    end
    if key == "return" and text ~= "" then
        debug = "enter func"
        --play ding sound
        playSound(sounds.correct)
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
    text = string.sub(text, -1)
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

function playSound(sound)
    love.audio.stop(sound)
    love.audio.play(sound)
end