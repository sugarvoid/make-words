--load_media.lua

function load_sounds()
  local Sounds = {}
  Sounds.click = love.audio.newSource("sound/click.wav", "static")
  Sounds.correct = love.audio.newSource("sound/correct.wav", "static")
  Sounds.invalid = love.audio.newSource("sound/invalid.wav", "static")
  Sounds.level_up = love.audio.newSource("sound/level_up.wav", "static")
  Sounds.erase = love.audio.newSource("sound/erase.wav", "static")
  return Sounds
end
