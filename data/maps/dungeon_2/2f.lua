local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_a", 0, 3)
elevator_manager:create_elevator(map, "elevator_b", 0, 8)

local slot_machine_manager = require("scripts/maps/slot_machine_manager")
slot_machine_manager:create_slot_machine(map, "slot_machine_a")
slot_machine_manager:create_slot_machine(map, "slot_machine_b")
slot_machine_manager:create_slot_machine(map, "slot_machine_c")

function map:on_started()

  -- Walking NPCs.
  local movement = sol.movement.create("random_path")
  movement:start(blue_haired_boy)
  movement = sol.movement.create("random_path")
  movement:start(green_hat_man)

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
