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

  if not game:get_value("dungeon_2_3f_queens_puzzle") then
    -- The flying tiles scripts initially made the door open
    -- but we want it closed here.
    map:set_doors_open("flying_tile_door", false)
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

  if solved then
    if not rooks_puzzle_chest:is_enabled() then
      sol.audio.play_sound("chest_appears")
      rooks_puzzle_chest:set_enabled(true)
    else
      sol.audio.play_sound("secret")
    end
  end

end

for i = 1, 6 do
  map:get_entity("auto_block_rook_" .. i).on_moved = rook_puzzle_on_moved
end

-- 6 queens puzzle.
local function queen_puzzle_on_moved(queen)

  local x, y = queen:get_bounding_box()
  if x % 8 ~= 0 or y % 8 ~= 0 then
    return
  end

  local solved = true
  for i = 1, 6 do
    local current_queen = map:get_entity("auto_block_queen_" .. i)
    if chess_utils:get_num_pieces_controlling(current_queen, "auto_block_queen_") ~= 0 then
      solved = false
      break
    end
  end

  if solved then
    sol.audio.play_sound("secret")
    if not flying_tile_door:is_open() then
      game:set_value("dungeon_2_3f_queens_puzzle", true)
      map:open_doors("flying_tile_door")
    end
  end

end

for i = 1, 6 do
  map:get_entity("auto_block_queen_" .. i).on_moved = queen_puzzle_on_moved
end
