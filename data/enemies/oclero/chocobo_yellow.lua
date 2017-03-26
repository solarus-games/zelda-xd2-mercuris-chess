local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/oclero/chick_yellow")
  enemy:set_life(2)
  enemy:set_damage(1)
end

function enemy:on_restarted()

  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(80)
  movement:start(enemy)
  sol.timer.start(enemy, 2000, function()
    enemy:stop_movement()
    sprite:set_animation("pecking")
    sol.timer.start(enemy, 1000, function()
      enemy:restart()
    end)
  end)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

-- Change the color of the chick. Red chick drops a small heart.
function enemy:set_color(color)

  if color == "R" then
    enemy:remove_sprite(sprite)
    sprite = enemy:create_sprite("enemies/oclero/chick_red")
    enemy:set_treasure("heart")
    enemy:restart()
  end
end
