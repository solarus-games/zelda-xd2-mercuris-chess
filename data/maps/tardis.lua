local map = ...
local game = map:get_game()

function map:on_started()
  doctor:random_walk(80)
end
