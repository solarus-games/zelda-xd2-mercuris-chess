local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_bow")
  item:set_amount_savegame_variable("amount_bow")
  item:set_assignable(true)
end

function item:on_using()

  if item:get_amount() == 0 then
    sol.audio.play_sound("wrong")
  else
    local map = game:get_map()
    local hero = game:get_hero()
    hero:start_bow()
    -- We remove the arrow from the equipment after a small delay because the hero
    -- does not shoot immediately
    sol.timer.start(200, function()
      item:remove_amount(1)
      if not game.bow_broken_dialog then
        sol.audio.play_sound("cane")
        game:start_dialog("bow_broken")
        game.bow_broken_dialog = true
      end
      hero:unfreeze()
      local x, y, layer = hero:get_facing_position()
      map:create_pickable({
        x = x,
        y = y,
        layer = layer,
        treasure_name = "arrow",
      })
    end)
  end
  item:set_finished()
end

function item:on_amount_changed(amount)

  if item:get_variant() ~= 0 then
    -- update the icon (with or without arrow)
    if amount == 0 then
      item:set_variant(1)
    else
      item:set_variant(2)
    end
  end
end

function item:on_obtaining(variant, savegame_variable)

  local quiver = self:get_game():get_item("quiver")
  if not quiver:has_variant() then
    -- Give the first quiver automatically with the bow.
    quiver:set_variant(1)
  end

  item:set_amount(item:get_max_amount())
end

