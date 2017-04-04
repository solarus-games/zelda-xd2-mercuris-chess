local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 12,
  damage = 4,
  normal_speed = 80,
  faster_speed = 80
}

behavior:create(enemy, properties)
