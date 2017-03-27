local item = ...

function item:on_created()

  self:set_savegame_variable("possession_perfume_counter")
  self:set_amount_savegame_variable("amount_perfume_counter")
  self:set_max_amount(50)
end

