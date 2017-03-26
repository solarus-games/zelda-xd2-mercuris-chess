local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local laying_time = 1000 -- In milliseconds.
local walking_speed = 48
local state_index = 1 -- Current state index.
local state -- Current state.
local phase = 0 -- Current battle phase.
local rounds_per_phase = {4, 4, 4} -- Number of rounds per phase.
local life_per_round = {5, 6} -- Number of life points per round at each phase.
local round = 1 -- Current round.
local remaining_life_per_round
local chocobo_eggs_per_round = { -- Types and number of eggs for each round. Y: yellow, R: red.
  [1] = {"R", "R", "R", "Y", "Y", "Y", "Y", "Y"},
  [2] = {"Y", "Y", "Y", "R", "Y", "Y", "Y", "R", 
         "Y", "Y", "Y", "R", "Y", "Y", "Y", "R"},
  [3] = {"Y", "Y", "R", "Y", "Y", "Y", "R", "Y"},
  [4] = {"Y", "R", "Y", "Y", "Y", "R", "Y", "Y",
         "Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y",
         "Y", "Y", "R", "Y", "Y", "Y", "Y", "Y",
         "Y", "Y", "Y", "Y", "Y", "Y", "R", "R"}
}
-- List of the possible states during each battle phase. States change cyclically.
local phase_states = {
  [1] = {"put_chocobo_eggs", "go_peck_hero"},
  [2] = {"fly_to_center", "put_chicken_eggs", "chicken_attack", "put_chocobo_eggs", "falling_attack"},
  [3] = {"dying"}
}
local starting_location -- Eggs are created here.

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

  -- Phase 0 (before battle).
  if phase == 0 then
    enemy:first_fall()
  -- Phase 1: put chocobo eggs, go peck the hero, wait for chocobos death (flying).
  elseif phase == 1 then
    if state == "put_chocobo_eggs" then
      enemy:put_chocobo_eggs()
    elseif state == "go_peck_hero" then
      enemy:go_peck_hero()
    end
  -- Phase 2: put chicken eggs and throw chicken, put chocobo eggs, fast flying/stomp attacks. 
  elseif phase == 2 then
    if state == "fly_to_center" then
      enemy:fly_to_center()
    elseif state == "put_chicken_eggs" then
      enemy:put_chicken_eggs()
    end
  -- Phase 3: dying phase.
  elseif phase == 3 then
    enemy:set_life(0) -- Kill the enemy.
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
      state = phase_states[phase][1]
      return
    end
  end
  state = phase_states[phase][state_index]
  -- Start next state of the round.
  enemy:restart()
  return state
end

-- Update remaining life for each round.
function enemy:on_hurt()

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
  sol.timer.start(enemy, 5, function()
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
  phase = 1 -- Start phase 1 (first battle phase).
  state = phase_states[1][1]
  remaining_life_per_round = life_per_round[phase]
  sol.timer.start(enemy, 1000, function()
    enemy:restart()
  end)
end

------------------------- Phase 1: battle on ground -------------------------

-- Puts a chocobo egg backwards for the current direction.
function enemy:put_chocobo_eggs()

  enemy:set_invincible()
  sprite:set_animation("laying")
  local frame_delay = sprite:get_frame_delay()
  local dir = sprite:get_direction()
  local x, y, layer = enemy:get_position()
  local num_eggs = #(chocobo_eggs_per_round[round])
  local eggs_counter = 0
  local prop = {x = x, y = y, layer = layer, direction = 0, breed = "oclero/egg_golden"}
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
  sprite:set_animation("flying")
  movement = sol.movement.create("target")
  movement:set_target(starting_location.x, starting_location.y)
  movement:set_speed(walking_speed)
  movement:set_ignore_obstacles(true)
  movement:start(enemy)
  function movement:on_finished()
    enemy:start_next_state()
  end
end

function enemy:put_chicken_eggs()

end