local screen_width, _ = love.graphics.getDimensions()


Word = {}
Word.__index = Word

function Word:new()
    local _d_word = setmetatable({}, Word)
    _d_word.letters = {}
    _d_word.x = 250
    _d_word.y = 250
    _d_word.position = {x=0, y=-200}
    _d_word.ox = 30
    _d_word.oy = 30
    _d_word.rot = math.rad(0)
    _d_word.starting_pos = {x=0, y=0}
    return _d_word
end

function Word:update(dt, mx, my)

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
    local _last_part = nil
    local _next_index = nil
    local new_part = nil
    if #self.letters > 0 then
        _last_part = self.letters[#self.letters] or 1
        _next_index = #self.letters + 1
        new_part = Letter:new(str, _last_part)
    else
        new_part = Letter:new(str, _last_part)
        new_part.x = self.x
    end
    new_part.y = self.y
    table.insert(self.letters, new_part)
    --print("word got a new letter: " .. str )
end

function Word:move(new_x, new_y)
    self.position.x = new_x
    self.position.y = new_y
end


function Word:backspace()
   --print("backspace")
   local last = #self.letters
   table.remove(self.letters)
   --print(#self.letters)
end

function Word:draw()
    for _, p in ipairs(self.letters) do
        p:draw()
    end
end

function Word:reset()

end
