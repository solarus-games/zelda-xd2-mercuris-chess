local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local fighting_boss = false

function map:on_started()

  map:set_doors_open("boss_door", true)
end

function start_boss_sensor:on_activated()

  if game:get_value("dungeon_2_boss") then
    return
  end

  if fighting_boss then
    return
  end

  map:close_doors("boss_door")
  sol.audio.stop_music()
end

function grump_npc:on_interaction()

  game:start_dialog("dungeon_2.9f.boss_start", function()
    hero:freeze()
    sol.timer.start(map, 1000, function()
      sol.audio.play_music("alttp/ganon_battle")
      grump_npc:set_enabled(false)
      hero:unfreeze()
    end)
    fighting_miniboss = true
  end)

end
