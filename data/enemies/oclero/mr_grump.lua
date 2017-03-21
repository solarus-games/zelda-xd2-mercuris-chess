-- Mr Grump boss.

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local state
local path_finding_targets = {}

local initial_life = 120

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(initial_life)
  enemy:set_damage(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  for target in map:get_entities("path_finding_target") do
    path_finding_targets[#path_finding_targets + 1] = target
  end
end

function enemy:on_restarted()

  if state == nil or state == "running_away" then
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

  -- Look for a random spot far away from the hero.
  local best_targets = {}
  for _, target in ipairs(path_finding_targets) do
    local distance = target:get_distance(hero)
    if distance > 200 then
      best_targets[#best_targets + 1] = target
    end
  end
  if #best_targets == 0 then
    -- Wrong configuration of the room.
    return
  end
  local target = best_targets[math.random(#best_targets)]
  movement = sol.movement.create("target")
  movement:set_speed(96)
  movement:set_target(target)
  movement:set_smooth(true)
  movement:start(enemy)
end

-- Runs aways from the hero and shoots some rupees.
function enemy:start_state_running_away()

  state = "running_away"
  enemy:run_away()
  sol.timer.start(enemy, 2000, function()
    enemy:run_away()
    return true  -- Repeat.
  end)
end
