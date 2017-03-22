local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:on_created()

  entity:set_size(32, 56)
  entity:set_origin(16, 53)
  entity:set_traversable_by(false)
end
