local map = ...
local game = map:get_game()

function wizard:on_interaction()

  local boots = game:get_item("pegasus_shoes")
  if boots:get_variant() == 1 then
    game:start_dialog("desert.small_house_shoelaces", function()
      hero:start_treasure("pegasus_shoelaces")
    end)
  else
    game:start_dialog("desert.small_house")
  end
end
