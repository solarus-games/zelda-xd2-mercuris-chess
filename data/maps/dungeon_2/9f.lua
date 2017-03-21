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
  boss:set_enabled(false)
  if boss == nil then
    -- Already beaten.
    grump_npc:set_enabled(false)
  end
end

function start_boss_sensor:on_activated()

  if boss == nil then
    -- Already beaten.
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
    sol.timer.start(map, 200, function()
      sol.audio.play_music("alttp/ganon_battle")

      -- The boss is close to the hero, don't attack too quickly.
      boss:set_can_attack(false)
      sol.timer.start(boss, 500, function()
        boss:set_can_attack(true)
      end)

      grump_npc:set_enabled(false)
      boss:set_enabled(true)
      hero:unfreeze()
    end)
    fighting_boss = true
  end)

end
