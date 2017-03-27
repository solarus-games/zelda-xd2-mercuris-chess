local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local fighting_boss = false
local escaping_after_boss = false

function map:on_started(destination)

  map:set_doors_open("boss_door", true)
  boss:set_enabled(false)
  if boss == nil then
    -- Already beaten.
    grump_npc:set_enabled(false)
  end

  the_doctor:set_enabled(false)
  tardis:set_enabled(false)
  tardis_door:set_enabled(false)
end

function start_boss_sensor:on_activated()

  if boss == nil or escaping_after_boss then
    -- Already beaten.
    return
  end

  if fighting_boss then
    return
  end

  if boss_door:is_open() then
    map:close_doors("boss_door")
    sol.audio.stop_music()
  end
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

  fighting_boss = false
  escaping_after_boss = true

  elevator_b_sensor:set_enabled(false)
  map:close_doors("elevator_b_door")

  sol.timer.start(map, 3000, function()
    sol.timer.start(map, 1000, function()
      sol.audio.stop_music()
    end)

    local explosion_sound_timer = sol.timer.start(map, 300, function()
      sol.audio.play_sound("explosion")
      return true
    end)

    sol.timer.start(map, 2000, function()

      -- Shake the camera sometimes.
      sol.timer.start(map, 6000, function()
        if hero:get_state() == "stairs" then
          -- Don't freeze/unfreeze the hero while taking stairs
          return true
        end
        shake_camera()
        explosion_sound_timer:stop()
        return true
      end)

      -- Add harmless explosions and fire sometimes.
      sol.timer.start(map, 8000, function()
        sol.audio.play_music("alttp/soldiers")
        game:start_dialog("dungeon_2.9f.grump_building_collapsing", function()

          map:open_doors("boss_door")
          sol.timer.start(map, 250, function()
            if math.random(4) == 1 then
              sol.audio.play_sound("explosion")
              local x, y = hero:get_position()
              for i = 1, 3 + math.random(5) do
                if math.random(2) == 1 then
                  map:create_explosion({
                    x = x + math.random(300) - 150,
                    y = y + math.random(300) - 150,
                    layer = 2,
                  })
                  map:create_fire({
                    x = x + math.random(300) - 150,
                    y = y + math.random(300) - 150,
                    layer = 2,
                  })
                end
              end
            end
            return true
          end)
        end)
      end)
    end)
  end)
end

function tardis_landing_sensor:on_activated()

  if not escaping_after_boss then
    return
  end

  sol.audio.play_sound("tardis")
  tardis:set_enabled(true)
  tardis_door:set_enabled(true)
  the_doctor:set_enabled(true)
end

function doctor_coming_sensor:on_activated()

  if not escaping_after_boss then
    return
  end

  local movement = sol.movement.create("straight")
  movement:set_speed(96)
  movement:set_angle(3 * math.pi / 2)
  movement:set_max_distance(96)
  movement:start(the_doctor, function()
    
    sol.audio.play_music("doctor_octoroc/i_am_the_doctor_1")
    game:get_dialog_box():set_position("bottom")
    game:start_dialog("dungeon_2.9f.doctor", function()

      game:get_dialog_box():set_position("auto")

      local movement = sol.movement.create("target")
      movement:set_target(tardis)
      movement:set_smooth(false)
      movement:set_speed(96)
      movement:set_ignore_obstacles(true)

      function movement:on_position_changed()
        if the_doctor:overlaps(tardis_door, "facing") and tardis_door:is_closed() then
          map:open_doors("tardis_door")
        end
      end

      movement:start(the_doctor, function()
        the_doctor:set_enabled(false)
      end)
    end)
  end)
end

function tardis_sensor:on_activated()

  if not escaping_after_boss then
    return
  end

  tardis:disappear("entities/dungeon_2/tardis_cache_dungeon_2.png", function()
    hero:teleport("tardis")
  end)
end

function map:on_finished()

  game:get_hero():set_visible(true)
  game:set_pause_allowed(true)
end
