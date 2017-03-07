local enemy = ...
local sprite

function enemy:on_created()

  enemy:set_life(4)
  enemy:set_damage(12)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_restarted()

  local movement = sol.movement.create("random_path")
  movement:set_speed(48)
  movement:start(enemy)

  sol.timer.start(enemy, 200, function()
    local direction4 = sprite:get_direction()
    sprite:set_direction((direction4 + 1) % 4)
    return true
  end)
end
