local item = ...
local game = item:get_game()

function item:on_created()

end

function item:on_obtaining(variant)

  if variant > 0 then
    -- Obtaining the Pegasus shoelaces fixes the Pegasus boots.
    game:get_item("pegasus_shoes"):set_variant(2)
  end
end

