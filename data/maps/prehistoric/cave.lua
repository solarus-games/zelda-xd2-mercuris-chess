local map = ...
local game = map:get_game()

function map:on_started()

  tyrannosaurus:get_sprite():set_animation("stopped")
  tyrannosaurus:get_sprite():set_ignore_suspend(true)
  for egg in map:get_entities("egg_") do
    egg:get_sprite():set_animation("stopped")
  end

  if game.prehistoric_tyrannosaurus_explained then
    doctor:set_position(tyrannosaurus_doctor_target:get_position())
    doctor:random_walk()
  else
    doctor:set_enabled(false)
  end

  tardis:set_enabled(false)
  tardis_door:set_enabled(false)
end

function tyrannosaurus_sensor:on_activated()

  if not game.prehistoric_tyrannosaurus_explained then
    hero:freeze()
    tyrannosaurus:get_sprite():set_animation("anger")
    doctor:set_enabled(true)
    local movement = sol.movement.create("path")
    movement:set_path({2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4})
    movement:set_speed(64)
    movement:set_ignore_obstacles(true)
    movement:start(doctor, function()
      hero:set_direction(1)
      doctor:get_sprite():set_direction(1)

      local timer = sol.timer.start(map, 4500, function()
        doctor:get_sprite():set_direction(0)
      end)
      timer:set_suspended_with_map(false)
      timer = sol.timer.start(map, 9000, function()
        doctor:get_sprite():set_direction(1)
      end)
      timer:set_suspended_with_map(false)

      game:start_dialog("prehistoric.doctor_tyrannosaurus", function()
        hero:unfreeze()
        doctor:random_walk()
        game.prehistoric_tyrannosaurus_explained = true
      end)
    end)
  end
end

function doctor:on_interaction()

  if game.prehistoric_tyrannosaurus_happy then
    return
  end

  game:start_dialog("prehistoric.doctor_tyrannosaurus_pissed_off")
end

function tyrannosaurus:use_perfume()

  if game.prehistoric_tyrannosaurus_happy then
    return
  end

  sol.audio.play_sound("secret")
  tyrannosaurus:get_sprite():set_animation("yes", "stopped")
  game:set_pause_allowed(false)  -- Don't allow to save without the perfume.
  game:get_item("perfume_counter"):remove_amount(1)
  game.prehistoric_tyrannosaurus_happy = true
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

  if not game.prehistoric_tyrannosaurus_happy then
    return
  end

  game:start_dialog("prehistoric.doctor_lets_go_back", function()
    sol.audio.play_music("bttf/title")
    hero:freeze()
    hero:set_visible(false)
    tardis:set_enabled(true)
    tardis_door:set_enabled(true)

    sol.timer.start(map, 2000, function()
      doctor:set_visible(false)
    end)

    tardis:appear("entities/doctor_who/tardis_cache_prehistoric_cave.png", function()
      hero:teleport("sunset_creek", "from_tardis")
    end)
  end)
end
