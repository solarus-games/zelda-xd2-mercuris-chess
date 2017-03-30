-- Lua script of map out/b2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local zelda_chores = require("scripts/maps/zelda_chores")

local bush_count = 0
local current_chore_step = -1

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- Get chores state.
  local chore_step, chore_done, all_chores_done = zelda_chores:get_chores_state()
  current_chore_step = chore_step

  -- Lock the door while the hero has not done the chores.
  local door_open = game:get_value("link_garden_door_open") == true
  link_garden_door:set_enabled(not door_open)

  -- If the hero is doing the chore 1, count the bushes
  if current_chore_step == 1 and not chore_done then
    for i = 1, 24 do
      local bush_name = "link_garden_bush_" .. i
      local bush_entity = map:get_entity(bush_name)
      if bush_entity ~= nil then
        bush_entity.on_cut = map.increase_bush_count
        bush_entity.on_lifting = map.increase_bush_count
      end
    end

  -- Else, hide all the bushes
  else
    for i = 1, 24 do
      local bush_name = "link_garden_bush_" .. i
      local bush_entity = map:get_entity(bush_name)
      if bush_entity ~= nil then
        bush_entity:remove()
      end
    end
  end

  if hidden_chest:is_open() then
    lens_fake_tile_1:set_enabled(false)
  end
end

-- Called each time a bush in Link's garden is cut.
-- When all the bushes are cut, the chore is done.
function map:increase_bush_count()
  if current_chore_step ~= 1 then
    return
  end

  bush_count = bush_count + 1

  if bush_count == 24 then
    sol.audio.play_sound("secret")
    zelda_chores:set_chore_done(true)
  end
end

-- Called when the hero talks to the mailbox
function link_mailbox:on_interaction()
  if current_chore_step ~= 2 then
    game:start_dialog("chores.mailbox_empty")
    return
  end

  -- Give a letter to the hero if he has not got one yet.
  if game:has_item("mail") then
    game:start_dialog("chores.mailbox_empty")
  else
    hero:start_treasure("mail", 1)
    zelda_chores:set_chore_done(true)
  end
end

function map:on_obtaining_treasure(item, variant, savegame_variable)

  if savegame_variable == "forest_invisible_rupee_chest" then
    lens_fake_tile_1:set_enabled(false)
  end
end

