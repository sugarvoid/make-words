Letter = {}
Letter.__index = Letter

function Letter:new(val, pos)
    local _letter = setmetatable({}, Letter)
    _letter.val = val
    _letter.x = pos[1]
    _letter.y = pos[2]
    _letter.display_pos = nil
    return _letter
end

function Letter:move_to(x,y)
    
end

function Letter:update(dt)
    self.y_pos = self.y_pos - scroll_speed * dt
    if self.y_pos > (love.graphics.getHeight() - 20) then
        return
    end
end

function Letter:draw()
    love.graphics.printf(self.val, 0, self.y_pos, 800, "center", 0, 0.8, 0.8)
end
