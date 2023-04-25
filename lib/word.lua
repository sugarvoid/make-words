--! word.lua

local screenWidth, screenHeight = love.graphics.getDimensions()
local scroll_speed = 30

Word = {}
-- MetaWord = {}
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
        -- TODO: Find way to remove word from scroll_words table
        --table.remove(scroll_words, self)
    end
end

function Word:draw()
    love.graphics.printf(self.val, 0, self.yPos, screenWidth, "center")
end








--[[Word = Object.extend(Object)

function Word:new(self, val, y)
    self.val = val
    self.x = 000000000
    self.y = y
end

function Word:update(self, dt)
    self.y = self.y - 2 * dt
    if self.x > (love.graphics.getHeight() - 20) then
        table.remove(typedWords, index)
    end
end

function Word:draw(self)
    love.graphics.printf(
        self.val, 
        0, 
        self.y, 
        screenWidth, 
        "center")
end
--]]