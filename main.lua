--main.lua

require("scripts.load_media")



local font = love.graphics.newFont("font/Blazma-Regular.ttf", 64)
local text = ""
local debug =""
local utf8 = require("utf8")
local word_history
local lettersToIgnore = {'x', 'q', 'u', 'z', 'w'}
local sounds
local score = 0
local negative_multipler = 1
local typedWords = {}


local screenWidth, screenHeight = love.graphics.getDimensions()
local width, height = love.graphics.getDimensions()


function love.load()
    word_history = {}
    font:setFilter("nearest")
    love.graphics.setFont(font)
    love.keyboard.setKeyRepeat(true)
    -- love.mouse.setVisible(false)
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
            if string.len(text) > 1 then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                text = string.sub(text, 1, byteoffset - 1)
                playSound(sounds.erase)
            end
        end
    end

    if key == "return" and text ~= "" then
        checkWord(text)
        
    end
    if key == "escape" then
        love.event.quit()
    end
end


function love.update(dt)
    return
end


function love.draw()
    love.graphics.print(debug, 10, 0)
    love.graphics.print(score, 10, 52)
    --love.graphics.setFont(font)
    --love.graphics.print("Hello set font", 20, 20)
    love.graphics.printf(text, 0, screenHeight / 2 - font:getHeight() / 2, screenWidth, "center")
end


function word_was_good(word)
    -- add word to list
    score = score + getWordValue(word)
    debug = getWordValue(word)
    table.insert(word_history, word)
    text = string.sub(text, -1)
end


function has_value (tab, val)
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


function checkWord(word)
    local inList

    for line in love.filesystem.lines("data/wordlist.txt") do
        if line == word then
            inList = true
            break
        end
    end

    if inList == true then
        -- TODO: Check if word is in the typedWords table
        -- Word good
        playSound(sounds.correct)
        word_was_good(word)
    else
        -- Word was bad
        playSound(sounds.invalid)
        score = clamp(0, (score - (1 * negative_multipler)), 900)
        negative_multipler = negative_multipler + 1
        text = ""
    end
end

function saveWordsToTxt()
    return
end

---
-- Clamps a value to a certain range.
-- @param min - The minimum value.
-- @param val - The value to clamp.
-- @param max - The maximum value.
--
function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end



function addWordToScreen(x, y, speed)
    word = {xPos = x,
            yPos = y,
            width,
            height,
            speed=speed
        }
    table.insert(typedWords, word)
  end


  function updateWordPos(dt)
    for index, word in ipairs(typedWords) do
      word.xPos = word.xPos + dt * word.speed
      if word.xPos > love.graphics.getHeight() then
        table.remove(typedWords, index)
      end
    end
  end
  

  function getWordValue(word)
    local num = 0
    for i = 1, #word do
        local char = string.sub(#word, i, i)
        num = num + getLetterValue(char)
      end
    return num
  end

  function getLetterValue(letter)
    local _num = 1
    return _num
  end 