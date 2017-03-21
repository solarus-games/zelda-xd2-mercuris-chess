-- Lua script of custom entity low_wall.

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:on_created()
  entity:set_modified_ground("low_wall")
end
