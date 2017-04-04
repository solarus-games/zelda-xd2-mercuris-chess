-- Lua script of enemy rat.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

-- A rat who walk randomly in the room

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
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()

  movement = sol.movement.create("straight")
  movement:set_target(hero)
  movement:set_speed(88)
  movement:start(enemy)

  local m = sol.movement.create("straight")
  m:set_speed(0)
  m:start(self)
  local direction4 = math.random(4) - 1
  self:go(direction4)
end



-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  local m = sol.movement.create("straight")
  m:set_speed(0)
  m:start(self)
  local direction4 = math.random(4) - 1
  self:go(direction4)
end

-- An obstacle is reached: stop for a while, looking to a next direction.
function enemy:on_obstacle_reached(movement)
  -- stop for a while
  local animation = sprite:get_animation()
  if animation == "walking" then
    sprite:set_animation("stopped")
    sol.timer.start(enemy, 500, function()
      enemy:go(math.random(4)-1)
    end)
  end
end

-- The movement is finished: stop for a while, looking to a next direction.
function enemy:on_movement_finished(movement)
  -- Same thing as when an obstacle is reached.
  self:on_obstacle_reached(movement)
end

-- Makes the soldier walk towards a direction.
function enemy:go(direction4)

  -- Set the sprite.
  sprite:set_animation("walking")
  sprite:set_direction(direction4)

  -- Set the movement.
  local m = self:get_movement()
  local max_distance = 20 + math.random(60)
  m:set_max_distance(max_distance)
  m:set_smooth(true)
  m:set_speed(88)
  m:set_angle(direction4 * math.pi / 2)
end

