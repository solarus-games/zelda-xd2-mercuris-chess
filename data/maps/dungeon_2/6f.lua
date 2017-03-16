local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8)

local chess_utils = require("scripts/maps/chess_utils")

function map:on_started()

  if game:get_value("dungeon_2_6f_8_queens_puzzle_piece_of_heart") then
    queens_puzzle_reward_barrier:set_enabled(false)
  end
end

-- 8 queens puzzle.
local function queen_puzzle_on_moved(queen)

  local x, y = queen:get_bounding_box()
  if x % 8 ~= 0 or y % 8 ~= 0 then
    return
  end

  local solved = true
  for i = 1, 8 do
    local current_queen = map:get_entity("auto_block_queen_" .. i)
    if chess_utils:get_num_pieces_controlling(current_queen, "auto_block_queen_") ~= 0 then
      solved = false
      break
    end
  end

  if solved then
    sol.audio.play_sound("secret")
    if queens_puzzle_reward_barrier:is_enabled() then
      sol.audio.play_sound("door_open")
      queens_puzzle_reward_barrier:set_enabled(false)
    end
  end
end

for i = 1, 8 do
  map:get_entity("auto_block_queen_" .. i).on_moved = queen_puzzle_on_moved
end
