local map = ...
local game = map:get_game()

local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
