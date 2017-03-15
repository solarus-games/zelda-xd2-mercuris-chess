-- Lua script of item cat_food.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

function item:on_created()
  item:set_savegame_variable("possession_cat_food")
  self:set_assignable(true)
end

-- Event called when the hero is using any item
-- in front of an NPC related to the cat food item.
function item:on_npc_interaction_item(npc, item_used)

  if npc:get_name() == "tigriss_npc_docile" and
      item_used == item then
    npc:use_food()
  end
end

-- Called when the hero talks to the docile cat.
function item:on_npc_interaction(npc)

  if npc:get_name() ~= "tigriss_npc_docile" then
    return
  end

  if game:get_value("zelda_cat_fed") then
    game:start_dialog("chores.cat_fed")
  else
    game:start_dialog("chores.cat_gurgling")
  end
end

-- Event called when the hero is using this item.
function item:on_using()

  item:set_finished()
end
