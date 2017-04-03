local item = ...
local game = item:get_game()

local sound_timer

function item:on_created()

  item:set_savegame_variable("possession_banana_skin_counter")
  item:set_amount_savegame_variable("amount_banana_skin_counter")
  item:set_max_amount(10)
  item:set_assignable(true)
end

function item:on_using()

  if item:get_amount() == 0 then
    if sound_timer == nil then
      sol.audio.play_sound("wrong")
      sound_timer = sol.timer.start(game, 500, function()
        sound_timer = nil
      end)
    end
    return
  end

  item:remove_amount(1)

  local map = item:get_map()
  local hero = map:get_hero()
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  if direction == 0 then
    x = x + 16
  elseif direction == 1 then
    y = y - 16
  elseif direction == 2 then
    x = x - 16
  elseif direction == 3 then
    y = y + 16
  end

  local banana = map:create_pickable{
    x = x,
    y = y,
    layer = layer,
    treasure_name = "banana_skin",
  }

  item:set_finished()
end
