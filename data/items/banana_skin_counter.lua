local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_banana_skin_counter")
  item:set_amount_savegame_variable("amount_banana_skin_counter")
  item:set_max_amount(10)
  item:set_assignable(true)
end
