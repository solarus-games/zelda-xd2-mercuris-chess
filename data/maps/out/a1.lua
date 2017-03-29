local map = ...
local game = map:get_game()

function map:on_started()

  island_beach_jellyfish:set_life(2000000)

  beach_hut:set_drawn_in_y_order(true)
end

function island_scaring_rupee_sensor:on_activated()
  sol.audio.play_sound("enemy_hurt")
  sol.audio.play_sound("hero_hurt")
  game:set_life(4)
end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)

  if treasure_savegame_variable ~= "island_scaring_rupee_obtained" then
    return
  end
  game:start_dialog("island.scaring_rupee_obtained_dialog")
end
