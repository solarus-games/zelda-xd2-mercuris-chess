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

  sol.audio.play_sound("monkey")
end

-- Event called when the hero is using this item.
function item:on_using()

  sol.audio.play_sound("wrong")
  game:start_dialog("not_now.perfume")
  item:set_finished()
end
