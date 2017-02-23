local enemy = ...

-- Skeletor.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 3,
  damage = 2
}

behavior:create(enemy, properties)
