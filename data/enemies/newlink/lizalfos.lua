local enemy = ...

-- Lizalfos.

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 5,
  damage = 6,
  play_hero_seen_sound = true,
  hurt_style = "monster",
  normal_speed = 48,
  faster_speed = 72
}

behavior:create(enemy, properties)
