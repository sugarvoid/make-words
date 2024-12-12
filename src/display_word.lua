-- Used only for displaying words on the game over screen. 


local screen_width, _ = love.graphics.getDimensions()
local scroll_speed = 30

DisplayWord = {}
DisplayWord.__index = DisplayWord

function DisplayWord:new(val, y_pos)
    local _word = setmetatable({}, DisplayWord)
    _word.val = val
    _word.y_pos = y_pos
    return _word
end

function DisplayWord:update(dt)
    self.y_pos = self.y_pos - scroll_speed * dt
    if self.y_pos > (love.graphics.getHeight() - 20) then
        return
    end
end

function DisplayWord:draw()
    love.graphics.printf(self.val, 0, self.y_pos, 800, "center", 0, 0.8, 0.8)
end
