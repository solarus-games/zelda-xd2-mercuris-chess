local map = ...
local game = map:get_game()

function map:on_started()

  if hidden_chest:is_open() then
    lens_fake_tile_1:set_enabled(false)
    lens_fake_tile_2:set_enabled(false)
  end
end

function map:on_obtaining_treasure(item, variant, savegame_variable)

  if savegame_variable == "stupid_chest_cave_rupees_chest" then
    lens_fake_tile_1:set_enabled(false)
    lens_fake_tile_2:set_enabled(false)
  end
end

