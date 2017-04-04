local enemy = ...

-- Red knight soldier.
local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 4,
  damage = 2,
  play_hero_seen_sound = true
}

behavior:create(enemy, properties)
