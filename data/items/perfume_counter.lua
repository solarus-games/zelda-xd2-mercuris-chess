local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_perfume_counter")
  item:set_amount_savegame_variable("amount_perfume_counter")
  item:set_max_amount(50)
  item:set_assignable(true)
end

-- Event called when the hero is using any item
-- in front of an NPC related to the perfume item.
function item:on_npc_interaction_item(npc, item_used)

  if game.prehistoric_tyrannosaurus_happy then
    return false
  end

  if npc:get_name() == "tyrannosaurus" and
      item_used == item then
    npc:use_perfume()
    return true  -- Stop the propagation of the event.
  end
end

-- Called when the hero talks to an NPC related to
-- the perfume item.
function item:on_npc_interaction(npc)

  if npc:get_name() ~= "tyrannosaurus" then
    return
  end

  if not game.prehistoric_tyrannosaurus_happy then
    sol.audio.play_sound("monkey")
    npc:get_sprite():set_animation("no", "stopped")
    game:start_dialog("prehistoric.tyrannosaurus_upset")
  else
    sol.audio.play_sound("mk64_yoshi")
  end
end

-- Event called when the hero is using this item.
function item:on_using()

  sol.audio.play_sound("wrong")
  game:start_dialog("not_now.perfume")
  item:set_finished()
end
