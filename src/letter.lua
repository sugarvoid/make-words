Letter = {}
Letter.__index = Letter

function Letter:new(str, prev_letter)
    local _letter = setmetatable({}, Letter)
    _letter.x = nil
    _letter.is_visible = true
    _letter.end_x = nil
    if prev_letter then
        _letter.x = prev_letter.x + prev_letter.width
    end
    _letter.value = str
    _letter.width = font:getWidth(str)
    _letter.color = nil
    return _letter
end

function Letter:move_to(pos)
    flux.to(self, 1, {x = pos[1], y = pos[2]}):ease("backinout")
end

function Letter:draw()
    if self.is_visible then
        if self.color then
            love.graphics.push("all")
            setColorHEX(self.color)
            love.graphics.print(self.value, self.x, self.y, 0, 1, 1)
            love.graphics.pop()
        else
            love.graphics.print(self.value, self.x, self.y, 0, 1, 1)
        end
    end
end
