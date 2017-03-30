local map = ...
local game = map:get_game()

function map:on_started()

  grump:set_enabled(false)
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

-- Mr Grump taking back his flippers.
local function grump_sensor_on_activated()

  if game:get_value("island_grump_flippers_done") then
    return
  end

  local grump_sprite = grump:get_sprite()
  hero:freeze()
  hero:set_direction(1)
  game:start_dialog("island.grump_hey", function()
    grump:set_enabled(true)
    local movement = sol.movement.create("target")
    movement:set_speed(88)
    movement:set_target(grump_target_1)
    movement:set_smooth(false)
    movement:set_ignore_obstacles(true)  -- To pass the ladder.
    movement:start(grump, function()
      movement:stop()
      grump_sprite:set_animation("stopped")
      game:start_dialog("island.grump_my_flippers", function()
        local movement = sol.movement.create("target")
        movement:set_speed(88)
        movement:set_target(grump_target_2)
        movement:set_smooth(false)
        movement:set_ignore_obstacles(true)
        movement:start(grump, function()
          movement:stop()
          grump_sprite:set_animation("stopped")
          grump_sprite:set_direction(3)
        end)
      end)
    end)
  end)
end

for sensor in map:get_entities("grump_sensor_") do
  sensor.on_activated = grump_sensor_on_activated
end
