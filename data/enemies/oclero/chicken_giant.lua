local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local laying_time = 1000 -- In milliseconds.
local walking_speed = 48
local running_speed = 64
local state_index = 1 -- Current state index.
local state -- Current state.
local phase = 0 -- Current battle phase.
local rounds_per_phase = {4, 3, 1} -- Number of rounds per phase.
local life_per_round = {6, 4, 1} -- Number of life points per round at each phase.
local round = 1 -- Current round.
local remaining_life_per_round
local chocobo_eggs_per_round = { -- Types and number of eggs for each round. Y: yellow, R: red.
  [1] = {"Y", "Y", "R", "Y", "R", "Y", "Y", "R"},
  [2] = {"Y", "Y", "Y", "R", "Y", "Y", "Y", "R", 
         "Y", "R", "Y", "R", "Y", "Y", "Y", "R"},
  [3] = {"Y", "R", "Y", "Y", "Y", "R", "Y", "Y",
         "Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y",
         "Y", "Y", "R", "Y", "Y", "Y", "Y", "Y",
         "Y", "R", "Y", "Y", "Y", "R", "Y", "Y",
         "Y", "Y", "Y", "Y", "R", "R", "R", "R"},
  [4] = {"Y", "Y", "R", "Y", "Y", "Y", "R", "R"}
}
-- List of the possible states during each battle phase. States change cyclically.
local phase_states = {
  [1] = {"put_chocobo_eggs", "go_peck_hero", "fly_to_center"},
  [2] = {"put_chicken_eggs", "falling_attack", "chicken_attack", 
         "fly_to_center", "put_chocobo_eggs", "fly_to_center"},
  [3] = {"put_chicken_eggs", "falling_attack", "chicken_attack", "selfdestroy"}
}
local starting_location -- Eggs are created here.
local chicken_list = {} -- Chicken array for the flying phase.

function enemy:on_created()

  enemy:set_size(64, 64)
  enemy:set_origin(32, 60)
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(100) -- Life is determined by the list "life_per_round" and the number of rounds/phases.
  enemy:set_damage(2)
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  local x, y, layer = enemy:get_position()
  starting_location = {x = x, y = y, layer = layer}
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  if phase == 0 then  -- Phase 0 (before battle).
    enemy:first_fall()
  elseif state == "put_chocobo_eggs" then
    enemy:put_chocobo_eggs()
  elseif state == "go_peck_hero" then
    enemy:go_peck_hero()
  elseif state == "fly_to_center" then
    enemy:fly_to_center()
  elseif state == "put_chicken_eggs" then
    enemy:put_chicken_eggs()
  elseif state == "falling_attack" then
    enemy:falling_attack()
  elseif state == "chicken_attack" then
    enemy:chicken_attack()
  elseif state == "selfdestroy" then
    enemy:selfdestroy()
  end
end

-- Start next state of the current phase (cyclically), or start next phase.
function enemy:start_next_state()

  state_index = (state_index) % #phase_states[phase] + 1
  if state_index == 1 then
    round = round + 1 -- Next round.
    remaining_life_per_round = life_per_round[phase]
    -- Start next phase if necessary.
    if round > rounds_per_phase[phase] then
      phase = phase + 1
      round = 1
      state_index = 1
    end
  end
  state = phase_states[phase][state_index]
  -- Start next state of the round.
  enemy:restart()
  return state
end

-- Update remaining life for each round.
function enemy:on_hurt()

  if enemy:get_life() <= 0 then
    return
  end

  remaining_life_per_round = remaining_life_per_round - 1
  if remaining_life_per_round == 0 then
    enemy:start_next_state()
  end
end

------------------------- Phase 0: before battle -------------------------

function enemy:first_fall()

  enemy:set_invincible()
  sprite:set_animation("falling")
  sprite:set_xy(0, -100) -- Shift the sprite.
  sol.timer.start(enemy, 15, function()
    local dx, dy = sprite:get_xy()
    if dy < 0 then
      dy = dy + 1
      sprite:set_xy(dx, dy)
      return true
    else -- The enemy has already fallen.
      enemy:prepare_battle()
    end
  end)   
