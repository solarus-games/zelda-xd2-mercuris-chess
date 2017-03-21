-- Mr Grump boss.

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local path_finding_targets = {}
local eyeglass_dialog_done = false
local searching_timer
local initial_life = 300

local state  -- "running_away", "shooting", "charging", "searching", "finished"

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(initial_life)
  enemy:set_damage(4)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_hurt_style("boss")
  enemy:set_invincible()
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_hookshot_reaction("protected")

  for target in map:get_entities("path_finding_target") do
    path_finding_targets[#path_finding_targets + 1] = target
  end
end

function enemy:on_restarted()

  if state == "searching" then
    enemy:start_state_searching()
  elseif state == "finished" then
    enemy:start_state_finished()
  else
    enemy:start_state_running_away()
  end
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
  enemy:set_attack_consequence("sword", "protected")
  searching_timer = nil

  enemy:run_away()

  sol.timer.start(enemy, 2000, function()
    -- Change the movement.
    enemy:run_away()
    return true  -- Repeat.
  end)

  -- Attack sometimes.
  sol.timer.start(enemy, 50, function()

    local n = math.random(100)
    if n <= 1 and enemy:can_charge() then
      enemy:start_state_charging()
      return false
    elseif n <= 6 then
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

-- Returns whether Grump can charge towards the hero without hitting obstacles.
function enemy:can_charge()

  local enemy_x, enemy_y = enemy:get_position()
  local hero_x, hero_y = hero:get_position()
  local dx, dy = hero_x - enemy_x, hero_y - enemy_y

  -- Sample on 20 positions on the path.
  local num_samples = 20
  for i = 1, num_samples do
    if enemy:test_obstacles(i * dx / num_samples, i * dy / num_samples) then
      return false
    end
  end

  return true
end

function enemy:start_state_charging()

  state = "charging"
  sol.timer.stop_all(enemy)
  enemy:stop_movement()

  sol.audio.play_sound("boss_charge")
  sprite:set_direction(enemy:get_direction4_to(hero))
  sprite:set_animation("loading")
  sol.timer.start(enemy, 1000, function()
    sprite:set_animation("attack_ready", function()
      sprite:set_animation("attacking")
      movement = sol.movement.create("straight")
      movement:set_smooth(false)
      movement:set_angle(enemy:get_angle(hero))
      movement:set_max_distance(enemy:get_distance(hero) + 96)
      movement:set_speed(160)

      local running_sound_timer = sol.timer.start(enemy, 150, function()
        sol.audio.play_sound("running")
        return true
      end)

      local running_timeout_timer = sol.timer.start(enemy, 3000, function()
        enemy:restart()
      end)

      movement:start(enemy, function()
        -- Max distance reached.
        enemy:restart()
      end)

      function movement:on_obstacle_reached()
        running_timeout_timer:stop()
        running_sound_timer:stop()
        sol.audio.play_sound("running_obstacle")
        sprite:set_animation("hit")
        enemy:stop_movement()
        sol.timer.start(1000, function()
          if not eyeglass_dialog_done then
            game:start_dialog("dungeon_2.9f.grump_eyeglass_lost", function()
              enemy:start_state_searching()
            end)
          else
            enemy:start_state_searching()
          end
        end)
      end

    end)
  end)
end

function enemy:start_state_searching()

  state = "searching"
  sol.timer.stop_all(enemy)
  enemy:stop_movement()
  sprite:set_animation("searching")

  enemy:set_attack_consequence("sword", 5)

  sol.timer.start(enemy, 800, function()
    sprite:set_direction(math.random(4) - 1)
    return true
  end)

  if searching_timer == nil then
    searching_timer = sol.timer.start(map, 3000, function()
      -- This state and timer persist when the enemy is hurt.

      if enemy:get_life() <= 0 or state == "finished" then
        return
      end

      if not eyeglass_dialog_done then
        eyeglass_dialog_done = true
        game:start_dialog("dungeon_2.9f.grump_eyeglass_found", function()
          enemy:start_state_running_away()
        end)
      else
        enemy:start_state_running_away()
      end
    end)
  end
end

-- Explosion of rupees that replaces the usual explosion animations.
function enemy:start_state_finished()

  state = "finished"
  sol.timer.stop_all(enemy)
  enemy:stop_movement()
  enemy:set_invincible()
  enemy:set_can_attack(false)
  sprite:set_animation("hurt")

  local x, y, layer = enemy:get_position()
  local hero_x = hero:get_position()
  sprite:set_direction(hero_x > x and 0 or 2)  -- Look right or left.

  sol.timer.start(enemy, 3000, function()
    local num_explosions = 20
    sol.timer.start(enemy, 150, function()
      sol.audio.play_sound("explosion")

      for i = 1, 21 - num_explosions do
        local n = math.random(3)
        local sprite_id = "enemies/rupee_green"
        if n == 2 then
          sprite_id = "enemies/rupee_blue"
        elseif n == 3 then
          sprite_id = "enemies/rupee_red"
        end

        local rupee = map:create_custom_entity({
          x = x,
          y = y - 5,
          layer = layer,
          width = 16,
          height = 16,
          direction = 0,
          sprite = sprite_id,
        })
        local movement = sol.movement.create("straight")
        movement:set_ignore_obstacles(true)
        movement:set_max_distance(320)
        movement:set_angle(math.random() * 2 * math.pi)
        movement:set_speed(320)
        movement:start(rupee, function()
          rupee:remove()
        end)
      end

      num_explosions = num_explosions - 1
      return num_explosions > 0
    end)
  end)
end

function enemy:on_hurt(attack)

  if enemy:get_life() <= 0 then
    -- Ending animation.
    enemy:set_life(1)
    enemy:set_invincible()
    enemy:start_state_finished()
    return
  end

  if attack == "sword" then
    -- Hurt by the sword while searching the eyeglass.
    sprite:set_animation("hurt_searching")
  end

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
  enemy:hurt(5)
end
