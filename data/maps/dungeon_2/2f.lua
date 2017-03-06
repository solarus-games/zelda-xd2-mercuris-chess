local map = ...
local game = map:get_game()

local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)

function map:on_started()

  -- VIP card chest.
  if game:get_value("dungeon_2_2f_vip_card_chest_appeared") then
    ne_chest_switch:set_activated(true)
  else
    ne_chest:set_enabled(false)
  end
end

function ne_chest_switch:on_activated()

  sol.audio.play_sound("chest_appears")
  ne_chest:set_enabled(true)
  game:set_value("dungeon_2_2f_vip_card_chest_appeared", true)
end
