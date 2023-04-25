--man_sound.lua

function load_sounds()
  local sounds = {}
  Sounds.click = love.audio.newSource("sound/tick_004.ogg", "static")
  Sounds.correct = love.audio.newSource("sound/confirmation_004.ogg", "static")
  Sounds.invalid = love.audio.newSource("sound/error_006.ogg", "static")
  Sounds.level_up = love.audio.newSource("sound/level_up.wav", "static")
  Sounds.erase = love.audio.newSource("sound/erase.wav", "static")
  return Sounds
end
