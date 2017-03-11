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

  -- Game's introducton, normally called only one time
  if destination_point ~= nil and destination_point:get_name() == "start_position" then

    -- Create white surface.
    local quest_w, quest_h = sol.video.get_quest_size()
    if white_surface == nil then
      white_surface = sol.surface.create(quest_w, quest_h)
      white_surface:fill_color({255, 255, 255})
    end

    -- Initialize cinematic black stripes.
    should_draw_black_stripes = true
    black_stripe = sol.surface.create(quest_w, 24)
    black_stripe:fill_color({0, 0, 0})

    -- Hide HUD.
    game:set_hud_enabled(false)

    -- Hide hero.
    local hero = map:get_hero()
    hero:freeze()
    hero:set_visible(false)

    -- Prevent the player from pausing the game
    game:set_pause_allowed(false)

    -- Instead, show Link in bed.
    local bed_hero_sprite = bed:get_sprite()
    bed_hero_sprite:set_animation("hero_sleeping")

    -- Fade-in from white to simulate a cloudy mountain top
    map:start_fadein_from_white(2000)

    -- Start Zelda's dialog.
    sol.timer.start(map, 2000, function()

      local dialog_box = game:get_dialog_box()
      dialog_box:set_position("bottom")
      game:start_dialog("intro.zelda_waking_up", function()
        sol.timer.start(map, 1500, function()
          game:start_dialog("intro.zelda_shaking", function()
            map:shake_camera()
          end)
        end)
      end)     
    end)
    

  -- Normal state
  else
    snores:remove()
    game:set_hud_enabled(true)
    sol.audio.play_music("village")
    bed:set_position(56, 101)  
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

  -- Draw cinematic black stripes.
  if should_draw_black_stripes and black_stripe ~= nil then
    black_stripe:draw(dst_surface, 0, 0)
    black_stripe:draw(dst_surface, 0, 216)    
  end

  -- Draw white fade-in.
  if should_draw_white_surface and white_surface ~= nil then
   white_surface:draw(dst_surface)
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
    if camera_shaking_count == camera_shaking_count_max / 2 then
      map:make_link_fall_off_bed()
    end

    if camera_shaking_count <= camera_shaking_count_max then
      map:shake_camera()
    else
      map:make_link_fall_off_bed()
    end
  end)

end

function map:make_link_fall_off_bed()
    local bed_hero_sprite = bed:get_sprite()
    bed_hero_sprite:set_animation("hero_sleeping_aside")
    local bed_hero_x, bed_hero_y = bed:get_position()
    bed:set_position(bed_hero_x + 8, bed_hero_y)
end