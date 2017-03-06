local item = ...
local game = item:get_game()

local sound_timer

function item:on_created()

  item:set_savegame_variable("possession_bombs_counter")
  item:set_amount_savegame_variable("amount_bombs_counter")
  item:set_assignable(true)
end

-- Called when the player uses the bombs of his inventory by pressing the corresponding item key.
function item:on_using()

  if item:get_amount() == 0 then
    if sound_timer == nil then
      sol.audio.play_sound("wrong")
      sound_timer = sol.timer.start(game, 500, function()
        sound_timer = nil
      end)
    end
  else
    item:remove_amount(1)
    local x, y, layer = item:create_bomb()
    sol.audio.play_sound("bomb")
  end
  item:set_finished()
end

function item:create_bomb()

  local map = item:get_map()
  local hero = map:get_entity("hero")
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

  local bomb = map:create_bomb{
    x = x,
    y = y,
    layer = layer
  }

  map.current_bombs = map.current_bombs or {}
  map.current_bombs[bomb] = true
end

function item:remove_bombs_on_map()

  local map = item:get_map()
  if map.current_bombs == nil then
    return
  end
  for bomb in pairs(map.current_bombs) do
    bomb:remove()
  end
  map.current_bombs = {}
end
