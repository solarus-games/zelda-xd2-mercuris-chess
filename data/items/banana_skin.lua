local item = ...
local game = item:get_game()

function item:on_started()

  item:set_brandish_when_picked(false)
end

function item:on_obtaining(variant, savegame_variable)

  local counter = game:get_item(item:get_name() .. "_counter")
  if counter:get_variant() == 0 then
    counter:set_variant(1)
  end
  counter:add_amount(1)
end
