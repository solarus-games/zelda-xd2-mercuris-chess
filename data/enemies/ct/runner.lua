local enemy = ...

-- Runner.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 6,
  damage = 0,
  normal_speed = 64,
  faster_speed = 64,
}

behavior:create(enemy, properties)
