local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local sprite
local movement

-- Legal knight movements.
local jumps = {
  {  32, -16 },
  {  16, -32 },
  { -16, -32 },
  { -32, -16 },
  { -32,  16 },
  { -16,  32 },
  {  16,  32 },
  {  32,  16 },
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

  local index = math.random(#jumps)
  local dx, dy = unpack(jumps[index])
  local num_attempts = 1

  while enemy:test_obstacles() or enemy:test_obstacles(dx, dy) do
    if num_attempts >= #jumps then
      -- No legal jump: just do nothing for now.
      sol.timer.start(enemy, 1000, function()
        enemy:restart()
      end)
      return
    end
    index = (index % #jumps) + 1
    dx, dy = unpack(jumps[index])
    num_attempts = num_attempts + 1
  end

  local x, y = enemy:get_position()
  movement = sol.movement.create("target")
  movement:set_target(x + dx, y + dy)
  movement:set_speed(96)
  movement:set_smooth(false)
  movement:set_ignore_obstacles(true)
  movement:start(enemy, function()
    enemy:restart()
  end)
end
