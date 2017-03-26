-- Lua script of map sunset_creek.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local sunset_effect = require("scripts/maps/sunset_effect")

-- Cinematic black lines
local black_stripe = nil
local cinematic_mode = false

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  map:make_seagull_move(seagull_flying_1, 30)
  map:make_seagull_move(seagull_flying_2, 50)
  map:make_seagull_move(seagull_flying_3, 40)
end

-- Call when map needs to be drawn.
function map:on_draw(dst_surface)
  sunset_effect:draw(dst_surface)
  
  if cinematic_mode then
    map:draw_cinematic_stripes(dst_surface)
  end
end

-- Move the seagull npc
function map:make_seagull_move(seagull, speed)
  local seagull_sprite = seagull:get_sprite()
  seagull_sprite:set_animation("walking")
  seagull_sprite:set_paused(false)

  local movement = sol.movement.create("target")
  local seagull_x, seagull_y = seagull:get_position()
  
  if seagull_x < 0 then
    seagull_sprite:set_direction(0) -- right
    movement:set_target(320 + 32, seagull_y)
  elseif seagull_x > 320 + 32 then
    seagull_sprite:set_direction(2) -- left
    movement:set_target(- 32, seagull_y)
  -- else
  --   seagull_sprite:set_direction(0) -- right
  --   movement:set_target(320 + 32, seagull_y)
  end

  movement:set_speed(speed)
  movement:set_smooth(true)
  movement:set_ignore_obstacles(true)

  movement:start(seagull, function()
    map:make_seagull_move(seagull, speed)
  end)
end

-- Launch the final scene when cinematic sensor activated
function cinematic_sensor:on_activated()
  map:set_cinematic_mode(true)
  map:start_cinematic()
end

-- Draw the cinematic black stripes
function map:draw_cinematic_stripes(dst_surface)
  if black_stripe == nil then
    local quest_w, quest_h = sol.video.get_quest_size()
    black_stripe = sol.surface.create(quest_w, 24)
    black_stripe:fill_color({0, 0, 0})
  end
  
  black_stripe:draw(dst_surface, 0, 0)
  black_stripe:draw(dst_surface, 0, 216)
end

-- Enable or disable the cinematic mode
function map:set_cinematic_mode(is_cinematic)

  -- Cinematic lines
  cinematic_mode = is_cinematic

  -- Hide or show HUD.
  game:set_hud_enabled(not is_cinematic)

  -- Freeze hero
  local hero = map:get_hero()
  if is_cinematic then
    hero:freeze()
  else
    hero:unfreeze()
  end
  
  -- Prevent or allow the player from pausing the game
  game:set_pause_allowed(not is_cinematic)

  -- Track the hero with the camera.
  if not is_cinematic then
    map:get_camera():start_tracking(hero)
  end
end

-- Launch the final cinematic
function map:start_cinematic()
  -- TODO
  -- dialogs, etc

  -- then go to the final map (sunset scene)
  local hero = map:get_hero()
  hero:teleport("final_scene", "from_beach", "immediate")
end