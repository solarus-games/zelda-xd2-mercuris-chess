-- Mr Grump boss.

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local path_finding_targets = {}
local last_target
local children = {}
local initial_life = 120

local state  -- "running_away", "throwing"

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(initial_life)
  enemy:set_damage(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_invincible()

  for target in map:get_entities("path_finding_target") do
    path_finding_targets[#path_finding_targets + 1] = target
  end
end

function enemy:on_restarted()

  enemy:start_state_running_away()
end

function enemy:on_movement_changed()

  local movement = enemy:get_movement()
  if movement ~= nil then
    sprite:set_direction(movement:get_direction4())
  end
end

function enemy:set_vulnerable(vulnerable)

  if vulnerable == nil then
    vulnerable = true
  end

  enemy:set_invincible()
  if vulnerable then
    enemy:set_attack_consequence("sword", 1)
  end
end

-- Moves toward a random target far from the hero.
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
  last_target = best_targets[math.random(#best_targets)]
  enemy:run_to_target(last_target)
end

-- Moves toward the given target.
function enemy:run_to_target(target)

  movement = sol.movement.create("target")
  movement:set_speed(96)
  movement:set_target(target)
  movement:set_smooth(true)
  movement:start(enemy)
end

-- Runs aways from the hero and shoots some rupees.
function enemy:start_state_running_away()

  state = "running_away"
  sol.timer.stop_all(enemy)
  enemy:set_vulnerable(true)

  if last_target ~= nil then
    enemy:run_to_target(last_target)
  else
    enemy:run_away()
  end

  sol.timer.start(enemy, 2000, function()
    -- Change the movement.
    enemy:run_away()
    return true  -- Repeat.
  end)

  -- Attack sometimes.
  sol.timer.start(enemy, 500, function()

    if sprite:get_animation() ~= "walking" then
      -- Not the appropriate time: try again later.
      return true
    end

    local n = math.random(10)
    if n >= 6 then
      enemy:start_state_shooting()
      return false
    end
    return true
  end)
end

function enemy:start_state_shooting()

  state = "shooting"
  sol.timer.stop_all(enemy)

  enemy:set_vulnerable(false)
  enemy:stop_movement()
  sprite:set_direction(enemy:get_direction4_to(hero))
  sprite:set_animation("throwing", function()
    enemy:shoot_rupee()
  end)
end

function enemy:shoot_rupee()

  local projectile_breed
  if enemy:get_life() > 2 * initial_life / 3 then
    projectile_breed = "alttp/rupee_green"
  elseif enemy:get_life() > initial_life / 3 then
    projectile_breed = "alttp/rupee_blue"
  else
    projectile_breed = "alttp/rupee_red"
  end

  sol.audio.play_sound("rupee_counter")
  children[#children + 1] = enemy:create_enemy({
    breed = projectile_breed,
  })
end
