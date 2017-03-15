-- Lua script of map out/a1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
  island_beach_jellyfish:set_life(2000000)
end

function island_scaring_rupee_sensor:on_activated()
  sol.audio.play_sound("enemy_hurt")
  sol.audio.play_sound("hero_hurt")
  game:set_life(4)
end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)
  if treasure_savegame_variable ~= "island_scaring_rupee_obtained"
  then
    return
  end
  game:start_dialog("island.scaring_rupee_obtained_dialog")
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
