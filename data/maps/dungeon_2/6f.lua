local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local chess_utils = require("scripts/maps/chess_utils")

local fighting_miniboss = false
local previous_music = sol.audio.get_music()

function map:on_started()

  if game:get_value("dungeon_2_6f_8_queens_puzzle_piece_of_heart") then
    queens_puzzle_reward_barrier:set_enabled(false)
  end

  if game:get_value("dungeon_2_6f_se_weak_floor") then
    map:set_entities_enabled("weak_floor_a_open", true)
    map:set_entities_enabled("weak_floor_a_closed", false)
    weak_floor_a_sensor:set_enabled(false)
  else
    map:set_entities_enabled("weak_floor_a_open", false)
    map:set_entities_enabled("weak_floor_a_closed", true)
    weak_floor_a_teletransporter:set_enabled(false)
  end

  map:set_entities_enabled("miniboss_enemy", false)
  map:set_doors_open("miniboss_door", true)
  if game:get_value("dungeon_2_miniboss") then
    miniboss_chicken_npc:set_enabled(false)
  else
    miniboss_chicken_npc:set_traversable(true)
    local movement = sol.movement.create("random")
    movement:set_speed(32)
    movement:start(miniboss_chicken_npc)
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

-- Weak floor.
function weak_floor_a_sensor:on_collision_explosion()

  sol.audio.play_sound("secret")
  map:set_entities_enabled("weak_floor_a_open", true)
  map:set_entities_enabled("weak_floor_a_closed", false)
  weak_floor_a_sensor:set_enabled(false)
  weak_floor_a_teletransporter:set_enabled(true)
  game:set_value("dungeon_2_6f_se_weak_floor", true)
end

function chess_fight_sensor_1:on_activated()

  chess_fight_wall:set_enabled(false)
end

function chess_fight_sensor_2:on_activated()

  chess_fight_wall:set_enabled(false)
end

function chess_fight_exit_sensor:on_activated()

  chess_fight_wall:set_enabled(true)
end

function start_miniboss_sensor:on_activated()

  if game:get_value("dungeon_2_miniboss") then
    return
  end

  if fighting_miniboss then
    return
  end

  game:start_dialog("dungeon_2.6f.miniboss_start", function()
    map:close_doors("miniboss_door")
    hero:freeze()
    sol.audio.stop_music()
    sol.timer.start(map, 1000, function()
      sol.audio.play_music("alttp/boss")
      miniboss_chicken_npc:set_enabled(false)
      map:set_entities_enabled("miniboss_enemy", true)
      map:set_entities_enabled("miniboss_spikes", true)
      hero:unfreeze()
    end)
    fighting_miniboss = true
  end)
end

local function miniboss_enemy_on_dead()

  if not map:has_entities("miniboss_enemy") then
    sol.audio.play_music(previous_music)
    map:open_doors("miniboss_door")
    map:set_entities_enabled("miniboss_spikes", false)
    game:set_value("dungeon_2_miniboss", true)
  end
end

for enemy in map:get_entities("miniboss_enemy") do
  enemy.on_dead = miniboss_enemy_on_dead
end
