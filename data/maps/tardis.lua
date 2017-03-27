local map = ...
local game = map:get_game()

function map:on_started()
  doctor:random_walk(80)
end

function doctor:on_interaction()

  game:start_dialog("tardis.doctor_escaping_grump_tower", function()
    hero:teleport("prehistoric/mountains", "from_tardis")
  end)
end
