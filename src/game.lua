require("src.word")

local music
local font
local text
local utf8 = require("utf8")
local word_history
local letters_to_ignore = { 'x', 'q', 'u', 'z', 'w', 'y', 'i', 'v' } -- For starting letter
local sounds
local score
local entered_words
local scroll_words
local gamestate -- 0 = menu, 1 = game, 2 = gameover
local screen_width, screen_height = love.graphics.getDimensions()
local lives
local time_left_bg
local MAX_LIVES = 3
local char_values = {
    a = 1,
    b = 3,
    c = 3,
    d = 2,
    e = 1,
    f = 4,
    g = 2,
    h = 4,
    i = 1,
    j = 8,
    k = 5,
    l = 1,
    m = 3,
    n = 1,
    o = 1,
    p = 3,
    q = 10,
    r = 1,
    s = 1,
    t = 1,
    u = 1,
    v = 4,
    w = 4,
    x = 8,
    y = 4,
    z = 10
}

local COLORS = {
    BLACK = "#000000",
    GRAY = "#202122",
    RED = "#ff0028",
    WHITE = "#ffffff99"
}

function load_sounds()
    local Sounds = {}
    Sounds.click = love.audio.newSource("sound/click.wav", "static")
    Sounds.click:setVolume(0.7)

    Sounds.correct = love.audio.newSource("sound/correct.wav", "static")
    Sounds.correct:setVolume(0.2)

    Sounds.invalid = love.audio.newSource("sound/invalid.wav", "static")

    Sounds.level_up = love.audio.newSource("sound/level_up.wav", "static")
    Sounds.erase = love.audio.newSource("sound/erase.wav", "static")
    return Sounds
end

function love.load()
    love.mouse.setVisible(false)
    font = love.graphics.newFont("font/Round9x13.ttf", 64)
    font:setFilter("nearest")
    music = love.audio.newSource("sound/thinking_and_tinkering.ogg", "stream")
    music:setVolume(0.7)
    set_background_fron_hex(COLORS.BLACK)
    math.randomseed(os.time()) -- Insures the first letter is random each time
    entered_words = 0
    lives = MAX_LIVES
    gamestate = 0
    score = 0
    text = get_first_letter()
    word_history = {}
    scroll_words = {}
    time_left_bg = 0
    love.graphics.setFont(font)
    love.keyboard.setKeyRepeat(true)
    sounds = load_sounds()
end

function get_first_letter()
    local _letter = "z"
    while has_value(letters_to_ignore, _letter) == true do
        _letter = string.char(math.random(97, 122))
    end
    return _letter
end

function love.textinput(t)
    if gamestate == 1 then
        if (t:match("%a+")) then
            text = text .. t
            play_sound(sounds.click)
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
                    play_sound(sounds.erase)
                end
            end
        end

        if key == "return" and text ~= "" and string.len(text) >= 2 then
            check_word(text)
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
    
end

function update_game(dt)
    if not music:isPlaying() then
        love.audio.play(music)
    end

    if entered_words > 3 then
        if time_left_bg >= 600 then
            go_to_gameover()
        end
        time_left_bg = time_left_bg + 0.5
    end
end

function update_gameover(dt)
    if music:isPlaying() then
        love.audio.stop(music)
    end

    for _, word in ipairs(scroll_words) do
        word:update(dt)
    end
end

function love.draw()
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

function draw_menu()
    set_draw_color_from_hex(COLORS.WHITE)
    love.graphics.print("Make Words", 240, 200, 0, 0.9, 0.9)
    love.graphics.print("press space", 260, 300, 0, 0.7, 0.7)
end

function draw_game()
    set_draw_color_from_hex(COLORS.GRAY)
    love.graphics.rectangle("fill", 0, time_left_bg, 800, 600)

    set_draw_color_from_hex(COLORS.WHITE)
    love.graphics.print(score, 5, 5)

    set_draw_color_from_hex(COLORS.RED)
    love.graphics.printf(text, 0, screen_height / 2 - font:getHeight() / 2, screen_width, "center")
    draw_lives(lives)
end

function draw_gameover()
    set_draw_color_from_hex(COLORS.WHITE)
    for index, word in ipairs(scroll_words) do
        if word.yPos < (love.graphics.getHeight() - 20) then
            word:draw()
        end
    end
    set_draw_color_from_hex(COLORS.BLACK)
    love.graphics.rectangle("fill", 0, 0, 800, 250)

    set_draw_color_from_hex(COLORS.GRAY)
    love.graphics.printf("game over", 0, 50 - font:getHeight() / 2, screen_width, "center")
    love.graphics.printf("score: " .. score, 0, 120 - font:getHeight() / 2, screen_width, "center")
    love.graphics.printf("Press R to Restart", 0, 200 - font:getHeight() / 2, screen_width, "center")
end

function draw_lives(lives)
    set_draw_color_from_hex(COLORS.WHITE)
    for a = 1, lives do
        love.graphics.rectangle("fill", 260 + (40 * a), 10, 20, 20)
    end
end

function word_was_good(word)
    entered_words = entered_words + 1
    score = score + get_word_value(word)
    time_left_bg = 0
    table.insert(word_history, word)
    text = string.sub(text, -1)
end

function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function play_sound(sound)
    love.audio.stop(sound)
    love.audio.play(sound)
end

function check_word(word)
    local _valid_word
    local _is_repeat

    for line in love.filesystem.lines("data/wordlist.txt") do
        if line == word then
            _valid_word = true
            break
        end
    end

    if _valid_word == true then
        _is_repeat = has_value(word_history, word)
        if _is_repeat == false then
            -- Word was good
            play_sound(sounds.correct)
            word_was_good(word)
        else
            -- Used reapet word
            lives = lives - 1
            text = string.sub(text, 1, 1)
            play_sound(sounds.invalid)
            check_lives()
        end
    else
        play_sound(sounds.invalid)
        go_to_gameover()
        text = ""
    end
end

function check_lives()
    if lives <= 0 then
        go_to_gameover()
    end
end

function go_to_gameover()
    gamestate = 2
    local _y_pos = 650
    for index, word in ipairs(word_history) do
        local _word = Word:new(word, _y_pos)
        table.insert(scroll_words, _word)
        _y_pos = _y_pos + 60
    end
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function get_word_value(word)
    local value = 0
    for i = 1, #word do
        local letter = string.sub(word, i, i)
        if char_values[letter] ~= nil then
            value = value + char_values[letter]
        end
    end
    return value
end

function set_draw_color_from_hex(rgba)
    --  where rgba is string as "#336699cc"
    local rb = tonumber(string.sub(rgba, 2, 3), 16)
    local gb = tonumber(string.sub(rgba, 4, 5), 16)
    local bb = tonumber(string.sub(rgba, 6, 7), 16)
    local ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
    love.graphics.setColor(love.math.colorFromBytes(rb, gb, bb, ab))
end

function set_background_fron_hex(rgba)
    --  where rgba is string as "#336699cc"
    local rb = tonumber(string.sub(rgba, 2, 3), 16)
    local gb = tonumber(string.sub(rgba, 4, 5), 16)
    local bb = tonumber(string.sub(rgba, 6, 7), 16)
    local ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
    love.graphics.setBackgroundColor(love.math.colorFromBytes(rb, gb, bb, ab))
end
