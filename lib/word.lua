--! word.lua

local screenWidth, _ = love.graphics.getDimensions()
local scroll_speed = 30

Word = {}
Word.__index = Word

function Word:new(val, yPos)
    local instance = setmetatable({}, Word)
    instance.val = val 
    instance.yPos = yPos
    --instance.xPos = 
    return instance
end


function Word:update(dt)
    self.yPos = self.yPos - scroll_speed * dt
    if self.yPos > (love.graphics.getHeight() - 20) then
       return
    end
end


function Word:draw()
    love.graphics.printf(self.val, 0, self.yPos, screenWidth, "center")
end

