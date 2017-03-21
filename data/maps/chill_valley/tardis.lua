local map = ...
local game = map:get_game()

function test_switch:on_activated()
  sol.audio.play_sound("tardis")
end
