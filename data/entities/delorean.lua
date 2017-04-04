local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:on_created()

  entity:set_size(72, 32)
  entity:set_origin(36, 29)
  entity:set_traversable_by(false)
  entity:set_drawn_in_y_order(true)
  entity:create_sprite("entities/bttf/delorean")
end
