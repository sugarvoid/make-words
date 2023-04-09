--load_media.lua

function load_sounds()
  local Sounds = {}
  Sounds.click = love.audio.newSource("sound/click.wav", "static")
  Sounds.correct = love.audio.newSource("sound/correct.wav", "static")
  Sounds.invaild = love.audio.newSource("sound/invaild.wav", "static")
  Sounds.level_up = love.audio.newSource("sound/level_up.wav", "static")
  Sounds.erase = love.audio.newSource("sound/erase.wav", "static")
  --local cursor_s = love.graphics.newImage("Media/Image/cursor.png")
  return Sounds
end
