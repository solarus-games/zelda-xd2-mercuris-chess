local enemy = ...

-- Blue duck soldier

local behavior = require("enemies/lib/soldier")

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 5,
  damage = 10,
  hurt_style = "monster",
  play_hero_seen_sound = true
}

behavior:create(enemy, properties)
