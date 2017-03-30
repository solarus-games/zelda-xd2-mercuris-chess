local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)

function map:on_started()
  map:set_light(0)
end

function weak_wall_a:on_opened()
  sol.audio.play_sound("secret")
end
