local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:on_created()

  entity:set_drawn_in_y_order(true)
  entity:set_traversable_by(false)
end
