local enemy = ...

-- Green duck soldier.

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 4,
  damage = 8,
  hurt_style = "monster",
  play_hero_seen_sound = true
}

behavior:create(enemy, properties)
