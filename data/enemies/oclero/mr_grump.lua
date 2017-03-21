-- Mr Grump boss.

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local state
local initial_life = 120
local path_finding_targets = {}

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(initial_life)
  enemy:set_damage(2)

  for target in map:get_entities("path_finding_target") do
    path_finding_targets[#path_finding_targets + 1] = target
  end
end

function enemy:on_restarted()

  if state == nil then
    enemy:start_state_running_away()
  end
end

function enemy:on_movement_changed()

  local movement = enemy:get_movement()
  if movement ~= nil then
    sprite:set_direction(movement:get_direction4())
  end
end

function enemy:run_away()

  -- Look for a spot far away from the hero.
  local max_distance = 0
  local best_target
  for _, target in ipairs(path_finding_targets) do
    local distance = target:get_distance(hero)
    if distance > max_distance then
      max_distance = distance
      best_target = target
    end
  end
  movement = sol.movement.create("target")
  movement:set_speed(88)
  movement:set_target(best_target)
  movement:set_smooth(true)
  movement:start(enemy)
end

-- Runs aways from the hero and shoots some rupees.
function enemy:start_state_running_away()

  state = "running_away"
  enemy:run_away()
  sol.timer.start(enemy, 500, function()
    enemy:run_away()
    return true  -- Repeat.
  end)
end
