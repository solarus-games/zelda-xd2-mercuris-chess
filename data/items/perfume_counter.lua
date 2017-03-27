local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_perfume_counter")
  item:set_amount_savegame_variable("amount_perfume_counter")
  item:set_max_amount(50)
  item:set_assignable(true)
end

function item:on_using()

  sol.audio.play_sound("wrong")
  game:start_dialog("not_now.perfume")
  item:set_finished()
end
