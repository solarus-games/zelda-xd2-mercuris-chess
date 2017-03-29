local map = ...
local game = map:get_game()

function map:on_started()
  map:set_light(0)
end