end

function enemy:prepare_battle()

  sprite:set_animation("stopped")
  phase = 1 -- Starting phase of battle. Change this for testing.
  ---- round = ? -- Uncomment to start at a given round, for testing.
  state = phase_states[phase][1]
  remaining_life_per_round = life_per_round[phase]
  sol.timer.start(enemy, 3000, function()
    enemy:restart()
  end)
end

------------------------- Phase 1: battle on ground -------------------------

-- Puts a chocobo egg backwards for the current direction.
function enemy:put_chocobo_eggs()

  enemy:set_invincible()
  sprite:set_animation("laying")
  local dir = sprite:get_direction()
  local x, y, layer = enemy:get_position()
  local num_eggs = #(chocobo_eggs_per_round[round])
  local eggs_counter = 0
  local prop = {x = x, y = y, layer = layer, direction = 0, breed = "oclero/egg_chocobo"}
  -- Change direction and put chocobo eggs.
  function sprite:on_animation_finished()
    -- Create one egg of a pair.
    eggs_counter = eggs_counter + 1
    local egg1 = map:create_enemy(prop)
    local color1 = chocobo_eggs_per_round[round][eggs_counter]
    egg1:set_chick_color(color1)
    local angle = math.pi * dir / 2
    egg1:roll(angle)    
    -- Create second egg of a pair, if necessary.
    if eggs_counter < num_eggs then
      eggs_counter = eggs_counter + 1
      sol.timer.start(enemy, 100, function()
        local egg2 = map:create_enemy(prop)
        local color2 = chocobo_eggs_per_round[round][eggs_counter]
        egg2:set_chick_color(color2)
        egg2:roll( angle + (math.pi / 4) )
      end)
    end
    -- Stop creating eggs if necessary.
    if eggs_counter >= num_eggs then
      sprite.on_animation_finished = nil -- Destroy event.
      sprite:set_animation("stopped")
      sol.timer.start(enemy, 150, function()
        -- Wait before next state (for a possible second egg).
        enemy:start_next_state()
      end)
      return
    end
    -- Prepare next direction to create more eggs.
    dir = (dir + 1) % 4
    sprite:set_direction(dir)
    sprite:set_animation("laying")
  end
end

-- Go to hero with a given type of speed.
function enemy:go_peck_hero()

  enemy:set_default_attack_consequences() -- Stop invincibility.
  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(walking_speed)
  movement:start(enemy)
  sol.timer.start(enemy, 1000, function()
    enemy:stop_movement()
    sprite:set_animation("pecking")
    function sprite:on_animation_finished()
      sprite.on_animation_finished = nil
      enemy:restart()
    end
  end)
end

------------------------- Phase 2: flying battle -------------------------

-- Fly to the starting point.
function enemy:fly_to_center()

  enemy:set_invincible() -- Make invincible while flying.
  self:set_can_attack(false) -- Cannot attack while flying.
  sprite:set_animation("flying")
  movement = sol.movement.create("target")
  movement:set_target(starting_location.x, starting_location.y)
  movement:set_speed(walking_speed)
  movement:set_ignore_obstacles(true)
  movement:start(enemy)
  function movement:on_finished()
    enemy:stop_movement()
    enemy:start_next_state()
  end
end

