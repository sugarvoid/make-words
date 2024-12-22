
Word = {}
Word.__index = Word

function Word:new()
    local _d_word = setmetatable({}, Word)
    _d_word.letters = {}
    _d_word.x = 250
    _d_word.y = 250
    _d_word.position = {x = 0, y = -200}
    _d_word.ox = 30
    _d_word.oy = 30
    _d_word.rot = math.rad(0)
    _d_word.starting_pos = {x = 0, y = 0}
    return _d_word
end

function Word:clear()
    for k in pairs (self.letters) do
        self.letters[k] = nil
    end
end

function Word:get_value()
    local _word = ""
    for _, l in ipairs(self.letters) do
        _word = _word .. tostring(l.value)
    end
    return _word
end

function Word:add_part(str)
    local _last_letter = nil
    local _next_index = nil
    local _new_letter = nil
    if #self.letters > 0 then
        _last_letter = self.letters[#self.letters] or 1
        _next_index = #self.letters + 1
        _new_letter = Letter:new(str, _last_letter)
    else
        _new_letter = Letter:new(str, _last_letter)
        _new_letter.x = self.x
    end
    _new_letter.y = self.y
    table.insert(self.letters, _new_letter)
end

function Word:move(new_x, new_y)
    self.position.x = new_x
    self.position.y = new_y
end

function Word:remove_last_letter()
    table.remove(self.letters)
end

function Word:draw()
    for _, p in ipairs(self.letters) do
        p:draw()
    end
end
