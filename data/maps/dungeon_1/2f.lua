-- Lua script of map dungeon_1/2f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function map:on_started()
  if game:get_value("dungeon_1_mario_painting") == true then
    map:remove_entities("weak_wall")
    map:remove_entities("mario")
  end
end

function mario_message:on_interaction()
  sol.audio.play_sound("mk64_mario_yeah")
end

function mario_sensor:on_collision_explosion()
  sol.audio.play_sound("mk64_mario_mammamia")
  map:remove_entities("weak_wall")
  map:remove_entities("mario")
  game:set_value("dungeon_1_mario_painting", true)
end