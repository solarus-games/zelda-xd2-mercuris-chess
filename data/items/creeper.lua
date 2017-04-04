local item = ...
local game = item:get_game()

function item:on_created()

  item:set_sound_when_brandished("wrong")
end

function item:on_obtaining()

  -- Automaically skip the dialog box after some time
  -- when obtaining a Creeper in a chest.
  local timer = sol.timer.start(500, function()
    if game:is_dialog_enabled() then
      game:stop_dialog("skipped")
    end
    local map = game:get_map()
    local x, y, layer = map:get_hero():get_position()
    map:create_enemy({
      x = x,
      y = y - 16,
      layer = layer,
      breed = "creeper",
      direction = 3,
    })
  end)
  timer:set_suspended_with_map(false)
end
