flux = require "lib.flux"

require("src.letter")
require("src.word")
require("src.display_word")

local version = "2.0a"
local music
font = nil
local word_history
local letters_to_ignore = {'x', 'q', 'u', 'z', 'w', 'y', 'i', 'v'} -- For starting letter
local sounds
local score
local entered_words
local scroll_words
local gamestate -- 0 = menu, 1 = game, 2 = gameover
local lives
local time_left_bg
local MAX_LIVES = 3
local game_mode = ""
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

local txtPlay = nil
local txtChain = nil
local txtDeluxe = nil
local txtChainInfo = nil
local chainInfoStr = "The last letter becomes your next word's first letter."
local txtDeluxeInfo = nil
local deluxeInfoStr = "Use random letter from previous word in next word."
local menu_index = 1
local required_letters = {}
local word_obj = Word:new()
local tutorial_tbl = nil
local starting_pairs = {
    {"a", "l"},
    {"c", "h"},
    {"e", "d"},
    {"f", "l"},
    {"g", "o"},
    {"i", "h"},
    {"i", "t"},
    {"m", "e"},
}

local r_letter_pos = {
    {200, 80},
    {500, 80},
}

local TUTORIAL_CHAIN = {
    "Type a word \n starting with " .. tostring(word_obj:get_value()),
    "Keep going"
}

local TUTORIAL_DELUXE = {
    "Type a word",
    "Use this letter \n in next word",
    "Enter next word \n before time goes out",
    "Now use both letters"
}

local COLORS = {
    BLACK = "#0a010d",
    BLUE = "#144b66",
    YELLOW = "#ffbf40",
    RED = "#871e2e"
}

function set_up_text_objs()
    txtPlay = love.graphics.newText(font, "play")
    txtChain = love.graphics.newText(font, "chain")
    txtDeluxe = love.graphics.newText(font, "deluxe")

    txtChainInfo = love.graphics.newText(font, chainInfoStr)
    txtDeluxeInfo = love.graphics.newText(font, deluxeInfoStr)
end

function load_sounds()
    local _sounds = {}
    _sounds.click = love.audio.newSource("sound/click.wav", "static")
    _sounds.click:setVolume(0.7)

    _sounds.correct = love.audio.newSource("sound/correct.wav", "static")
    _sounds.correct:setVolume(0.2)

    _sounds.invalid = love.audio.newSource("sound/invalid.wav", "static")

    _sounds.erase = love.audio.newSource("sound/erase.wav", "static")
    return _sounds
end

function love.load()
    love.mouse.setVisible(false)
    font = love.graphics.newFont("font/Round9x13.ttf", 64)
    font:setFilter("nearest")
    love.graphics.setFont(font)
    love.keyboard.setKeyRepeat(true)
    gamestate = 0
    set_up_text_objs()
    music = love.audio.newSource("sound/thinking_and_tinkering.ogg", "stream")
    music:setVolume(0.7)
    set_background_fron_hex(COLORS.BLUE)
    math.randomseed(os.time()) -- Insures the first letter is random each time
    entered_words = 0
    lives = MAX_LIVES
    sounds = load_sounds()
end

function get_first_letter()
    local _letter = ""
    while has_value(letters_to_ignore, _letter) == true do
        _letter = string.char(math.random(97, 122))
    end
    return _letter
end

function love.textinput(t)
    if gamestate == 1 then
        if (t:match("%a+")) then
            word_obj:add_part(t)
            play_sound(sounds.click)
        end
    end
end

