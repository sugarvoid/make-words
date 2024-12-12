local screen_width, _ = love.graphics.getDimensions()

WordPart = {}
WordPart.__index = WordPart

function WordPart:new(str, prev_part)
    local _part = setmetatable({}, WordPart)
    _part.x = nil
    _part.end_x = nil
    if prev_part then
         _part.x = prev_part.x + prev_part.width
    end
    _part.value = str
    _part.width = font:getWidth(str)
    return _part
end

function WordPart:draw()
    love.graphics.print(self.value, self.x, self.y, 0, 1, 1) 
end

---------------------------------------------------------------------

Word = {}
Word.__index = Word

function Word:new()
    local _d_word = setmetatable({}, Word)
    _d_word.parts = {}
    _d_word.x = 50
    _d_word.y = 400
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
    --self.parts = {}
    for k in pairs (self.parts) do
        self.parts[k] = nil
    end
    
end

function Word:add_part(str)
    --print("this is the passed in teir " .. tier)
    local _last_part = nil
    local _next_index = nil
    local new_part = nil
    if #self.parts > 0 then
        _last_part = self.parts[#self.parts] or 1
        _next_index = #self.parts + 1
        new_part = WordPart:new(str, _last_part)
        
    else
        new_part = WordPart:new(str, _last_part)
        new_part.x = self.x
    end
    new_part.y = self.y
    table.insert(self.parts, new_part)
end

function Word:move(new_x, new_y)
    self.position.x = new_x
    self.position.y = new_y
end


function Word:backspace()
    print("backspace")
    local last = #self.parts
    table.remove(self.parts)
    print(#self.parts)
end

function Word:draw()
    for _, p in ipairs(self.parts) do
        p:draw()
    end
end

function Word:reset()

end
