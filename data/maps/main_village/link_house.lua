-- Lua script of map main_village/link_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local zelda_chores = require("scripts/maps/zelda_chores")

-- White surface for fade-in/out.
local white_surface = nil
local black_stripe = nil
local should_draw_white_surface = false
local should_draw_black_stripes = false
local opacity_time = 0

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started(destination_point)

  -- Continue the snores animation during dialogs.
  snores:get_sprite():set_ignore_suspend(true)

  -- Check if we need to launch the introduction (just after the LA beach dream).
  local intro_done = game:get_value("introduction_done")
  if intro_done == nil or not intro_done then
    -- Game's introducton, normally called only one time
    map:launch_intro()
  else
    -- Normal state
    map:launch_normal_state()
  end
end

-------------------------------------------------------------------------------

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

  local timer = sol.timer.start(map, timer_delay, function()
    opacity_time = opacity_time + timer_delay
    modify_opacity_to_transparent(opacity_time)
    local opacity = white_surface:get_opacity()
    if opacity == 0 then
      should_draw_white_surface = false
    end
    return opacity > 0 -- repeat
  end)
  timer:set_suspended_with_map(false)
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
    hero:set_enabled(false)
  else
    hero:unfreeze()
    hero:set_visible(true)
    hero:set_enabled(true)
  end
  -- Prevent or allow the player from pausing the game
  game:set_pause_allowed(not is_cinematic)

  -- Track the hero with the camera.
  if not is_cinematic then
    map:get_camera():start_tracking(hero)
  end
end

-------------------------------------------------------------------------------

-- Shake the camera to wake up Link.
function map:shake_camera()

  local camera = map:get_camera()
  local shake_config = {
    count = 9,
    amplitude = 4,
    speed = 90,
  }
  camera:shake(shake_config, function()
    -- Link finally wakes up.
    map:make_link_fall_off_bed()
    -- Zelda speaks to Link and explain the tasks to do.
    map:make_zelda_speak()
  end)

  -- Make Link fall at the middle of the shaking duration.
  sol.timer.start(map, 300, function()
    map:make_link_fall_off_bed()
  end)

end

-------------------------------------------------------------------------------

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