function enemy:put_chicken_eggs()

  enemy:set_invincible()
  enemy:set_can_attack(true)
  sol.timer.stop_all(enemy)
  sprite:set_animation("laying")
  sprite:set_direction(3)
  local x, y, layer = enemy:get_position()
  local prop = {x = x, y = y, layer = layer, direction = 0, breed = "oclero/egg_chicken"}
  chicken_list = {}
  function sprite:on_animation_finished()
    sprite.on_animation_finished = nil -- Destroy event.
    function sprite:on_animation_changed(animation)
      if animation ~= "flying" then
        sprite:set_animation("flying") -- Fix flying animation.
      end
    end
    sprite:set_animation("flying") -- Start flying.
    enemy:set_invincible()
    enemy:set_can_attack(false)
    -- Create chicken eggs.
    for dir = 0, 7 do
      local egg = map:create_enemy(prop)
      local angle = math.pi * dir / 4
      local max_distance = 64 -- Max distance before stop rolling.
      egg:roll(angle, max_distance)
      egg:add_to_list(chicken_list)
    end
  end
  -- Wait for chicken to start flying.
  sol.timer.start(enemy, 6000, function()
    enemy:chicken_circles() -- Prepare flying chicken!
  end)
end

-- Make chicken fly in circles.
function enemy:chicken_circles()

  -- Make chicken fly around the boss for a while.
  for _, chick in pairs(chicken_list) do
    chick:fly_around_boss(enemy)
  end
  -- Throw the chicken towards the hero.
  local chicken_index = 1
  sol.timer.start(enemy, 2000, function()
    sol.timer.start(enemy, 1000, function()
      local chick = chicken_list[chicken_index]
      --   chick:fly_to_hero()
      chicken_index = chicken_index + 1
      if chicken_index > #chicken_list then 
        --   enemy:start_next_state() -- Attack hero: next phase!
        return
      end
      return true
    end)
  end)
  -- Start next battle state!
  enemy:start_next_state()
end

function enemy:falling_attack()

  enemy:set_invincible()
  enemy:set_can_attack(false)
  function sprite:on_animation_changed(animation)
    if animation ~= "flying" then
      sprite:set_animation("flying") -- Fix flying animation.
    end
  end
  sprite:set_animation("flying") -- Start flying.
  -- Create movement towards hero.
  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(running_speed)
  movement:start(enemy)
  -- If the hero is close, start falling attack.
  function movement:on_position_changed()
    if enemy:get_distance(hero) < 16 then
      -- Stop fixing "flying" animation and stop movement.
      sprite.on_animation_changed = nil
      enemy:stop_movement()
      -- Falling attack! Allow to hurt and be hurt.
      sprite:set_animation("falling")
      sol.timer.start(enemy, 1000, function()
        enemy:set_default_attack_consequences()
        enemy:set_can_attack(true)
      end)
      sol.timer.start(enemy, 2000, function()
        if remaining_life_per_round > 0 then
          enemy:restart() -- Restart falling attack state.
        else
          enemy:start_next_state() -- Next state: throw remaining chicken!
        end
      end)
    end
  end
end

-- Throw all remaining chicken towards hero.
function enemy:chicken_attack()

  enemy:set_invincible()
  enemy:set_can_attack(false)
  enemy:stop_movement()
  function sprite:on_animation_changed(animation)
    if animation ~= "flying" then
      sprite:set_animation("flying") -- Fix flying animation.
    end
  end
  sprite:set_animation("flying") -- Start flying.
  -- Start random movement while flying.
  movement = sol.movement.create("random")
  movement:set_speed(walking_speed)
  movement:start(enemy)
  -- Throw remaining chicken.
  local chick_index = 1
  sol.timer.start(enemy, 1000, function()
    chick = chicken_list[chick_index]
    if chick:exists() then chick:fly_to_hero() end
    chick_index = chick_index + 1
    if chick_index <= #chicken_list then
      return true -- Throw next chicken.
    else
      sprite.on_animation_changed = nil -- Remove event.
      enemy:stop_movement()
      enemy:start_next_state()
    end
  end)
end

------------------------- Phase 3: death -------------------------

-- Create explosions and kill the enemy.
function enemy:selfdestroy()

  -- Kill remaining chocobos and flying chicken, if any.
  for chick in map:get_entities_by_type("enemy") do
    local breed = chick:get_breed()
    if breed == "oclero/chocobo_yellow" or breed == "oclero/flying_chicken" then
      chick:set_life(0) -- Destroy chick.
    end
  end
  -- Kill the enemy.
  enemy:set_life(0)
end
