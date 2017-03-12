-- Lua script of map dungeon_1/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local water_delay = 500

local function camera_intro()
  map:get_hero():freeze()
  local camera = map:get_entity("intro_camera")
  local camera_movement = sol.movement.create("straight")
  map:get_camera():start_tracking(camera)
  camera_movement:start(map:get_entity("intro_camera"))
  camera_movement:set_angle(3 * math.pi / 2)
  camera_movement:set_ignore_obstacles(true)
end

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("dungeon_1_camera_intro_played") ~= true then
    camera_intro()
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished(destination)
  if destination == from_outside then
    game:start_dialog("dungeon_1.welcome")
  end
end

function intro_camera:on_position_changed(x, y)
  if (y >= 376) then
    map:get_camera():start_tracking(map:get_hero())
    map:get_hero():unfreeze()
    map:remove_entities("intro_camera")
    game:set_value("dungeon_1_camera_intro_played", true)
  end
end

-- Pool switch mechanism
-- The switch fills up the champagne swimming pool
function pool_switch:on_activated()
  sol.audio.play_sound("water_fill_begin")
  sol.audio.play_sound("water_fill")
  local water_tile_index = 5
  sol.timer.start(water_delay, function()
    local next_tile = map:get_entity("pool_" .. water_tile_index)
    local previous_tile = map:get_entity("pool_" .. water_tile_index + 1)
    if next_tile == nil then
      return false
    end
    next_tile:set_enabled(true)
    if previous_tile ~= nil then
      previous_tile:set_enabled(false)
    end
    water_tile_index = water_tile_index - 1
    return true
  end)
end

-- River switch mechanism
-- The switch fills up the champagne river (yummy!)
function river_switch:on_activated()
  sol.audio.play_sound("water_drain_begin")
  sol.audio.play_sound("water_drain")
  local water_tile_index = 1
  sol.timer.start(water_delay, function()
    local next_tiles = map:get_entities("animated_river_" .. water_tile_index + 1)
    local previous_tiles = map:get_entities("animated_river_" .. water_tile_index)
    if next_tiles == nil then
      return false
    end
    for tile in next_tiles do
      tile:set_enabled(true)
    end
    for tile in previous_tiles do
      tile:set_enabled(false)
    end
    water_tile_index = water_tile_index + 1
    return true
  end)
  for tile in map:get_entities("static_river_") do
    tile:set_enabled(false)
  end
end