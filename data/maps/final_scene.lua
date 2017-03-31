-- Lua script of map final_scene.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local player_name = game:get_player_name()

local language_manager = require("scripts/language_manager")

-- Sunset effect
local sunset_effect = require("scripts/maps/sunset_effect")
-- Cinematic black lines
local black_stripe = nil
-- Final fade sprite
local fade_sprite = nil
local fade_x = 0
local fade_y = 0
local black_surface = nil
local end_text = nil

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- Hide or show HUD.
  game:set_hud_enabled(false)

  -- Prevent or allow the player from pausing the game
  game:set_pause_allowed(false)

  -- Let the sprite animation running.
  grump_and_zelda:get_sprite():set_ignore_suspend(true)

  -- Let the swell animation running.
  for i = 1, 10 do
    local swell_name = "swell_" .. i
    local swell_entity = map:get_entity(swell_name)
    if swell_entity ~= nil then
        swell_entity:get_sprite():set_ignore_suspend(true)
    end
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

  -- Freeze hero.
  local hero = map:get_hero()
  hero:set_visible(true)
  hero:freeze()

  -- Launch cinematic.
  map:start_cinematic()
end

-- Draw sunset then black stripes.
function map:on_draw(dst_surface)

  -- Sunset.
  sunset_effect:draw(dst_surface)
  
  -- Black stripes.
  map:draw_cinematic_stripes(dst_surface)

  -- Fade.
  if fade_sprite ~= nil then
    fade_sprite:draw(dst_surface, fade_x, fade_y)
  end

  -- Full black.
  if black_surface then
    black_surface:draw(dst_surface)
  end

  -- End text.
  if end_text then
    local quest_w, quest_h = sol.video.get_quest_size()
    end_text:draw(dst_surface, quest_w / 2, quest_h / 2)
  end
end


-- Draw the cinematic black stripes.
function map:draw_cinematic_stripes(dst_surface)

  -- Lazy creation of the black stripes.
  if black_stripe == nil then
    local quest_w, quest_h = sol.video.get_quest_size()
    black_stripe = sol.surface.create(quest_w, 24)
    black_stripe:fill_color({0, 0, 0})
  end
  
  -- Draw them.
  black_stripe:draw(dst_surface, 0, 0)
  black_stripe:draw(dst_surface, 0, 216)
end

-- Final cinematic.
function map:start_cinematic()

  sol.timer.start(map, 500, function()
    game:start_dialog("final.zelda_4", player_name, function()
      local hero_movement_1 = sol.movement.create("target")
      hero:set_direction(1) -- up
      hero:set_animation("walking")
      hero_movement_1:set_target(104, 192)
      hero_movement_1:set_speed(50)
      hero_movement_1:set_smooth(true)
      hero_movement_1:set_ignore_obstacles(true)
      hero_movement_1:start(hero, function()
        hero:set_direction(0) -- right
        hero:set_animation("stopped")

        sol.timer.start(map, 500, function()
          game:start_dialog("final.zelda_5", player_name, function()
            sol.timer.start(map, 500, function()
              game:start_dialog("final.mr_grump_3", function()
                sol.timer.start(map, 500, function()
                  game:start_dialog("final.zelda_6", player_name, function()
                  
                  -- Make the player disapear
                  local hero_movement_2 = sol.movement.create("target")
                  hero:set_direction(2) -- left
                  hero:set_animation("walking")
                  hero_movement_2:set_target(-32, 192)
                  hero_movement_2:set_speed(80)
                  hero_movement_2:set_smooth(true)
                  hero_movement_2:set_ignore_obstacles(true)
                  hero_movement_2:start(hero, function()

                    sol.timer.start(map, 500, function()
                      -- Then come back with cocktails
                      local hero_movement_3 = sol.movement.create("target")
                      hero:set_direction(0) -- right
                      hero:set_animation("carrying_walking")
                      hero_movement_3:set_target(104, 192)
                      hero_movement_3:set_speed(80)
                      hero_movement_3:set_smooth(true)
                      hero_movement_3:set_ignore_obstacles(true)

                      -- Make the cocktails move along the hero
                      cocktails:get_sprite():set_animation("walking")
                      local hero_x, hero_y = hero:get_position()
                      cocktails:set_position(hero_x, hero_y - 16)

                      function hero_movement_3:on_position_changed()
                        if cocktails then
                          local hero_x, hero_y = hero:get_position()
                          cocktails:set_position(hero_x, hero_y - 16)                      
                        end
                      end

                      hero_movement_3:start(hero, function()

                        hero:set_animation("carrying_stopped")
                        cocktails:get_sprite():set_animation("on_ground")
                        sol.timer.start(map, 1500, function()
                        
                          cocktails:remove()
                          hero:set_animation("stopped")

                          game:start_dialog("final.zelda_7", player_name, function()
                            sol.timer.start(map, 500, function()
                              hero:set_animation("dying")

                              sol.timer.start(map, 2000, function()
                                local hero_movement_4 = sol.movement.create("target")
                                hero:set_animation("walking")
                                hero:set_direction(2) -- left
                                hero_movement_4:set_target(-32, 192)
                                hero_movement_4:set_speed(80)
                                hero_movement_4:set_smooth(true)
                                hero_movement_4:set_ignore_obstacles(true)
                                hero_movement_4:start(hero, function()
                                  sol.timer.start(map, 1000, function()
                                    game:start_dialog("final.zelda_8", function()
                                      sol.timer.start(map, 500, function()
                                        -- TODO draw heart shape instead of ellipse
                                        fade_sprite = sol.sprite.create("entities/heart_fade")
                                        local camera_x, camera_y = map:get_camera():get_position()
                                        local zelda_x, zelda_y = grump_and_zelda:get_position()
                                        fade_x = zelda_x - camera_x
                                        fade_y = zelda_y - camera_y - 16
                                        fade_sprite:set_animation("close", function()
                                          -- Fill screen with black.
                                          local quest_w, quest_h = sol.video.get_quest_size()
                                          black_surface = sol.surface.create(quest_w, quest_h)
                                          black_surface:fill_color({0, 0, 0})

                                          sol.timer.start(map, 1000, function()
                                            local menu_font, menu_font_size = language_manager:get_menu_font()
                                            end_text = sol.text_surface.create{
                                              horizontal_alignment = "center",
                                              vertical_alignment = "middle",
                                              color = {255, 255, 255},
                                              font = menu_font,
                                              font_size = menu_font_size * 2,
                                              text_key = "final.end_text",
                                            }

                                            sol.timer.start(map, 2000, function()
                                              -- Hide text
                                              end_text = nil
                                              -- Launch Ending credits.
                                              local dialog_box = game:get_dialog_box()
                                              dialog_box:set_position("bottom")
                                              game:start_dialog("final.credits", function()
                                                -- Reset game.
                                                sol.main.reset()
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
      end)
    end)
  end)
  end)
end
