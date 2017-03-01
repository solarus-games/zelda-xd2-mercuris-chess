-- Lua script of map la_dream.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
  
  -- Camera is moved manually
  -- It starts at the top of the mountain,
  -- then move down to the beach,
  -- then follows Marine until she finds Link.
  local camera = map:get_camera()
  camera:start_manual()
  camera:set_position(320, 0)
  
  -- Hide HUD
  game:set_hud_enabled(false)

  -- Hide hero
  local hero = map:get_hero()
  hero:freeze()
  hero:set_visible(false)

  -- Wait a bit on the mountain top with the egg
  sol.timer.start(map, 2000, function()
    map:move_camera_down_to_the_beach()
  end)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Move camera from top of the mountain down to the beach
function map:move_camera_down_to_the_beach()
   local movement = sol.movement.create("straight")
   movement:set_speed(30)
   movement:set_smooth(true)
   movement:set_angle(3 * math.pi / 2)
   movement:set_max_distance(240)
   
   local camera = map:get_camera()

   function movement:on_position_changed()
    local x, y = movement:get_xy()
    if y == 162 then
      map:make_marine_enter_beach()
    end
   end

   movement:start(camera)
end

function map:make_marine_enter_beach()
   local movement = sol.movement.create("straight")
   movement:set_speed(30)
   movement:set_smooth(true)
   movement:set_angle(math.pi)
   movement:set_max_distance(88)
   movement:set_ignore_obstacles(true)

   movement:start(marine, function()
     marine:get_sprite():set_direction(3)
     -- TODO:
     -- make Marine go the the wooden piece, then stops,
     -- then go up and left, walk slowly,
     -- then stops, jumps/exclamation!
     -- then runs towards Link.
     -- Marine tries to wake up Link.
     -- Then progressively, she speaks more and more
     -- like Zelda who is actually shouting at Link
     -- in the real life (Link is dreaming!)
     -- Then shake the screen, with a beeeeeep sound
     -- and move to another map, where Link is in the bed.
   end)
end
