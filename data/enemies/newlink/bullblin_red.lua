local enemy = ...

-- Red Bullblin.

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 4,
  damage = 4,
  play_hero_seen_sound = false,
  normal_speed = 32,
  faster_speed = 48,
}

behavior:create(enemy, properties)
