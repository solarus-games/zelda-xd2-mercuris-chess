-- Lua script of map main_village/link_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- White surface for fade-in/out.
local white_surface = nil
local black_stripe = nil
local should_draw_white_surface = false
local should_draw_black_stripes = false
local opacity_time = 0
local camera_shaking_to_right = true
local camera_shaking_count = 0

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started(destination_point)

  local intro_done = game:get_value("introduction_done")

  -- Game's introducton, normally called only one time
  if intro_done == nil or not intro_done then

    -- Create white surface.
    local quest_w, quest_h = sol.video.get_quest_size()
    if white_surface == nil then
      white_surface = sol.surface.create(quest_w, quest_h)
      white_surface:fill_color({255, 255, 255})
    end

    -- Set cinematic mode.
    map:set_cinematic_mode(true)

    -- Instead, show Link in bed.
    local bed_hero_sprite = bed:get_sprite()
    bed_hero_sprite:set_animation("hero_sleeping")

    -- Fade-in from white to simulate a cloudy mountain top
    map:start_fadein_from_white(2000)

    -- Hide Angry Zelda
    zelda_angry:set_visible(false)

    -- Start Zelda's dialog.
    sol.timer.start(map, 2000, function()
      local dialog_box = game:get_dialog_box()
      dialog_box:set_position("bottom")
      game:start_dialog("intro.zelda_waking_up", function()
        sol.timer.start(map, 2000, function()
          game:start_dialog("intro.zelda_shaking", function()
            -- Shake the camera.
            -- The next actions are done when camera shaking is finished.
            map:shake_camera()
          end)
        end)
      end)     
    end)
    

  -- Normal state
  else
    zelda:set_position(104, 88, 1)
    local zelda_sprite = zelda:get_sprite()
    zelda_sprite:set_animation("stopped")
    zelda_sprite:set_direction(3) -- down
    
    snores:remove()
    zelda_angry:remove()    
    game:set_hud_enabled(true)
    sol.audio.play_music("alttp/village")
    map:set_cinematic_mode(false)

  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Linear function
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)
local function linear(t, b, c, d)
  return c * t / d + b
end

-- Launch the white surface fade-in
function map:start_fadein_from_white(duration)
  should_draw_white_surface = true
  white_surface:set_opacity(255)

  function modify_opacity_to_transparent(current_time)
    local new_opacity = linear(current_time, 255, -255, duration)
    white_surface:set_opacity(new_opacity)
  end

  local timer_delay = 100

  sol.timer.start(map, timer_delay, function()
    opacity_time = opacity_time + timer_delay
    modify_opacity_to_transparent(opacity_time)
    local opacity = white_surface:get_opacity()
    if opacity == 0 then
      should_draw_white_surface = false
    end
    return opacity > 0 -- repeat
  end)
end

-- Call when map needs to be drawn.
function map:on_draw(dst_surface)

  -- Draw white fade-in.
  if should_draw_white_surface and white_surface ~= nil then
   white_surface:draw(dst_surface)
  end

  -- Draw cinematic black stripes.
  if should_draw_black_stripes and black_stripe ~= nil then
    black_stripe:draw(dst_surface, 0, 0)
    black_stripe:draw(dst_surface, 0, 216)    
  end
end

-- Shake the camera to wake up Link.
function map:shake_camera()

  local camera = map:get_camera()
  local camera_x, camera_y = camera:get_position()  
  local camera_shaking_count_max = 9

  local movement = sol.movement.create("straight")
  movement:set_speed(60)
  movement:set_smooth(true)
  movement:set_ignore_obstacles(true)

  -- Determine direction.
  if camera_shaking_to_right then
    movement:set_angle(0) -- right
  else
    movement:set_angle(math.pi) -- left
  end

  -- Max distance.
  local max_distance = 4
  movement:set_max_distance(max_distance)

  -- Inverse direction for next time.
  camera_shaking_to_right = not camera_shaking_to_right
  camera_shaking_count = camera_shaking_count + 1

  -- Launch the movement and repeat if needed.
  movement:start(camera, function()
    if camera_shaking_count == (camera_shaking_count_max - 1) / 2 then
      map:make_link_fall_off_bed()
    end

    if camera_shaking_count <= camera_shaking_count_max then
      map:shake_camera()
    else
      map:make_link_fall_off_bed()
         
      sol.timer.start(map, 2000, function()
        local dialog_box = game:get_dialog_box()
        dialog_box:set_position("bottom")
        game:start_dialog("intro.zelda_resistant", function()
          sol.timer.start(map, 500, function()
            -- Make Zelda hurt Link with her rolling pin.
            zelda:set_visible(false)
            zelda_angry:set_visible(true)

            local zelda_angry_sprite = zelda_angry:get_sprite()
            zelda_angry_sprite:set_animation("walking")

            local hurt_count = 0
            -- hurt noise
            sol.audio.play_sound("arrow_hit")            
            sol.timer.start(map, 400, function()
              if hurt_count < 5 then
                hurt_count = hurt_count + 1
                sol.audio.play_sound("arrow_hit")            
              end
              return not hurt_finished
            end)

            sol.timer.start(map, 2000, function()
              sol.audio.stop_music()
              sol.audio.play_sound("wrong")
              
              snores:remove()
              local bed_hero_sprite = bed:get_sprite()
              bed_hero_sprite:set_animation("hero_waking_aside")
              zelda_angry_sprite:set_paused(true)
              zelda_angry:remove()
              zelda:set_visible(true)
              
              game:start_dialog("intro.zelda_waiting", function()
                local zelda_movement = sol.movement.create("target")
                local zelda_x, zelda_y = zelda:get_position()
                zelda:set_position(zelda_x, zelda_y, 1)
                zelda_movement:set_speed(30)
                zelda_movement:set_smooth(true)
                zelda_movement:set_ignore_obstacles(true)
                zelda_movement:set_target(104, 88)
                zelda_movement:start(zelda, function()
                  zelda:stop_movement()
                  local zelda_sprite = zelda:get_sprite()
                  zelda_sprite:set_animation("stopped")
                  zelda_sprite:set_direction(3) -- down
                  sol.timer.start(map, 500, function()
                    map:make_link_go_out_of_bed()
                    game:set_value("introduction_done", true)
                    sol.audio.play_music("alttp/village")                    
                  end)

                end)
              end)

            end)
          end)
        end)
      end)
    end
  end)

