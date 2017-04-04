-- Lua script of map chill_valley/j_house_b1.
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

  swimming_lady:set_dialog_id("chill_valley.bath.lovers_brassens")
  swimming_old_man:set_interaction(function()
    sol.audio.play_sound("tea_for_two")
    hero:freeze()
    hero:set_animation("swimming_stopped")
    sol.timer.start(map, 500, function()
      game:start_dialog("chill_valley.bath.tea_for_two", function()
        hero:unfreeze()
      end)
    end)
  end)
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
