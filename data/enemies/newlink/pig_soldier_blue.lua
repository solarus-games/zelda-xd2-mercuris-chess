local enemy = ...

-- Blue pig soldier.

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 8,
  damage = 16,
  play_hero_seen_sound = true,
  hurt_style = "monster"
}

behavior:create(enemy, properties)
