local map = ...
local game = map:get_game()

function map:on_started()

  grump:set_enabled(false)
  for deku in map:get_entities("deku_") do
    deku:set_enabled(false)
  end

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
      local x, y, layer = grump:get_position()
      grump:set_position(x, y, layer - 1)
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

          local num_sounds = 4
          sol.timer.start(map, 300, function()
            sol.audio.play_sound("bush")
            num_sounds = num_sounds - 1
            if num_sounds > 0 then
              return true  -- Repeat.
            end
          end)

          sol.timer.start(map, 500, function()
            hero:set_direction(3)
            for deku in map:get_entities("deku_") do
              deku:set_enabled(true)
              local movement = sol.movement.create("target")
              movement:set_ignore_obstacles(false)
              movement:set_target(hero)
              movement:set_speed(math.random(48, 72))
              movement:start(deku)
            end

            sol.timer.start(map, 2000, function()
              sol.audio.play_sound("hero_hurt")
              hero:set_animation("dying")
              game:get_item("flippers"):set_variant(0)

              sol.timer.start(map, 2000, function()

                game:start_dialog("island.deku_done", function()
                  for deku in map:get_entities("deku_") do
                    deku:set_enabled(true)
                    local movement = sol.movement.create("straight")
                    movement:set_ignore_obstacles(true)
                    movement:set_angle(hero:get_angle(deku) + math.random() * math.pi / 4 - math.pi / 8)
                    movement:set_speed(math.random(48, 72))
                    movement:set_smooth(true)
                    movement:start(deku)

                    function movement:on_position_changed()
                      local x, y, layer = deku:get_position()
                      if y < 368 and layer == 0 then
                        deku:set_position(x, y, 1)
                      end
                    end
                  end

                  local num_sounds = 6
                  sol.timer.start(map, 300, function()
                    sol.audio.play_sound("bush")
                    num_sounds = num_sounds - 1
                    if num_sounds > 0 then
                      return true  -- Repeat.
                    end

                    sol.timer.start(map, 2000, function()
                      map:remove_entities("deku_")
                      hero:unfreeze()
                      game:set_value("island_grump_flippers_done", true)
                      game:start_dialog("island.grump_done")
                    end)
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

function grump:on_interaction()
  game:start_dialog("island.grump_done")
end

for sensor in map:get_entities("grump_sensor_") do
  sensor.on_activated = grump_sensor_on_activated
end
