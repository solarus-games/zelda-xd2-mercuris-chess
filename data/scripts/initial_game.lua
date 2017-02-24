-- This script initializes game values for a new savegame file.
-- You should modify the initialize_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialize_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialize_new_savegame(game)

  -- You can modify this function to set the initial life and equipment
  -- and the starting location.
  game:set_starting_location("dungeon_2/entrance", nil)

  game:set_max_life(4 * 9)
  game:set_life(game:get_max_life())
  game:set_max_money(100)
  game:set_ability("jump_over_water", 1)
end

return initial_game
