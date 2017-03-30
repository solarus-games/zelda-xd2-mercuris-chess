local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_mail_counter")
  item:set_amount_savegame_variable("amount_mail_counter")
  item:set_max_amount(99)
  item:set_assignable(false)
end

function item:on_using()
  item:set_finished()
end
