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

local chess_utils = require("scripts/maps/chess_utils")

function map:on_started(destination)

  if destination == from_4f_se then
    -- Don't enable flying tiles when coming from this way.
    flying_tile_sensor:set_enabled(false)
  end

  if not rooks_puzzle_chest:is_open() then
    rooks_puzzle_chest:set_enabled(false)
  end
end

-- 6 rooks puzzle.
local function rook_puzzle_on_moved(rook)

  local x, y = rook:get_bounding_box()
  if x % 8 ~= 0 or y % 8 ~= 0 then
    return
  end

  local solved = true
  for i = 1, 6 do
    local current_rook = map:get_entity("auto_block_rook_" .. i)
    if chess_utils:get_num_pieces_controlling(current_rook, "auto_block_rook_") ~= 0 then
      solved = false
      break
    end
  end

  if solved and not rooks_puzzle_chest:is_enabled() then
    sol.audio.play_sound("secret")
    rooks_puzzle_chest:set_enabled(true)
  end

end

for i = 1, 6 do
  map:get_entity("auto_block_rook_" .. i).on_moved = rook_puzzle_on_moved
end
