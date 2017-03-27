local map = ...
local game = map:get_game()

function map:on_started()

  tyrannosaurus:get_sprite():set_animation("walking")

  if game:get_value("prehistoric_tyrannosaurus_explained") then
    doctor:set_position(tyrannosaurus_doctor_target:get_position())
    doctor:random_walk()
  else
    doctor:set_enabled(false)
  end

  tardis:set_enabled(false)
  tardis_door:set_enabled(false)
end

function tyrannosaurus_sensor:on_activated()

  if not game:get_value("prehistoric_tyrannosaurus_explained") then
    hero:freeze()
    doctor:set_enabled(true)
    local movement = sol.movement.create("path")
    movement:set_path({2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4})
    movement:set_speed(64)
    movement:set_ignore_obstacles(true)
    movement:start(doctor, function()
      hero:set_direction(1)
      doctor:get_sprite():set_direction(1)
      game:start_dialog("prehistoric.doctor_tyrannosaurus", function()
        hero:unfreeze()
        doctor:random_walk()
        game:set_value("prehistoric_tyrannosaurus_explained", true)
      end)
    end)
  end
end

function doctor:on_interaction()

  if game:get_value("prehistoric_tyrannosaurus_happy") then
    return
  end

  game:start_dialog("prehistoric.doctor_tyrannosaurus_pissed_off")
end

function tyrannosaurus:use_perfume()

  sol.audio.play_sound("secret")
  game:get_item("perfume_counter"):remove_amount(1)
  game:set_value("prehistoric_tyrannosaurus_happy", true)
  doctor:get_sprite():set_direction(doctor:get_direction4_to(tyrannosaurus))
  game:start_dialog("prehistoric.doctor_tyrannosaurus_solved", function()

    hero:unfreeze()
    doctor:set_traversable(true)
    local tardis_x, tardis_y = tardis:get_position()
    local movement = sol.movement.create("target")
    movement:set_target(tyrannosaurus_sensor)
    movement:set_speed(64)
    movement:set_smooth(true)
    movement:set_ignore_obstacles(true)

    movement:start(doctor, function()
      local movement = sol.movement.create("target")
      movement:set_target(tardis)
      movement:set_speed(64)
      movement:set_smooth(true)
      movement:set_ignore_obstacles(true)
      movement:start(doctor, function()
        doctor:stop_movement()
        doctor:get_sprite():set_direction(1)
        doctor:get_sprite():set_animation("stopped")
      end)
    end)
  end)
end

function tardis_sensor:on_activated()

  if not game:get_value("prehistoric_tyrannosaurus_happy") then
    return
  end

  hero:freeze()
  hero:set_visible(false)
  doctor:set_visible(false)
  tardis:set_enabled(true)
  tardis_door:set_enabled(true)
  tardis:appear("entities/doctor_who/tardis_cache_prehistoric_cave.png", function()
    hero:teleport("sunset_creek")
  end)
end
