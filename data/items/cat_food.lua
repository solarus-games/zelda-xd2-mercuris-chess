-- Lua script of item cat_food.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_started()

  -- Initialize the properties of your item here,
  -- like whether it can be saved, whether it has an amount
  -- and whether it can be assigned.
end

-- Event called when the hero is using this item.
function item:on_using()
  
  local current_map = game:get_map()
  
  -- Check if the cat is close to the hero.
  local cat_entity = current_map:get_entity("tigriss_npc_docile")
  if cat_entity ~= nil then
    local hero = current_map:get_hero()
    local hero_x, hero_y = hero:get_position()
    local cat_x, cat_y = cat_entity:get_position()
    if hero_x > cat_x - 8 and hero_x < cat_x + 8 and hero_y > cat_y and hero_y <= cat_y + 16 then
      cat_entity:use_food()
    end
  end

  item:set_finished()
end

function item:on_created()
    item:set_savegame_variable("possession_cat_food")
    self:set_assignable(true)
end