function love.keypressed(key, _, isrepeat)
    if key == "escape" then
        love.event.quit()
    end

    if gamestate == 0 then
        if isrepeat == false then
            if key == "left" then
                menu_index = clamp(1, menu_index - 1, 2)
            elseif key == "right" then
                menu_index = clamp(1, menu_index + 1, 2)
            end
        end

        if key == "space" then
            if menu_index == 1 then
                game_mode = "chain"
            else
                game_mode = "deluxe"
            end
            start_game()

            set_background_fron_hex(COLORS.BLACK)
        end
    end

    if gamestate == 2 then
        if key == "r" then
            love.load()
        end
    end

    if gamestate == 1 then
        if key == "backspace" then
            if game_mode == "chain" then
                if #word_obj.letters > 1 then
                    word_obj:remove_last_letter()
                    play_sound(sounds.erase)
                end
            else
                if #word_obj.letters > 0 then
                    word_obj:remove_last_letter()
                    play_sound(sounds.erase)
                end
            end
        end

        if key == "return" and #word_obj.letters >= 2 then
            check_word(word_obj:get_value())
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
    flux.update(dt)
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
    set_draw_color_from_hex(COLORS.YELLOW)
    love.graphics.print("Make Words", 240, 200, 0, 0.9, 0.9)

    if menu_index == 1 then
        love.graphics.rectangle("line", 200, 350 - 4, txtChain:getWidth() * 0.7, txtChain:getHeight() * 0.7)
        love.graphics.printf(chainInfoStr, 250, 420, 900, "left", 0, 0.4, 0.4)
    elseif menu_index == 2 then
        love.graphics.rectangle("line", 470, 350 - 4, txtDeluxe:getWidth() * 0.7, txtDeluxe:getHeight() * 0.7)
        love.graphics.printf(deluxeInfoStr, 250, 420, 900, "left", 0, 0.4, 0.4)
    end
    love.graphics.draw(txtChain, 200, 350, 0, 0.7, 0.7)
    love.graphics.draw(txtDeluxe, 470, 350, 0, 0.7, 0.7)
    love.graphics.print("v " .. version, 5, 575, 0, 0.4, 0.4)
end

function draw_game()
    set_draw_color_from_hex(COLORS.BLUE)
    love.graphics.rectangle("fill", 0, time_left_bg, 800, 600)

    set_draw_color_from_hex(COLORS.YELLOW)
    love.graphics.print(score, 5, 5)

    word_obj:draw()

    if game_mode == "deluxe" then
        required_letters[1]:draw()
        required_letters[2]:draw()
    end

    draw_lives(lives)
end

function draw_gameover()
    set_draw_color_from_hex(COLORS.RED)
    for index, word in ipairs(scroll_words) do
        if word.y_pos < (love.graphics.getHeight() - 20) then
            word:draw()
        end
    end
    set_draw_color_from_hex(COLORS.BLACK)
    love.graphics.rectangle("fill", 0, 0, 800, 250)

    set_draw_color_from_hex(COLORS.RED)
    love.graphics.printf("game over", 0, 60 - font:getHeight() / 2, 800 + (800 * 0.6), "center", 0, 0.6, 0.6)
    love.graphics.printf("score " .. score, 0, 110 - font:getHeight() / 2, 800 + (800 * 0.6), "center", 0, 0.6, 0.6)
    love.graphics.printf("Press R to Restart", 0, 180 - font:getHeight() / 2, 800 + (800 * 0.6), "center", 0, 0.6, 0.6)
end

function draw_lives(lives)
    set_draw_color_from_hex(COLORS.YELLOW)
    for a = 1, lives do
        love.graphics.rectangle("fill", 260 + (40 * a), 10, 20, 20)
    end
end

