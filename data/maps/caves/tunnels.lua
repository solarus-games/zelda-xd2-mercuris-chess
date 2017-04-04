local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

function map:on_started()
  map:set_light(0)
  if game:get_value("water_house_pool_empty") then
    water:remove()
  end
end

function weak_wall_a:on_opened()
  sol.audio.play_sound("secret")
end

function weak_wall_b:on_opened()
  sol.audio.play_sound("secret")
end
