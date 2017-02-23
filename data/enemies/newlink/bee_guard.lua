local enemy = ...

-- Bee Guard

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 3,
  damage = 2,
  play_hero_seen_sound = true,
  normal_speed = 32,
  faster_speed = 64,
  hurt_style = "monster"
}

behavior:create(enemy, properties)
