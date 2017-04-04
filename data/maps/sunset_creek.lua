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
function map:on_started(destination)

  -- Hide doctor_who
  doctor_who:set_visible(false)
  doctor_who:set_enabled(false)

  -- Prevent sprites from being suspended during dialogs.
  seagull_flying_1:get_sprite():set_ignore_suspend(true)
  seagull_flying_2:get_sprite():set_ignore_suspend(true)
  seagull_flying_3:get_sprite():set_ignore_suspend(true)
  grump_and_zelda:get_sprite():set_ignore_suspend(true)

  -- Launch the seagulls
  map:make_seagull_move(seagull_flying_1, 30)
  map:make_seagull_move(seagull_flying_2, 50)
  map:make_seagull_move(seagull_flying_3, 40)

  if destination == from_tardis then
    hero:set_visible(false)
    tardis:set_enabled(false)
    tardis_door:set_enabled(false)
  else
    map:set_doors_open("tardis_door", true)
  end
end

-- The TARDIS arrive in the creek
function map:on_opening_transition_finished(destination)
  if destination ~= from_tardis then
    return
  end

  hero:freeze()
  tardis:set_enabled(true)
  tardis_door:set_enabled(true)
  tardis:appear("entities/doctor_who/tardis_cache_creek.png", function()
    map:open_doors("tardis_door")
    tardis:get_sprite():set_animation("open")
    sol.timer.start(map, 500, function()
      hero:set_visible(true)
      hero:unfreeze()
      game:set_pause_allowed(true)
    end)
  end)
end

-- Call when map needs to be drawn.
map:register_event("on_draw", function(map, dst_surface)
  sunset_effect:draw(dst_surface)
  
  if cinematic_mode then
    map:draw_cinematic_stripes(dst_surface)
  end
end)

-- Move the seagull npc
function map:make_seagull_move(seagull, speed)
  local seagull_sprite = seagull:get_sprite()
  seagull_sprite:set_animation("walking")
  seagull_sprite:set_paused(false)

  local movement = sol.movement.create("target")
  local seagull_x, seagull_y = seagull:get_position()
  
  if seagull_x < 160 then
    -- Seagull is in the left part of screen
    seagull_sprite:set_direction(0) -- right
    movement:set_target(320 + 64, seagull_y)
  else
    -- Seagull is in the right part of screen
    seagull_sprite:set_direction(2) -- left
    movement:set_target(- 64, seagull_y)
  end

  movement:set_speed(speed)
  movement:set_smooth(true)
  movement:set_ignore_obstacles(true)

  movement:start(seagull, function()
    map:make_seagull_move(seagull, speed)
  end)
end

-- Launch the final scene when cinematic sensor activated
function cinematic_sensor_1:on_activated()
  map:start_cinematic()
end

-- Launch the final scene when cinematic sensor activated
function cinematic_sensor_2:on_activated()
  map:start_cinematic()
end

-- Launch the final scene when cinematic sensor activated
function cinematic_sensor_3:on_activated()
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
  if cinematic_mode then
    return
  end

  map:set_cinematic_mode(true)

  sol.timer.start(map, 1000, function()
    local hero = map:get_hero()
    local movement_1 = sol.movement.create("target")
    local hero_sprite = hero:get_sprite()
    hero_sprite:set_direction(3) -- down
    hero_sprite:set_animation("walking")
    movement_1:set_target(176, 344)
    movement_1:set_speed(50)
    movement_1:set_smooth(true)
    movement_1:start(hero, function()
      hero:get_sprite():set_animation("stopped")
      
      sol.timer.start(map, 500, function()
        doctor_who:set_visible(true)
        doctor_who:set_enabled(true)

        local movement_2 = sol.movement.create("target")
        local doctor_sprite = doctor_who:get_sprite()
        doctor_sprite:set_direction(3) -- down
        doctor_sprite:set_animation("walking")
        movement_2:set_target(200, 344)
        movement_2:set_speed(80)
        movement_2:set_smooth(true)
        
        movement_2:start(doctor_who, function()
          doctor_sprite:set_animation("stopped")
          doctor_sprite:set_paused(true)
          sol.timer.start(map, 1000, function()
            local dialog_box = game:get_dialog_box()
            dialog_box:set_position("top")
            

              -- Start dialogs between Zelda dand Mr Grump
              game:start_dialog("final.the_doctor_1", function()
                sol.timer.start(map, 1500, function()
                  -- Move camera towards Zelda and Mr Grump
                  local camera = map:get_camera()
                  camera:start_manual()

                  local zelda_camera_x, zelda_camera_y = camera:get_position_to_track(grump_and_zelda)
                  local camera_movement = sol.movement.create("target")
                  camera_movement:set_speed(50)
                  camera_movement:set_smooth(true)
                  camera_movement:set_ignore_obstacles(true)
                  camera_movement:set_target(zelda_camera_x, zelda_camera_y)
                  camera_movement:start(camera, function()
                    dialog_box:set_position("bottom")
                    game:start_dialog("final.mr_grump_1", function()
                      sol.timer.start(map, 1000, function()
                        dialog_box:set_position("bottom")
                        local player_name = game:get_player_name()
                        game:start_dialog("final.zelda_1", player_name, function()
                          sol.timer.start(map, 500, function()
                            dialog_box:set_position("bottom")
                            game:start_dialog("final.mr_grump_2", function()
                              sol.timer.start(map, 2000, function()
                                dialog_box:set_position("top")
                                game:start_dialog("final.the_doctor_2", function()
                                  sol.timer.start(map, 1000, function()
                                    dialog_box:set_position("bottom")
                                    game:start_dialog("final.zelda_2", function()
                                      sol.timer.start(map, 1000, function()
                                        dialog_box:set_position("bottom")
                                        game:start_dialog("final.zelda_3", player_name, function()
                                          sol.timer.start(map, 500, function()
                                            -- Go to the final map (sunset scene).
                                            local hero = map:get_hero()
                                            hero:teleport("final_scene", "from_beach", "fade")
                                          end)   
                                        end)
                                      end)
                                    end)
                                  end)
                                end)
                              end)
                            end)
                          end)
                        end)
                      end)
                    end)
                end)
              end)            
            end)
          end)
        end)    
      end)
    end)
   end)
end