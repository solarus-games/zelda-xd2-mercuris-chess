local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_a", 0, 3)
elevator_manager:create_elevator(map, "elevator_b", 0, 8)

local flying_tile_manager = require("scripts/maps/flying_tile_manager")
flying_tile_manager:create_flying_tiles(map, "flying_tile")

function map:on_started(destination)

  if destination == from_4f_se then
    -- Don't enable flying tiles when coming from this way.
    flying_tile_sensor:set_enabled(false)
  end
end
