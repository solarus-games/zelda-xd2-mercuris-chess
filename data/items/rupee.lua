local item = ...
local game = item:get_game()

function item:on_created()

  item:set_shadow("small")
  item:set_can_disappear(true)
  item:set_brandish_when_picked(false)
  item:set_sound_when_picked("picked_rupee")
end

function item:on_obtaining(variant, savegame_variable)

  local amounts = {1, 5, 20, 50, 100, 300}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee'")
  end
  game:add_money(amount)
end

