local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Legal king movements.
local distance = 48
local moves = {
  {  distance,         0 },
  {  distance, -distance },
  {         0, -distance },
  { -distance, -distance },
  { -distance,         0 },
  { -distance,  distance },
  {         0,  distance },
  {  distance,  distance },
}

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_invincible()
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()

  local index_to_hero = enemy:get_direction8_to(hero) + 1
  local index = (index_to_hero + math.random(3) - 2) % 8
  if index == 0 then
    index = 8
  end
  local dx, dy = unpack(moves[index])
  local num_attempts = 1

  while enemy:test_obstacles(dx, dy) do
    if num_attempts >= #moves then
      -- No legal move: just do nothing for now.
      sol.timer.start(enemy, 1000, function()
        enemy:restart()
      end)
      return
    end
    index = (index % #moves) + 1
    dx, dy = unpack(moves[index])
    num_attempts = num_attempts + 1
  end

  local x, y = enemy:get_position()
  movement = sol.movement.create("target")
  movement:set_target(x + dx, y + dy)
  movement:set_speed(48)
  movement:set_smooth(false)
  movement:start(enemy, function()
    enemy:restart()
  end)

  function movement:on_obstacle_reached()
    enemy:restart()
  end
end
