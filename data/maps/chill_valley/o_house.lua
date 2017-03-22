local map = ...
local game = map:get_game()

function map:on_started()

  local movement = sol.movement.create("random_path")
  movement:start(the_doctor)
end
