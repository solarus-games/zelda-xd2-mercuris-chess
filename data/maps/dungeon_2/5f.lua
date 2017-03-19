local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local cannonball_manager = require("scripts/maps/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")

local ice_knights_targets = {}
local ice_knights = {}

function map:on_started()

  if not ice_knights_puzzle_chest:is_open() then
    ice_knights_puzzle_chest:set_enabled(false)
  end

end

local function check_ice_knight(block)

  block.correct = false
  for _, target in ipairs(ice_knights_targets) do
    if target:overlaps(block, "containing") then
      block.correct = true
      return
    end
  end
end

local function get_num_correct_ice_knights()

  local count = 0
  for _, knight in ipairs(ice_knights) do
    if knight.correct then
      count = count + 1
    end
  end
  return count
end

local function block_on_moved_ice(block)

  hero:unfreeze()

  local x, y, layer = block:get_position()

  -- Create a wall to prevent the hero from overlapping the block
  -- when it moves alone.
  local wall = map:create_wall({
    x = x - 8,
    y = y - 13,
    layer = layer,
    width = 16,
    height = 16,
    stops_hero = true,
    stops_blocks = false,
  })

  -- Move the block towards the next obstacle.
  local direction4 = hero:get_direction()
  local movement = sol.movement.create("straight")
  movement:set_speed(64)
  movement:set_angle(direction4 * math.pi / 2)
  movement:start(block)

  -- Stop the movement when reaching an obstacle.
  function movement:on_obstacle_reached()
    block:stop_movement()
    wall:remove()
    check_ice_knight(block)
    if get_num_correct_ice_knights() == 4 then
      if not ice_knights_puzzle_chest:is_enabled() then
        sol.audio.play_sound("chest_appears")
        ice_knights_puzzle_chest:set_enabled(true)
      else
        sol.audio.play_sound("secret")
      end
    end
  end

  -- Keep the wall in the block.
  function movement:on_position_changed()

    local x, y = block:get_position()
    wall:set_position(x - 8, y - 13)
  end
end

for target in map:get_entities("ice_knights_puzzle_target") do
  ice_knights_targets[#ice_knights_targets + 1] = target
end

for knight in map:get_entities("auto_block_knight") do
  ice_knights[#ice_knights + 1] = knight
  knight.on_moved = block_on_moved_ice
end
