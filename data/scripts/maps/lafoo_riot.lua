-- Lua script for the Lost And Found Objects Office (LAFOO) riot

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

-------------------------------------------------------------------------------

local lafoo_riot = {}

local lafoo_riot_finished_key = "lafoo_riot_finished"

local game = sol.main.game

-- Get the LAFOO riot state
function lafoo_riot:is_finished()

  -- Read savegame file.
  local riot_finished = game:get_value(lafoo_riot_finished_key) or false
  return riot_finished
end

-- Return
return lafoo_riot
