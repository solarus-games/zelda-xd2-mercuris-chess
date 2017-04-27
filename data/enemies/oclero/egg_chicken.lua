local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local chicken_list -- Store chicken list to add chicken later.

-- Event called when the enemy is initialized.
function enemy:on_created()

  sprite = enemy:create_sprite("enemies/oclero/egg_golden")
  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:set_invincible() -- Chicken eggs cannot be broken.
end

function enemy:on_restarted()
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

-- Create movement in the given direction.
-- Hatch after collision with obstacle or after max distance reached.
function enemy:roll(angle, max_distance)

  sprite:set_direction( math.floor(2 * angle / math.pi) )
  movement = sol.movement.create("straight")
  movement:set_angle(angle)
  movement:set_speed(64)
  movement:set_max_distance(max_distance)
  movement:start(enemy)  
  function movement:on_obstacle_reached()
    enemy:start_hatching()
  end
  function movement:on_finished()
    enemy:start_hatching()
  end
end

-- Add chicken list.
function enemy:add_to_list(new_chicken_list)

  chicken_list = new_chicken_list
end

-- Start the hatching animations.
function enemy:start_hatching()

  enemy:stop_movement()
  sol.timer.start(enemy, 500, function()
    sprite:set_animation("shaking")
    sol.timer.start(enemy, 1000, function()
      sprite:set_animation("opening")
      function sprite:on_animation_finished()
        enemy:finish_hatching()
      end
    end)
  end)
end

-- Create chocobo enemy and destroy egg.
function enemy:finish_hatching()

  local dir = sprite:get_direction()
  local x, y, layer = enemy:get_position()
  local prop = {x = x, y = y, layer = layer, direction = 0, breed = "oclero/flying_chicken"}
  local chick = map:create_enemy(prop)
  if chicken_list then -- Add chicken to list.
    chicken_list[#chicken_list + 1] = chick
  end
  enemy:remove()
end
