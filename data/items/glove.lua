local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_glove")
end

function item:on_variant_changed(variant)
  -- The possession state of the glove determines the built-in ability "lift".
  game:set_ability("lift", variant)
end

