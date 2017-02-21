-- Lua script of map dungeon_2/entrance.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local parallax_config = {

  {
    entity = entrance,
    ratio_y = -6,
    reference_y = 189,
  },

  {
    entity = building,
    ratio_y = -12,
    reference_y = 189,
  },
}

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  game:set_hud_enabled(false)

  for _, config in ipairs(parallax_config) do
    config.entity_initial_x, config.entity_initial_y = config.entity:get_position()
  end

  sol.timer.start(map, 10, function()

    local hero_x, hero_y = hero:get_position()

    for _, config in ipairs(parallax_config) do
      local entity = config.entity
      local reference_x = config.reference_x or hero_x
      local reference_y = config.reference_y or hero_y
      local ratio_x = config.ratio_x or 1
      local ratio_y = config.ratio_y or 1
      local distance_x, distance_y = reference_x - hero_x, reference_y - hero_y
      
      local x = config.entity_initial_x + distance_x / ratio_x
      local y = config.entity_initial_y + distance_y / ratio_y
      entity:set_position(x, y)
    end

    return true
  end)
end

function map:on_finished()

  game:set_hud_enabled(true)
end
