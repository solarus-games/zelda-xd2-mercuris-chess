local item = ...
local game = item:get_game()

function item:on_obtaining(variant, savegame_variable)

  local mail_counter = self:get_game():get_item("mail_counter")
  if mail_counter:get_variant() == 0 then
    mail_counter:set_variant(1)
  end
  mail_counter:add_amount(1)
end
