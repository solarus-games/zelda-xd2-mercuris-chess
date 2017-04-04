local enemy = ...

-- Ropa.

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 4,
  damage = 2,
  normal_speed = 32,
  faster_speed = 32,
  hurt_style = "monster",
  movement_create = function()
    return sol.movement.create("random")
  end
}

behavior:create(enemy, properties)
