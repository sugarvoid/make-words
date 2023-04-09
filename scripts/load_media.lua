--load_media.lua

function load_media()
  local Sounds = {}
  Sounds.click = love.audio.newSource("sound/Sound/02.wav", "static")
  Sounds.correct = love.audio.newSource("sound/Sound/01.wav", "static")
  Sounds.invaild = love.audio.newSource("sound/Sound/01.wav", "static")
  Sounds.level_up = love.audio.newSource("sound/Sound/01.wav", "static")
  local cursor_s = love.graphics.newImage("Media/Image/cursor.png")
  return Sounds, cursor_s
end
