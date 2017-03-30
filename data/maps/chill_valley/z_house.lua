-- Lua script of map chill_valley/z_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.

    
  for npc in map:get_entities_by_type('npc') do
    if npc:get_name() ~= "encyclopedia" then
      function npc:on_interaction()
        game:start_dialog("chill_valley.z_house." .. npc:get_name(), function()
          game:set_value("chill_valley_z_house_" .. npc:get_name() .. "_read", true)
          if game:get_value('chill_valley_z_house_library_rat') ~= true then
            map:check_rat_appear()
          end
        end)
      end
    end
  end
  
  if game:get_value('chill_valley_z_house_library_rat') ~= true then
    function library_rat:on_dead()
      sol.audio.play_music("alttp/village")
      map:get_hero():start_victory()
    end
  end

  map:check_rat_appear()
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function map:check_rat_appear()
  if game:get_value('chill_valley_z_house_library_rat') ~= true then
    local all_read = true
    for npc in map:get_entities_by_type('npc') do
      if npc:get_name() ~= "encyclopedia" then
        all_read = all_read and game:get_value("chill_valley_z_house_" .. npc:get_name() .. "_read") == true
      
        if not all_read then
          break
        end
      end
    end
    
    library_rat:set_enabled(all_read)
    if all_read then
      sol.audio.play_music("alttp/soldiers")
      if game:get_value("chill_valley_z_house_all_read") ~= true then
        game:start_dialog("chill_valley.z_house.all_read", function()
          game:set_value("chill_valley_z_house_all_read", true)
        end)
      end
    end
  end
end

function encyclopedia:on_interaction()
  if game:get_value('chill_valley_z_house_heart_container_obtained') ~= true then
    game:start_dialog("chill_valley.z_house.encyclopedia.not_opened", function(answer)
      if answer == 1 then
        map:get_hero():start_treasure("heart_container", 1, "chill_valley_z_house_heart_container_obtained", function()
          game:start_dialog("chill_valley.z_house.encyclopedia.when_opened")
        end)
      else
        game:start_dialog("chill_valley.z_house.encyclopedia.back_on_shelf")
      end
    end)
  else
    game:start_dialog("chill_valley.z_house.encyclopedia.already_opened")
  end
end