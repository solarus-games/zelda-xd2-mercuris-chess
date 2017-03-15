-- Marine tries to wake up Link.
-- Then progressively, she speaks more and more
-- like Zelda who is actually shouting at Link
-- in the real life (Link is dreaming!)
-- Then shake the screen, with a beeeeeep sound
-- and move to another map, where Link is in the bed.

local map = ...
local game = map:get_game()

-- White surface for fade-in/out.
local quest_w, quest_h = sol.video.get_quest_size()
local white_surface = sol.surface.create(quest_w, quest_h)
white_surface:fill_color({255, 255, 255})
local should_draw_white_surface = false
local opacity_time = 0

-- Event called at initialization time,
-- as soon as this map becomes is loaded.
function map:on_started()
  -- Fade-in from white to simulate a cloudy mountain top
  map:start_fadein_from_white(6000)

  -- Camera is moved manually
  local camera = map:get_camera()
  camera:start_manual()
  camera:set_position(320, 0)

  -- Cinematic black stipes.
  camera:set_size(320, 192)
  camera:set_position_on_screen(0, 24)

  -- Hide HUD.
  game:set_hud_enabled(false)

  -- Hide hero.
  local hero = map:get_hero()
  hero:freeze()
  hero:set_visible(false)

  -- Prevent the player from pausing the game
  game:set_pause_allowed(false)

  -- Instead, show a castaway hero lying on the beach.
  local castaway_hero_sprite = castaway_hero:get_sprite()
  castaway_hero_sprite:set_animation("dying")
  castaway_hero_sprite:set_paused(true)
  castaway_hero_sprite:set_direction(0)
  castaway_hero_sprite:set_frame(castaway_hero_sprite:get_num_frames() - 1)

  -- Hide and show the right palm trees
  palm_trees_parallax:set_visible(false)
  palm_trees_static:set_visible(true)

  -- Launch first seagull
  map:make_seagull_move(seagull_4, 30)

  -- Wait a bit on the mountain top with the egg.
  sol.timer.start(map, 3000, function()
    map:move_camera_down_to_the_beach()
  end)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Move camera from top of the mountain down to the beach
function map:move_camera_down_to_the_beach()
  -- Create the movement.
  local movement = sol.movement.create("straight")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_angle(3 * math.pi / 2) -- down

  -- Max y for the camera movement is Marine's Y
  local camera = map:get_camera()
  local marine_camera_x, marine_camera_y = camera:get_position_to_track(marine)
  movement:set_max_distance(marine_camera_y)

  -- Marine begins to enter when the camera reach the y 162.
  function movement:on_position_changed()
   local x, y = movement:get_xy()
   if y == 96 then
     sol.timer.start(map, 1000, function()
       sol.audio.play_sound("la_seagull")
     end)
     map:make_seagull_move(seagull_2, 40)
   elseif y == 162 then
     map:make_marine_enter_beach()
   end
  end

  -- Move seagull 1
  map:make_seagull_move(seagull_1, 40)

  -- Launch the camera movement
  movement:start(camera, function()
    -- Hide and show the right palm trees
    palm_trees_parallax:set_visible(true)
    palm_trees_static:set_visible(false)
  end)

end

-- Move Marine from outside the map to the East of the beach.
function map:make_marine_enter_beach()
  marine:get_sprite():set_animation("walking")
  local marine_x, marine_y = marine:get_position()
  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(576, marine_y)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    map:make_marine_go_to_wood_piece()
  end)

end

-- Move Marine to the floating wood piece.
function map:make_marine_go_to_wood_piece()

  local marine_x, marine_y = marine:get_position()
  local marine_sprite = marine:get_sprite()
  marine_sprite:set_animation("walking")

  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(marine_x, marine_y + 16)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    marine_sprite:set_animation("stopped")
    marine_sprite:set_paused(true)
    -- Marine is watching the wooden piece.
    sol.timer.start(map, 1000, function()
      local dialog_box = game:get_dialog_box()
      dialog_box:set_position("bottom")
      game:start_dialog("intro.marine_wondering")
      map:make_marine_come_back_from_wood_piece()
    end)
  end)

end

-- Move Marine back to beach.
function map:make_marine_come_back_from_wood_piece()

  local marine_x, marine_y = marine:get_position()
  local marine_sprite = marine:get_sprite()
  marine_sprite:set_animation("walking")
  marine_sprite:set_paused(false)

  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(marine_x, marine_y - 16)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    -- Continue Marine's balade on the beach.
    map:make_marine_go_to_wreck()
  end)

