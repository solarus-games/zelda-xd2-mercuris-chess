require("scripts/multi_events")

local tardis = ...
local game = tardis:get_game()
local map = tardis:get_map()
local hero = game:get_hero()

local tardis_cache

function tardis:on_created()

  tardis:set_size(32, 56)
  tardis:set_origin(16, 53)
  tardis:set_traversable_by(true)

  map:register_event("on_draw", function(map, dst_surface)

    if tardis_cache == nil then
      return
    end

    map:draw_visual(tardis_cache, 768, 24)
  end)
end

function tardis:disappear(cache_file, callback)

  map:close_doors("tardis_door")
  hero:set_visible(false)
  hero:freeze()
  game:set_pause_allowed(false)

  local tardis_opacities = {}
  for i = 1, 3 do
    for opacity = 255, 120, -5 do
      tardis_opacities[#tardis_opacities + 1] = opacity
    end
    for opacity = 125, 250, 5 do
      tardis_opacities[#tardis_opacities + 1] = opacity
    end
  end
  for i = 1, 2 do
    for opacity = 255, 0, -5 do
      tardis_opacities[#tardis_opacities + 1] = opacity
    end
    for opacity = 5, 250, 5 do
      tardis_opacities[#tardis_opacities + 1] = opacity
    end
  end
  for opacity = 255, 0, -5 do
    tardis_opacities[#tardis_opacities + 1] = opacity
  end
  for i = 1, 3 do
    for opacity = 0, 125, 5 do
      tardis_opacities[#tardis_opacities + 1] = opacity
    end
    for opacity = 120, 0, -5 do
      tardis_opacities[#tardis_opacities + 1] = opacity
    end
  end

  local timer = sol.timer.start(map, 500, function()

    tardis_cache = sol.surface.create(cache_file)

    sol.audio.play_sound("tardis")
    tardis:get_sprite():set_animation("blinking")
  
    local i = 1
    tardis_cache:set_opacity(0)
    sol.timer.start(map, 20, function()
      tardis_cache:set_opacity(255 - tardis_opacities[i])
      i = i + 1
      if i <= #tardis_opacities then
        return true  -- Repeat.
      end

      if callback ~= nil then
        callback()
      end
    end)
  end)
  timer:set_suspended_with_map(false)
end
