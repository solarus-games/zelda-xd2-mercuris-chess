local enemy = ...

-- Mandible.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 3,
  damage = 2,
  hurt_style = "monster"
}

behavior:create(enemy, properties)
