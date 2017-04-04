-- Lua script of map out/b1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local lafoo_riot = require("scripts/maps/lafoo_riot")

function map:on_started()

 -- Show or hide the riot
  local riot_finished = lafoo_riot:is_finished()
  if riot_finished then
    map:remove_entities("npc_riot")
    map:remove_entities("random_walk_npc_riot")
  end

  -- Hide the Fire Rod NPC if player already has the fire rod
  local has_perfume = game:has_item("perfume_counter") and game:get_item("perfume_counter"):has_amount()
  if has_perfume and perfume_npc ~= nil then 
    perfume_npc:remove()
  end

end

function perfume_sensor:on_activated()
  local has_perfume = game:has_item("perfume_counter") and game:get_item("perfume_counter"):has_amount()
  if has_perfume then 
    return
  end
  
  -- block hero
  local hero = map:get_hero()
  hero:freeze()
  game:set_hud_enabled(false)
  game:set_pause_allowed(false)

  local npc_movement_1 = sol.movement.create("target")
  local hero_x, hero_y = hero:get_position()
  npc_movement_1:set_speed(100)
  npc_movement_1:set_smooth(true)
  npc_movement_1:set_ignore_obstacles(true)
  npc_movement_1:set_target(hero_x, hero_y + 16)
  npc_movement_1:start(perfume_npc, function()
    sol.timer.start(map, 800, function()
      perfume_npc:get_sprite():set_direction(1) --top
      perfume_npc:get_sprite():set_paused(true)
      game:start_dialog("lafoo_riot.perfume_npc", function()
        hero:unfreeze()
        hero:start_treasure("perfume", 1)
        game:set_hud_enabled(true)
        game:set_pause_allowed(true)
        
        local npc_movement_2 = sol.movement.create("target")
        npc_movement_2:set_speed(120)
        npc_movement_2:set_smooth(true)
        npc_movement_2:set_ignore_obstacles(true)
        npc_movement_2:set_target(144, 528)
        --npc_movement_2:set_ignore_obstacles(true)
        npc_movement_2:start(perfume_npc, function()
          perfume_npc:remove()
        end)
      end)
    end)
  end)
end

function castle_guard:on_interaction()

  if not game:is_dungeon_finished(1) then
    game:start_dialog("main_village.castle_guard_before_dungeon_1")
  else
    game:start_dialog("main_village.castle_guard_after_dungeon_1")
  end
end
