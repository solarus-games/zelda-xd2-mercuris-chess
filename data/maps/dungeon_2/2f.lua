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

local chest_game_manager = require("scripts/maps/chest_game_manager")
local chest_game_rewards = {
  { "rupee", 1 },
  { "rupee", 2 },
  { "rupee", 3 },
  { "rupee", 4 },
  { "heart", 1 },
  { "heart", 1 },
  { "creeper", 1 },
  { "creeper", 1 },
  { "creeper", 1 },
  { "creeper", 1 },
}

if not game:get_value("dungeon_2_2f_chest_game_key") then
  -- Give the key with probability 0.5.
  local num_rewards_before = #chest_game_rewards
  for i = 1, num_rewards_before do
    chest_game_rewards[#chest_game_rewards + 1] = { "small_key", 1, "dungeon_2_2f_chest_game_key" }
  end
end
chest_game_manager:create_chest_game(map, "chest_game", 20, chest_game_rewards)

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

function casino_receptionnist:on_interaction()

  if game:get_value("dungeon_2_2f_casino_doors_open") then
    game:start_dialog("dungeon_2.2f_casino_receptionnist_open")
  else
    game:start_dialog("dungeon_2.2f_casino_receptionnist_intro", function(answer)
      if answer == 1 then
        -- TODO
      end
    end)
  end
end
