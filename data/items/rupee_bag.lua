local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_rupee_bag")
end

function item:on_variant_changed(variant)

  -- Obtaining a rupee bag changes the max money.
  local max_moneys = {100, 300, 999}
  local max_money = max_moneys[variant]
  if max_money == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee_bag'")
  end

  game:set_max_money(max_money)
end

