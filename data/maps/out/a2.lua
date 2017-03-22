local map = ...
local game = map:get_game()

function no_entry_sensor:on_activated()
  game:start_dialog("chill_valley.no_entry_2")
end