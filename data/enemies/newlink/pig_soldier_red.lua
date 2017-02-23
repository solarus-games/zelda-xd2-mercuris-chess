local enemy = ...

-- Red pig soldier.

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 12,
  damage = 24,
  play_hero_seen_sound = true,
  hurt_style = "monster"
}

behavior:create(enemy, properties)
