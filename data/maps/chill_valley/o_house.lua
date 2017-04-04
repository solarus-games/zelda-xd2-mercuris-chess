local map = ...
local game = map:get_game()

local num_dialogs = 5
local dialog_index = math.random(num_dialogs)

function map:on_started()

  tardis:set_drawn_in_y_order(true)
  tardis:get_sprite():set_animation("closed")
end

function random_walk_npc_doctor:on_interaction()

  game:start_dialog("chill_valley.o_house.doctor_" .. dialog_index)
  dialog_index = dialog_index % num_dialogs + 1
end
