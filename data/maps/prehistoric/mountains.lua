local map = ...
local game = map:get_game()

function map:on_started(destination)

  if destination == from_tardis then
    hero:set_visible(false)
    tardis:set_enabled(false)
    tardis_door:set_enabled(false)
  end
end

function map:on_opening_transition_finished(destination)

  if destination ~= from_tardis then
    return
  end

  tardis:set_enabled(true)
  tardis_door:set_enabled(true)
  tardis:appear("entities/doctor_who/tardis_cache_prehistoric.png", function()
    -- TODO
  end)
end