-- Zelda speak to Link and explain the tasks to do.
function map:make_zelda_speak()

  sol.timer.start(map, 2000, function()
    game:start_dialog("intro.zelda_resistant", function()
      sol.timer.start(map, 500, function()
        -- Make Zelda hurt Link with her rolling pin.
        zelda:set_visible(false)
        zelda_angry:set_visible(true)
        local zelda_angry_sprite = zelda_angry:get_sprite()
        zelda_angry_sprite:set_animation("walking")

        -- Repeat noise until Zelda stops to hit the hero.
        local hurt_count = 0
        sol.audio.play_sound("arrow_hit")
        sol.timer.start(map, 400, function()
          if hurt_count < 5 then
            hurt_count = hurt_count + 1
            sol.audio.play_sound("arrow_hit")
          end
          return not hurt_finished
        end)

        sol.timer.start(map, 2000, function()
          -- Stop music.
          sol.audio.stop_music()
          sol.audio.play_sound("hero_hurt")

          -- Set up correctly the entities we use.
          snores:remove()
          local bed_hero_sprite = bed:get_sprite()
          bed_hero_sprite:set_animation("hero_waking_aside")
          zelda_angry_sprite:set_paused(true)
          zelda_angry:remove()
          zelda:set_visible(true)

          -- Zelda tells Link she's waiting.
          game:start_dialog("intro.zelda_waiting", function()
            -- After, she moves and wait.
            sol.timer.start(map, 800, function()
              -- And confiscate the light saber!
              local sword = game:get_item("sword")
              sword:set_variant(1)

              -- Move Zelda.
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
  end)
end

-------------------------------------------------------------------------------

-- Configure the map to show the introduction.
function map:launch_intro()
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
end

--Configure the map to show the normal state.
function map:launch_normal_state()
  -- Configure Zelda.
  zelda:set_position(104, 88, 1) -- x, y, layer
  local zelda_sprite = zelda:get_sprite()
  zelda_sprite:set_animation("stopped")
  zelda_sprite:set_direction(3) -- down
  zelda_angry:remove()

  -- Remove the snores.
  snores:remove()

  -- Show the HUD.
  game:set_hud_enabled(true)

  -- Normal music.
  sol.audio.play_music("alttp/village")

  -- No cinematic black stripes.
  map:set_cinematic_mode(false)
end

-------------------------------------------------------------------------------

-- Called when the hero talks to Zelda.
-- Zelda asks him to do the 3 same chores, again and again in an infinite loop.
-- Hovever, only the first times are mandatory.
function zelda:on_interaction()

  -- Get chores state.
  local chore_step, chore_done, all_chores_done = zelda_chores:get_chores_state()

  -- Step 0: Feed the cat.
  if chore_step == 0 then
    if chore_done then
      zelda_chores:go_to_next_chore_step()
      zelda:on_interaction()
    else
      zelda_chores:set_chores_state(0, false, all_chores_done)
      local dialog_id = "chores.chore_0"
      if all_chores_done then
        dialog_id =  dialog_id .. "_again"
      end
      game:start_dialog(dialog_id, function()
        -- Give the player the cat food if he has not got it yet.
        if not game:has_item("cat_food") then
          hero:start_treasure("cat_food", 1, nil, function()
            game:start_dialog("intro.light_saber_confiscate")
          end)
        end
      end)
    end

  -- Step 1: Cut the grass in the garden.
  elseif chore_step == 1 then
    if chore_done then
      zelda_chores:go_to_next_chore_step()
      zelda:on_interaction()
    else
      local dialog_id = "chores.chore_1"
      if all_chores_done then
        dialog_id =  dialog_id .. "_again"
      end
      game:start_dialog(dialog_id)
    end

  -- Step 2: Bring back Zelda mail.
  elseif chore_step == 2 then
    if chore_done then

      -- Take the letter from the hero.
      local mail = game:get_item("mail")
      mail:set_variant(0)

      -- Get a different letter than last time.
      local chore_thanks = game:get_value("introduction_chore_2_thanks")
      if chore_thanks == nil then
        chore_thanks = math.random(4) - 1
      end

      -- Take the letter from the hero.
      local mail = game:get_item("mail")
      mail:set_variant(0)

      -- Zelda thanks Link and reads the letter.
      game:start_dialog("chores.chore_2_thanks_" .. chore_thanks, game:get_player_name(), function()

        -- Write in savegame the next letter.
        chore_thanks = (chore_thanks + 1) % 4
        game:set_value("introduction_chore_2_thanks", chore_thanks)

        local should_give_back_light_saber = not all_chores_done

        -- Next chore.
        zelda_chores:go_to_next_chore_step()

        if should_give_back_light_saber then
          game:start_dialog("intro.zelda_removing_hearts", function()

            -- Remove 4 heart containers.
            local hearts_timer = sol.timer.start(game, 500, function()
              sol.audio.play_sound("danger")
              game:set_max_life(game:get_max_life() - 4)
              return game:get_max_life() > (5 * 4)
            end)
            hearts_timer:set_suspended_with_map(false)

            game:start_dialog("intro.light_saber_give_back", function()

              -- Give back light saber.
              local sword = game:get_item("sword")
              game:set_value("link_garden_door_open", true)  -- Open the garden door.

              hero:start_treasure("sword", 3, nil, function()
                -- Call this function again.
                zelda:on_interaction()
              end)
            end)
          end)
        else
          -- Call this function again.
          zelda:on_interaction()
        end

      end)

    else
      local dialog_id = "chores.chore_2"
      if all_chores_done then
        dialog_id =  dialog_id .. "_again"
      end
      game:start_dialog(dialog_id)
    end
  end
end

-- Prevent the player from leaving
function dont_leave_sensor:on_activated()

  -- Get chores state.
  local chore_step, chore_done, all_chores_done = zelda_chores:get_chores_state()

  -- Link cant leave the house only if he has not done
  -- the first chore at least one time.
  if chore_step == 0 and not all_chores_done then
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
