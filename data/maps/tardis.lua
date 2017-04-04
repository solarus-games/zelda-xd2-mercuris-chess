local map = ...
local game = map:get_game()

function map:on_started()

  if game.prehistoric_tyrannosaurus_happy then
    doctor:random_walk()
  else
    doctor:random_walk(80)  -- Walk faster during the emergency escape.
    to_sunset_creek:set_enabled(false)
  end
end

function doctor:on_interaction()

  if game.prehistoric_tyrannosaurus_happy then
    game:start_dialog("tardis.doctor_back_to_present")
  else
    game:start_dialog("tardis.doctor_escaping_grump_tower", function()
      hero:teleport("prehistoric/mountains", "from_tardis")
    end)
  end
end
