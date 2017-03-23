local map = ...
local game = map:get_game()

function map:on_started()

  local movement = sol.movement.create("random_path")
  movement:start(doc)
end

function no_entry_sensor:on_activated()
  game:start_dialog("chill_valley.no_entry_2")
end
