local map = ...
local game = map:get_game()

function map:on_started(destination)

  if destination == from_tardis then
    hero:set_visible(false)
    tardis:set_enabled(false)
    tardis_door:set_enabled(false)
  end

  doctor:set_enabled(false)
end

function map:on_opening_transition_finished(destination)

  if destination ~= from_tardis then
    return
  end

  hero:freeze()
  sol.timer.start(map, 2000, function()
    tardis:set_enabled(true)
    tardis_door:set_enabled(true)
    tardis:appear("entities/doctor_who/tardis_cache_prehistoric.png", function()
      game:start_dialog("prehistoric.doctor_tardis_arrived", function()
        map:open_doors("tardis_door")
        sol.timer.start(map, 500, function()
          hero:set_visible(true)
          sol.audio.play_sound("jump")
          local movement = sol.movement.create("jump")
          movement:set_distance(232)
          movement:set_speed(256)
          movement:set_direction8(6)
          movement:set_ignore_obstacles(true)
          movement:start(hero, function()
            hero:unfreeze()
            jump_target_wall:set_enabled(false)
            map:set_doors_open("tardis_door", false)
            doctor:set_enabled(true)
            game:set_pause_allowed(true)
          end)
        end)
      end)
    end)
  end)
end

function doctor:on_interaction()

  if not game.prehistoric_tyrannosaurus_happy then
    game:start_dialog("prehistoric.doctor_are_you_okay")
  end
end
