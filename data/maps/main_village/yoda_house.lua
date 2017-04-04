local map = ...
local game = map:get_game()

function yoda:on_interaction()

  local sword = game:get_item("sword"):get_variant()
  if sword == 3 then
    -- Pink Saber.
    game:start_dialog("main_village.yoda_house.give_green_saber", function()
      hero:start_treasure("sword", 4)
    end)
  else
    game:start_dialog("main_village.yoda_house.done")
  end
end
