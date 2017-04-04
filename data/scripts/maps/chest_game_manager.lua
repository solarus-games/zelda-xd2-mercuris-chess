-- Basic chest game to find a saved reward.

local chest_game_manager = {}

-- Sets up a chest game.
-- There must be some chests named <prefix>_1, <prefix>_2, etc and an NPC called <prefix>_npc,
-- where <prefix> is given as parameter to chest_game_manager:create().
-- rewards should be an array of possible treasures.
-- Each reward element is an item name, variant and optionally a savegame variable.
-- When the hero opens a chest, a reward is picked randomly in the list.
function chest_game_manager:create_chest_game(map, prefix, price, rewards)

  local game = map:get_game()
  local playing = false
  local good_chest_index
  local num_chests = 0

  local chest_npc = map:get_entity(prefix .. "_npc")

  function chest_npc:on_interaction()

    if playing then
      -- Already playing.
      game:start_dialog("chest_game.go_chest")
    else
      -- Propose to play.
      game:start_dialog("chest_game.rules", function(answer)
        if answer == 1 then
          -- Yes.
          if game:get_money() < price then
            game:start_dialog("chest_game.not_enough_money")
          else
            game:start_dialog("chest_game.thanks", function()
              game:remove_money(20)
              for i = 1, num_chests do
                local chest = map:get_entity(prefix .. "_chest_" .. i)
                chest:set_open(false)
              end
              playing = true
            end)
          end
        end
      end)
    end
  end

  local function on_opened(chest)

    local hero = game:get_hero()
    if not playing then
      game:start_dialog("chest_game.pay_first", function()
        chest:set_open(false)
      end)
      hero:unfreeze()
    else
      playing = false
      local item_name, variant, savegame_variable = unpack(rewards[math.random(#rewards)])
      while savegame_variable ~= nil and game:get_value(savegame_variable) do
        item_name, variant, savegame_variable = unpack(rewards[math.random(#rewards)])
      end
      hero:start_treasure(item_name, variant, savegame_variable)
    end
  end

  for chest in map:get_entities(prefix .. "_chest_") do
    if chest:get_type() == "chest" then
      chest.on_opened = on_opened
      num_chests = num_chests + 1
    end
  end

end

return chest_game_manager
