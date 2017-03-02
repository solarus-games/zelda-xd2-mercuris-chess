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
  game:set_starting_location("la_dream", nil)

  game:set_ability("jump_over_water", 1)

  game:set_max_life(4 * 9)
  game:set_life(game:get_max_life())
  game:get_item("rupee_bag"):set_variant(2)
  game:set_money(42)

  game:get_item("tunic"):set_variant(1)
  game:get_item("sword"):set_variant(2)
  game:get_item("shield"):set_variant(1)

  game:get_item("glove"):set_variant(1)
  game:get_item("feather"):set_variant(1)
  game:get_item("pegasus_shoes"):set_variant(1)

  game:get_item("quiver"):set_variant(1)
  local bow = game:get_item("bow")
  bow:set_variant(1)
  bow:set_amount(0)

  game:get_item("bomb_bag"):set_variant(2)
  local bombs_counter = game:get_item("bombs_counter")
  bombs_counter:set_variant(1)
  bombs_counter:set_amount(0)

  game:get_item("bottle_1"):set_variant(1)
  game:get_item("bottle_2"):set_variant(1)
  game:get_item("bottle_3"):set_variant(1)
end

return initial_game
