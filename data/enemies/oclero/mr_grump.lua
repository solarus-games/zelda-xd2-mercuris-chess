-- Mr Grump boss.

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local path_finding_targets = {}
local last_target
local initial_life = 300

local state  -- "running_away", "shooting"

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(initial_life)
  enemy:set_damage(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_hurt_style("boss")
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_hookshot_reaction("protected")

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
  local target = best_targets[math.random(#best_targets)]
  --last_target = target
  enemy:run_to_target(target)
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
  sprite:set_animation("walking")

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
  sol.timer.start(enemy, 50, function()

    local n = math.random(100)
    if n >= 95 then
      enemy:start_state_shooting()
      return false
    end
    return true
  end)
end

function enemy:start_state_shooting()

  state = "shooting"
  sol.timer.stop_all(enemy)

  enemy:stop_movement()
  sprite:set_direction(enemy:get_direction4_to(hero))
  sprite:set_animation("throwing", function()
    enemy:shoot_rupee()
    enemy:start_state_running_away()
  end)
end

function enemy:shoot_rupee()

  local projectile_breed
  local num_projectiles = 1
  if enemy:get_life() <= initial_life / 3 then
    num_projectiles = math.random(3)
  end

  sol.audio.play_sound("throw")

  for i = 1, num_projectiles do
    local projectile_breed = "rupee_green"

    if enemy:get_life() <= 2 * initial_life / 3 then
      local n = math.random(3)
      if n == 3 then
        projectile_breed = "rupee_red"
      elseif n == 2 then
        projectile_breed = "rupee_blue"
      end
    end

    local rupee = enemy:create_enemy({
      breed = projectile_breed,
    })
    rupee.can_attack_grump = false
    sol.timer.start(rupee, 300, function()
      rupee.can_attack_grump = true
    end)
  end
end

function enemy:on_hurt(attack)

  if attack ~= "script" then
    return
  end

  -- Hurt by his own rupee.
  sol.audio.play_sound("sonic_rings_lost")
  local x, y, layer = enemy:get_position()
  for i = 1, 1 + math.random(7) do
    sol.timer.start(enemy, math.random(200), function()
      map:create_pickable({
        x = x + math.random(64) - 32,
        y = y + math.random(64) - 32,
        layer = layer,
        treasure_name = "rupee",
        treasure_variant = math.random(3),
      })
    end)
  end
end

function enemy:on_collision_enemy(other_enemy)

  if other_enemy.get_money_value == nil then
    return
  end

  if not other_enemy.can_attack_grump then
    return
  end

  if sprite:get_animation() == "hurt" then
    return
  end

  local value = other_enemy:get_money_value()
  enemy:hurt(5)  -- Remove more life that with the sword.
end
