local map = ...
local game = map:get_game()

function map:on_started()

  map:set_light(0)

  if game:get_value("tipiton_cave_2f_weak_floor") then
    map:set_entities_enabled("weak_floor_a_open", true)
    map:set_entities_enabled("weak_floor_a_closed", false)
    weak_floor_a_sensor:set_enabled(false)
  else
    map:set_entities_enabled("weak_floor_a_open", false)
    map:set_entities_enabled("weak_floor_a_closed", true)
    weak_floor_a_teletransporter:set_enabled(false)
  end

end

-- Weak floor.
function weak_floor_a_sensor:on_collision_explosion()

  sol.audio.play_sound("secret")
  map:set_entities_enabled("weak_floor_a_open", true)
  map:set_entities_enabled("weak_floor_a_closed", false)
  weak_floor_a_sensor:set_enabled(false)
  weak_floor_a_teletransporter:set_enabled(true)
  game:set_value("tipiton_cave_2f_weak_floor", true)
end