function word_was_good(word)
    entered_words = entered_words + 1
    score = score + get_word_value(word)
    time_left_bg = 0
    table.insert(word_history, word)
    if game_mode == "chain" then
        local next_starting_letter = word_obj.letters[#word_obj.letters].value
        word_obj:clear()
        word_obj:add_part(next_starting_letter)
    elseif game_mode == "deluxe" then
        local _options = shuffled_range_take(2, 1, #word_obj.letters)

        required_letters[1] = table.copy(word_obj.letters[_options[1]])
        required_letters[2] = table.copy(word_obj.letters[_options[2]])

        required_letters[1]:move_to(r_letter_pos[1])
        required_letters[2]:move_to(r_letter_pos[2])

        word_obj:clear()
    end
end

function get_next_required_letters(word)
    local _word_t = word_to_table(word)
    _word_t = table.shuffle(word_t)
    required_letters = {word_t[1], word_t[2]}
end

function has_value(tab, val)
    for _, value in ipairs(tab) do
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

function is_word_valid(word)
    for line in love.filesystem.lines("data/wordlist.txt") do
        if line == word then
            return true
        end
    end
    return false
end

local function all_true(t)
    for _, v in pairs(t) do
        if not v then return false end
    end
    return true
end

function check_word(word)
    local _valid_word
    local _is_repeat

    _valid_word = is_word_valid(word)

    if game_mode == "chain" then
        if _valid_word == true then
            _is_repeat = has_value(word_history, word)
            if _is_repeat == false then
                -- Word was good
                play_sound(sounds.correct)
                word_was_good(word)
            else
                -- Used reapet word
                lives = lives - 1
                play_sound(sounds.invalid)
                check_lives()
            end
        else
            play_sound(sounds.invalid)
            go_to_gameover()
            word_obj:clear()
        end
    elseif game_mode == "deluxe" then
        local _word_t = word_to_table(word)
        local _bool_tbl = {}

        for _, l in ipairs(required_letters) do
            table.insert(_bool_tbl, table.contains(_word_t, l.value))
        end

        if all_true(_bool_tbl) then
            play_sound(sounds.correct)
            word_was_good(word)
        else
            print("bad word")
        end
    end
end

function check_lives()
    if lives <= 0 then
        go_to_gameover()
    end
end

function go_to_gameover()
    local _y_pos = 665
    for _, word in ipairs(word_history) do
        local _word = DisplayWord:new(word, _y_pos)
        table.insert(scroll_words, _word)
        _y_pos = _y_pos + 60
    end
    gamestate = 2
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function get_word_value(word)
    local _value = 0
    for i = 1, #word do
        local letter = string.sub(word, i, i)
        if char_values[letter] ~= nil then
            _value = _value + char_values[letter]
        end
    end
    return _value
end

function set_draw_color_from_hex(rgba)
    --  where rgba is string as "#336699cc"
    local _rb = tonumber(string.sub(rgba, 2, 3), 16)
    local _gb = tonumber(string.sub(rgba, 4, 5), 16)
    local _bb = tonumber(string.sub(rgba, 6, 7), 16)
    local _ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
    love.graphics.setColor(love.math.colorFromBytes(_rb, _gb, _bb, _ab))
end

function set_background_fron_hex(rgba)
    --  where rgba is string as "#336699cc"
    local _rb = tonumber(string.sub(rgba, 2, 3), 16)
    local _gb = tonumber(string.sub(rgba, 4, 5), 16)
    local _bb = tonumber(string.sub(rgba, 6, 7), 16)
    local _ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
    love.graphics.setBackgroundColor(love.math.colorFromBytes(_rb, _gb, _bb, _ab))
end

function create_used_word_file()
    local _success, _message = love.filesystem.write("used_words.txt", "hello")
    if _success then
        print('file created')
    else
        print('file not created: ' .. _message)
    end
end

function start_game()
    gamestate = 1
    score = 0
    word_history = {}
    scroll_words = {}
    time_left_bg = 0
    if game_mode == "chain" then
        tutorial_tbl = TUTORIAL_CHAIN
        word_obj:add_part(get_first_letter())
    elseif game_mode == "deluxe" then
        local _r_num = math.random(#starting_pairs)
        local _starting_letter = starting_pairs[_r_num]
        tutorial_tbl = TUTORIAL_DELUXE
        required_letters = {
            Letter:new(_starting_letter[1]),
        Letter:new(_starting_letter[2])}
        required_letters[1].x = r_letter_pos[1][1]
        required_letters[1].y = r_letter_pos[1][2]
        required_letters[2].x = r_letter_pos[2][1]
        required_letters[2].y = r_letter_pos[2][2]
    else
        print("Error: game mode was not set")
    end
end

function table.contains(tbl, x)
    local _found = false
    for _, v in pairs(tbl) do
        if v == x then
            _found = true
        end
    end
    return _found
end

function word_to_table(word)
    local _t = {}
    for i = 1, #word do
        _t[i] = word:sub(i, i)
    end
    return _t
end

function table.shuffle(t)
    local _tbl = {}
    for i = 1, #t do
        _tbl[i] = t[i]
    end
    for i = #_tbl, 2, -1 do
        local _j = math.random(i)
        _tbl[i], _tbl[_j] = _tbl[_j], _tbl[i]
    end
    return _tbl
end

function table.copy(t)
    local _u = {}
    for k, v in pairs(t) do
        _u[k] = v
    end
    return setmetatable(_u, getmetatable(t))
end

function shuffle(arr)
    for i = 1, #arr - 1 do
        local _j = math.random(i, #arr)
        arr[i], arr[_j] = arr[_j], arr[i]
    end
end

function shuffled_range_take(n, a, b)
    local _numbers = {}
    for i = a, b do
        _numbers[i] = i
    end
    shuffle(_numbers)

    local _take = {}
    for i = 1, n do
        _take[i] = _numbers[i]
    end
    return _take
end