end

-- Move Marine to the ship wreck.
function map:make_marine_go_to_wreck()

  local wreck_x, wreck_y = ship_wreck:get_position()
  local marine_x, marine_y = marine:get_position()
  marine:get_sprite():set_animation("walking")

  -- Once the free movement of the camera is done,
  -- the camera is locked on Marine.
  map:get_camera():start_tracking(marine)

  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(wreck_x + 96, marine_y)
  movement:set_ignore_obstacles(true)

  local seagull_3_x, seagull_3_y = seagull_3:get_position()
  seagull_3_x = seagull_3_x + 32

  -- Move the seagull when Marine is approaching.
  function movement:on_position_changed()
   local x, y = movement:get_xy()
   if x == seagull_3_x then
     local seagull_movement = sol.movement.create("target")
     local seagull_sprite = seagull_3:get_sprite()
     seagull_sprite:set_paused(false)
     seagull_movement:set_speed(60)
     seagull_movement:set_smooth(true)
     seagull_movement:set_ignore_obstacles(true)
     seagull_movement:set_target(0, 0)
     seagull_movement:start(seagull_3)
     sol.timer.start(map, 500, function()
       sol.audio.play_sound("la_seagull")
     end)
   end
  end

  movement:start(marine, function()
    -- Mark a little stop: Marine is seeing the hero far away.
    local marine_sprite = marine:get_sprite()
    marine_sprite:set_animation("stopped")
    marine_sprite:set_paused(true)

    sol.timer.start(map, 1000, function()
      game:start_dialog("intro.marine_exclaming")
      -- Then she runs to the hero.
      map:make_marine_go_to_link()
    end)
  end)

end

-- Move Marine to the hero lying on the beach.
function map:make_marine_go_to_link()

  local marine_sprite = marine:get_sprite()
  marine_sprite:set_animation("walking")
  marine_sprite:set_frame_delay(marine_sprite:get_frame_delay() / 4)
  marine_sprite:set_paused(false)

  local movement = sol.movement.create("target")
  movement:set_speed(120)
  movement:set_smooth(true)
  movement:set_target(castaway_hero, 24, 0)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    marine:get_sprite():set_animation("stopped")
    marine:get_sprite():set_paused(true)
    local dialog_box = game:get_dialog_box()
    dialog_box:set_position("bottom")
    local player_name = game:get_player_name()
    game:start_dialog("intro.marine_waking_up", player_name, function()
      game:start_dialog("intro.marine_to_zelda")  -- This dialog persists accross the map change.
      map:start_fadeout_to_white(2000)
    end)
  end)

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
    movement:set_target(640 + 32, seagull_y)
  elseif seagull_x > 640 then
    seagull_sprite:set_direction(2) -- left
    movement:set_target(- 32, seagull_y)
  else
    seagull_sprite:set_direction(0) -- right
    movement:set_target(640 + 32, seagull_y)
  end

  movement:set_speed(speed)
  movement:set_smooth(true)
  movement:set_ignore_obstacles(true)

  movement:start(seagull, function()
    map:make_seagull_move(seagull, speed)
  end)
end

-- Linear function
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)
local function linear(t, b, c, d)
  return c * t / d + b
end

-- Launch the white surface fade-out
function map:start_fadeout_to_white(duration)
  should_draw_white_surface = true
  white_surface:set_opacity(0)

  function modify_opacity_to_white(current_time)
    local new_opacity = linear(current_time, 0, 255, duration)
    white_surface:set_opacity(new_opacity)
  end

  local timer_delay = 100

  local timer = sol.timer.start(map, timer_delay, function()
    opacity_time = opacity_time + timer_delay
    modify_opacity_to_white(opacity_time)
    return white_surface:get_opacity() < 255 -- repeat
  end)
  timer:set_suspended_with_map(false)

  timer = sol.timer.start(map, duration, function()
    map:end_dreaming()
  end)
  timer:set_suspended_with_map(false)
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
    return white_surface:get_opacity() > 0 -- repeat
  end)
end

-- Call when map needs to be drawn.
function map:on_draw(dst_surface)
  if should_draw_white_surface then
   white_surface:draw(dst_surface)
  end
end

-- End the dream and go to Link's house.
function map:end_dreaming()
  local hero = map:get_hero()
  hero:teleport("main_village/link_house", "start_position", "immediate")
end
