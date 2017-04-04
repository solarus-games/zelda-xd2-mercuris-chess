local enemy = ...
local map = enemy:get_map()

function enemy:on_created()

  enemy:set_life(10)
  enemy:set_damage(2)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_hurt_style("monster")
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  local movement = sol.movement.create("random")
  movement:set_speed(64)
  movement:start(enemy)
  enemy:get_sprite():set_animation("running")
end
