local map = ...
local game = map:get_game()

local num_dialogs = 2
local dialog_index = math.random(num_dialogs)

function random_walk_npc_doctor:on_interaction()

  game:start_dialog("chill_valley.o_house.doctor_" .. dialog_index)
  dialog_index = dialog_index % num_dialogs + 1
end
