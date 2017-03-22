local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local fighting_boss = false

function map:on_started(destination)

  map:set_doors_open("boss_door", true)
  boss:set_enabled(false)
  if boss == nil then
    -- Already beaten.
    grump_npc:set_enabled(false)
  end
  tardis:set_enabled(false)
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
      sol.timer.start(map, 500, function()
        boss:set_can_attack(true)
      end)

      grump_npc:set_enabled(false)
      boss:set_enabled(true)
      hero:unfreeze()
    end)
    fighting_boss = true
  end)

end

function debug_boss_sensor:on_activated()

  game:set_value("dungeon_2_9f_boss_door", true)
  game:set_value("dungeon_2_9f_door_a", true)
  map:close_doors("boss_door")
  if boss ~= nil then
    boss:set_life(1)
  end
end

local function shake_camera()
  sol.audio.play_sound("enemy_awake")
  hero:freeze()
  local camera = map:get_camera()
  local shake_config = {
    count = 10,
    amplitude = 4,
  }
  camera:shake(shake_config, function()
    hero:unfreeze()
  end)
end
 
-- Function called when the boss is beaten.
-- Starts the escape sequence of the dungeon.
function map:grump_finished(grump)

  sol.timer.start(map, 3000, function()
    sol.timer.start(map, 1000, function()
      sol.audio.stop_music()
      map:open_doors("boss_door")
    end)

    local explosion_sound_timer = sol.timer.start(map, 300, function()
      sol.audio.play_sound("explosion")
      return true
    end)

    sol.timer.start(map, 2000, function()

      sol.timer.start(map, 6000, function()
        shake_camera()
        explosion_sound_timer:stop()
        return true
      end)

      sol.timer.start(map, 8000, function()
        sol.audio.play_music("alttp/soldiers")

        sol.timer.start(map, 100, function()
          if math.random(10) == 1 then
            sol.audio.play_sound("explosion")
            local x, y = hero:get_position()
            map:create_explosion({
              x = x + math.random(100) - 50,
              y = y + math.random(100) - 50,
              layer = 2,
            })
          end
          return true
        end)

        sol.timer.start(map, 100, function()
          if math.random(10) == 1 then
            sol.audio.play_sound("explosion")
            local x, y = hero:get_position()
            map:create_fire({
              x = x + math.random(100) - 50,
              y = y + math.random(100) - 50,
              layer = 2,
            })
          end
          return true
        end)
      end)
    end)
  end)
end

function tardis_landing_sensor:on_activated()

  sol.audio.play_sound("tardis")
  tardis:set_enabled(true)
  the_doctor:set_enabled(true)
end

function doctor_coming_sensor:on_activated()

  print("go doctor")
  local movement = sol.movement.create("straight")
  movement:set_speed(96)
  movement:set_angle(3 * math.pi / 2)
  movement:set_max_distance(120)
  movement:start(the_doctor)
end
