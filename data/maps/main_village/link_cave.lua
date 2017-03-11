-- Lua script of map main_village/link_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- Open doors by default.
  map:set_doors_open("cave_door_")
  
  tigriss_docile:set_visible(false)
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Launch the boss fight.
function door_sensor:on_activated()
  -- Close doors.
  map:close_doors("cave_door_")

  -- 
end

-- When the boss is killed.
function tigriss:on_dying()
  local tigriss_x, tigriss_y = tigriss:get_position()
  tigriss_docile:set_position(tigriss_x, tigriss_y)
  tigriss_docile:set_visible(true)
end

-- Some sinisters sounds before fighting the boss...
function miaou_sensor_1:on_activated()
  local dialog_box = game:get_dialog_box()
  game:start_dialog("chores.miaou_1")
end

-- Some sinisters sounds before fighting the boss...
function miaou_sensor_2:on_activated()
  local dialog_box = game:get_dialog_box()
  game:start_dialog("chores.miaou_2")
end