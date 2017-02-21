-- Lua script of map dungeon_2/entrance.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local _, map_height = map:get_size()
local entrance_initial_x, entrance_initial_y = entrance:get_position()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  game:set_hud_enabled(false)

  entrance:remove_sprite()
end

function map:on_finished()

  game:set_hud_enabled(true)
end

function entrance:on_update()

  local _, hero_y = hero:get_position()
  local distance_y = map_height - hero_y
  local entrance_y = entrance_initial_y - distance_y / 6
  entrance:set_position(entrance_initial_x, entrance_y)
end
