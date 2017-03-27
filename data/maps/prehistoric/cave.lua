local map = ...
local game = map:get_game()

function map:on_started()

  tyrannosaurus:get_sprite():set_animation("walking")
end

function tyrannosaurus:use_perfume()

  sol.audio.play_sound("mk64_yoshi")
end
