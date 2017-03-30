-- Lua script of map out/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local lafoo_riot = require("scripts/maps/lafoo_riot")

function map:on_started()

 -- Show or hide the riot
  local riot_finished = lafoo_riot:is_finished()
  if riot_finished then
    map:remove_entities("npc_riot")
    map:remove_entities("random_walk_npc_riot")
  end

end