end

-- Link falls off his bed.
function map:make_link_fall_off_bed()
  local bed_hero_sprite = bed:get_sprite()
  bed_hero_sprite:set_animation("hero_sleeping_aside")
  local bed_hero_x, bed_hero_y = bed:get_position()
  bed:set_position(bed_hero_x + 4, bed_hero_y)
  sol.audio.play_sound("bomb")  
end

-- Link finally wakes up and go out of his bed
function map:make_link_go_out_of_bed()
  -- Hide the hero in bed entity.
  local bed_hero_sprite = bed:get_sprite()
  bed_hero_sprite:set_animation("empty_open")
  -- Show the real hero instead.
  map:set_cinematic_mode(false)
  hero:start_jumping(0, 8, true)
  sol.audio.play_sound("hero_lands")  
end

-- Enable or disable the cinematic mode
function map:set_cinematic_mode(is_cinematic)
  -- Initialize cinematic black stripes.
  should_draw_black_stripes = is_cinematic
  if should_draw_black_stripes then
    if black_stripe == nil then
      local quest_w, quest_h = sol.video.get_quest_size()
      black_stripe = sol.surface.create(quest_w, 24)
      black_stripe:fill_color({0, 0, 0})
    end
  else
    black_stripe = nil
  end

  -- Hide or show HUD.
  game:set_hud_enabled(not is_cinematic)

  -- Hide of show hero.
  local hero = map:get_hero()
  if is_cinematic then
    hero:freeze()
    hero:set_visible(false)
  else
    hero:unfreeze()
    hero:set_visible(true)
  end
  -- Prevent or allow the player from pausing the game
  game:set_pause_allowed(not is_cinematic)

  -- Track the hero with the camera.
  if not is_cinematic then
    map:get_camera():start_tracking(hero)
  end
end

function zelda:on_interaction()

  -- Get chores state.
  local chore_step, chores_done = map:get_chores_state()

  -- Step 0: Feed the cat.
  if chore_step == 0 then
    game:start_dialog("chores.chore_0", function()
      -- Give the player the cat food if he has not got it yet.
      if not game:has_item("cat_food") then
        hero:start_treasure("cat_food")
      end
    end)

  -- Step 1: Cut the grass in the garden.
  elseif chore_step == 1 then
    game:start_dialog("chores.chore_1", function()
      
    end)
  -- Step 2: Do Zelda grocery (buy apple pie).
  elseif chore_step == 2 then

  end

end

-- Get the chores step.
-- Returns a pair: (number) chore_step, (boolean) chores_done 
function map:get_chores_state()
  local chores_done = game:get_value("introduction_chores_done")
  local chore_step = game:get_value("introduction_chore_step")
  
  if chores_done ==  nil then
    chores_done = false
  end

  if chore_step == nil then
    chore_step = 0
  end
  return chore_step, chores_done
end

-- Prevent the player from leaving
function dont_leave_sensor:on_activated()

  -- Get chores state.
  local chore_step, chores_done = map:get_chores_state()

  -- Link cant leave the house only if he has not done
  -- the first chore at least one time.
  if chore_step == 0 and not chores_done then
    game:start_dialog("chores.dont_leave", function()
      hero:freeze()
      hero:set_animation("walking")
      hero:set_direction(1)
      local movement = sol.movement.create("path")
      movement:set_path({ 2 })
      movement:set_speed(88)
      movement:start(hero, function()
        hero:unfreeze()
      end)
    end)
  end
end
