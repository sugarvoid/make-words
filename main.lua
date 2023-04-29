--! main.lua

require("utils.man_sound")
require("lib.word")


local music
local font
local text
local debug = ""
local utf8 = require("utf8")
local word_history
local lettersToIgnore = {'x', 'q', 'u', 'z', 'w', 'y', 'i', 'v'} -- For starting letter 
local sounds
local score
local entered_words
local negative_multipler = 1
--local typedWords = {}
local scroll_words
local gamestate -- 0 = menu, 1 = game, 2 = gameover
local screenWidth, screenHeight = love.graphics.getDimensions()
local width, height = love.graphics.getDimensions()
local time_left
local MAX_TIME = 10
local lives
local MAX_LIVES = 3
local char_values = {
    a = 1, b = 3, c = 3, d = 2, e = 1, f = 4, g = 2, h = 4,
    i = 1, j = 8, k = 5, l = 1, m = 3, n = 1, o = 1, p = 3,
    q = 10, r = 1, s = 1, t = 1, u = 1, v = 4, w = 4, x = 8,
    y = 4, z = 10
  }

local YELLOW = love.math.colorFromBytes(255, 191, 64)


function love.load()
    font = love.graphics.newFont("font/Blazma-Regular.ttf", 64)
    music = love.audio.newSource("sound/thinking_and_tinkering.ogg", "stream")
    love.graphics.setBackgroundColor(love.math.colorFromBytes(20, 75, 102))
    math.randomseed(os.time()) -- Insures the first letter is random each time
    entered_words = 0 
    time_left = MAX_TIME
    lives = MAX_LIVES
    gamestate = 0
    score = 0
    text = getFirstLetter()
    word_history = {}
    scroll_words = {}
    font:setFilter("nearest")
    love.graphics.setFont(font)
    love.keyboard.setKeyRepeat(true)
    -- love.mouse.setVisible(false)
    sounds = load_sounds()
end


function getFirstLetter()
    local _letter = 'z'

    while has_value(lettersToIgnore, _letter) == true do
        _letter = string.char(math.random(97,122))
    end

    return _letter
end


function love.textinput(t)
    if gamestate == 1 then
        if (t:match("%a+")) then
            text = text .. t
            playSound(sounds.click)
        end
    end
end


function love.keypressed(key)

    if key == "escape" then
            love.event.quit()
        end

    if gamestate == 0 then
        if key == "space" then
            gamestate = 1
        end
    end

    if gamestate == 2 then
        if key == "r" then
            love.load()
        end
    end


    if gamestate == 1 then
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

        if key == "return" and text ~= "" and string.len(text) >= 2 then
            checkWord(text)
        end

        
    end
end


function love.update(dt)
    if gamestate == 0 then
        update_menu()
    elseif gamestate == 1 then
        update_game(dt)
    else
        update_gameover(dt)
    end
end

function update_menu()
    return
end


function update_game(dt)

    if not music:isPlaying() then
        love.audio.play(music)
    end

    if entered_words > 4 then
        if time_left <= 0 then
            goTOGameOver()
        end
        time_left = time_left - dt
    end
end


function update_gameover(dt)
    if music:isPlaying() then
        love.audio.stop(music)
    end

    for index, word in ipairs(scroll_words) do
        word:update(dt)
    end
end


function love.draw()
    -- love.graphics.print(debug, 10, 0)
    if gamestate == 0 then
        draw_menu()
    end
    if gamestate == 1 then
        draw_game()
    end
    if gamestate == 2 then
        draw_gameover()
    end
end


--#region Draw Functions
function draw_menu()
    love.graphics.printf("press space", 0, screenHeight / 2 - font:getHeight() / 2, screenWidth, "center")
end


function draw_game()
    love.graphics.print(score, 5, 5)
    love.graphics.printf(text, 0, screenHeight / 2 - font:getHeight() / 2, screenWidth, "center")
    draw_timer()
    draw_lives(lives)
end


function draw_gameover()
    love.graphics.setColor(love.math.colorFromBytes(255, 191, 64))
    for index, word in ipairs(scroll_words) do
        if word.yPos < (love.graphics.getHeight() - 20) then
            word:draw()
        end
    end
    love.graphics.setColor(love.math.colorFromBytes(20, 75, 102))
    love.graphics.rectangle("fill", 0 ,0 , 800, 250)
    love.graphics.setColor(love.math.colorFromBytes(255, 191, 64))

    love.graphics.printf("game over", 0, 50 - font:getHeight() / 2, screenWidth, "center")
    love.graphics.printf("Press R to Restart", 0, 200 - font:getHeight() / 2, screenWidth, "center")
    
end


function draw_timer()
    local sx,sy = 150,500
    local c = time_left
    -- TODO: Change color to fit rest of game
    local color = {2-2 * c, 2*c, 0} -- red by 0 and green by 1
    love.graphics.setColor(color)
    love.graphics.rectangle('fill', sx, sy, time_left * 50, 40)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle('line', sx, sy, MAX_TIME * 50, 40)
end


function draw_lives(lives)
    love.graphics.setColor(love.math.colorFromBytes(255, 191, 64))
    if lives == 3 then
        draw_life_1()
        draw_life_2()
        draw_life_3()
    elseif lives == 2 then
        draw_life_1()
        draw_life_2()
    else
        draw_life_1()
    end
end


function draw_life_1()
    love.graphics.rectangle("fill", 300,10, 20, 20)
end


function draw_life_2()
    love.graphics.rectangle("fill", 340,10, 20, 20)
end


function draw_life_3()
    love.graphics.rectangle("fill", 380,10, 20, 20)
end


--#endregion Draw Functions


function word_was_good(word)
    entered_words = entered_words + 1
    score = score + getWordValue(word)
    time_left = MAX_TIME
    -- Add word to list
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
    local _valid_word
    local _is_repeat

    for line in love.filesystem.lines("data/wordlist.txt") do
        if line == word then
            _valid_word = true
            break
        end
    end

    if _valid_word == true then
        -- TODO: Check if word is in the typedWords table
        _is_repeat = has_value(word_history, word)
        if _is_repeat == false then
            -- Word good
            playSound(sounds.correct)
            word_was_good(word)
        else
            -- Used reapet word 
            lives = lives - 1
            -- TODO: Remove all but first letter
            text = string.sub(text, 1, 1)
            playSound(sounds.invalid)
            check_lives()
        end
    else
        -- Word was bad
        playSound(sounds.invalid)
        goTOGameOver()
        score = clamp(0, (score - (1 * negative_multipler)), 900)
        negative_multipler = negative_multipler + 1
        text = ""
    end
end


function check_lives()
    if lives <= 0 then
        goTOGameOver()
    end
end


function goTOGameOver()
    gamestate = 2
    local _yPos = 620
    for index, word in ipairs(word_history) do
        local _word = Word:new(word, _yPos)
        table.insert(scroll_words, _word)
        _yPos = _yPos + 50
    end
end

function saveWordsToTxt()
    local f = love.filesystem.newFile("Test.txt")
    f:open("w")

    for k,v in ipairs(word_history) do
        f:write((v..'\n'))
    end

    f:close()
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


function updateWordPos(dt)
    for index, word in ipairs(typedWords) do
      word.xPos = word.xPos + dt * word.speed
      if word.xPos > (love.graphics.getHeight() - 20) then
        table.remove(typedWords, index)
      end
    end
end


function getWordValue(word)
    local value = 0
    for i = 1, #word do
        local letter = string.sub(word, i, i)
        if char_values[letter] ~= nil then
            value = value + char_values[letter]
        end
    end
    return value
end

