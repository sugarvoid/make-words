local screen_width, _ = love.graphics.getDimensions()
local scroll_speed = 30

Word = {}
Word.__index = Word

function Word:new(val, y_pos)
    local _word = setmetatable({}, Word)
    _word.val = val
    _word.y_pos = y_pos
    return _word
end

function Word:update(dt)
    self.y_pos = self.y_pos - scroll_speed * dt
    if self.y_pos > (love.graphics.getHeight() - 20) then
        return
    end
end

function Word:draw()
    love.graphics.printf(self.val, 0, self.y_pos, screen_width, "center")
end
