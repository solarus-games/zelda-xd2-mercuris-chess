-- Lua script of map main_village/link_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local has_passed_miaou_sensor_1 = false
local has_passed_miaou_sensor_2 = false
local has_passed_boss_fight_sensor = false
local has_passed_door_sensor = false
local boss_mode = false

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- Open doors by default.
  map:set_doors_open("cave_door_")
  
  -- Check if the cat has already been fed.
  local zelda_cat_fed = game:get_value("zelda_cat_fed")
  if zelda_cat_fed == nil or not zelda_cat_fed then
    -- Activate boss mode.
    boss_mode = true

    -- Sinister music.
    sol.audio.play_music("alttp/light_world_dungeon")  

    -- Show only a static tigriss
    tigriss_npc_docile:set_enabled(false)
    tigriss_npc:set_enabled(true)
    tigriss_enemy:set_enabled(false)
  else
    -- Not in boss mode.
    boss_mode = false

    -- Show only the cute tigriss.
    tigriss_npc_docile:set_enabled(true)
    tigriss_npc:set_enabled(false)
    tigriss_enemy:set_enabled(false)
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Launch the boss fight.
function door_sensor:on_activated()
  if not boss_mode then
    return
  end

  if not has_passed_door_sensor then
    has_passed_door_sensor =  true
  
    -- Close doors.
    map:close_doors("cave_door_")
  end 
end

-- When the boss is being killed.
function tigriss_enemy:on_dying()
  
  -- Show a cute tigriss.
  local tigriss_x, tigriss_y = tigriss_enemy:get_position()
  tigriss_npc:set_enabled(false)
  tigriss_npc_docile:set_position(tigriss_x, tigriss_y)
  tigriss_npc_docile:set_enabled(true)
end

-- When the boss is killed.
function tigriss_enemy:on_dead()
  sol.audio.stop_music()
  hero:freeze()

  sol.timer.start(map, 1000, function()
    map:open_doors("cave_door_")

    sol.timer.start(map, 1000, function()
      sol.audio.play_sound("secret")

      sol.timer.start(map, 1000, function()
        -- The cute cat speaks.
        game:start_dialog("chores.miaou_4", function()
            hero:unfreeze()
            sol.audio.play_music("alttp/village")
        end)
      end)
    end)
  end)
end

-- Some sinisters sounds before fighting the boss...
function miaou_sensor_1:on_activated()
  if not boss_mode then
    return
  end
  
  if not has_passed_miaou_sensor_1 then
    has_passed_miaou_sensor_1 = true
    game:start_dialog("chores.miaou_1")
  end
end

-- Some sinisters sounds before fighting the boss...
function miaou_sensor_2:on_activated()
  if not boss_mode then
    return
  end

  if not has_passed_miaou_sensor_2 then
    has_passed_miaou_sensor_2 = true
    game:start_dialog("chores.miaou_2")
  end
end

-- Trigger the cat.
function boss_fight_sensor:on_activated()
  if not boss_mode then
    return
  end

  if not has_passed_boss_fight_sensor then
    has_passed_boss_fight_sensor = true
    
    -- Stop music.
    sol.audio.stop_music()
    
    -- Stop the hero.
    hero:freeze()

    -- Tigriss vibrates a bit to simulate anger.
    local tigriss_npc_sprite = tigriss_npc:get_sprite()
    tigriss_npc_sprite:set_animation("shaking")

    sol.timer.start(map, 1000, function()
      -- Show dialog.
      game:start_dialog("chores.miaou_3", function()
        -- Show tigriss as an enemy.
        local tigriss_x, tigriss_y = tigriss_npc:get_position()
        tigriss_npc_docile:set_enabled(false)
        tigriss_npc:set_enabled(false)
        tigriss_enemy:set_position(tigriss_x, tigriss_y)
        tigriss_enemy:set_enabled(true)

        -- Unstop the hero.
        hero:unfreeze()    

        -- Boss music.
        sol.audio.play_music("alttp/boss")
      end)
    end)
  end

end

-- Called when the hero talks to the docile cat.
function tigriss_npc_docile:on_interaction()
  local zelda_cat_fed = game:get_value("zelda_cat_fed")

  if zelda_cat_fed ~= nil and zelda_cat_fed then
    game:start_dialog("chores.cat_fed")
  else 
    game:start_dialog("chores.cat_gurgling")
  end
end

-- Called by the item when it is used.
function tigriss_npc_docile:use_food()
  hero:freeze()
  sol.timer.start(map, 300, function()
    local tigriss_sprite = tigriss_npc_docile:get_sprite()
    tigriss_sprite:set_animation("eating")
    hero:freeze()

    sol.timer.start(map, 4000, function()
      tigriss_sprite:set_animation("stopped")

      sol.audio.play_sound("secret")

      sol.timer.start(map, 500, function()
        game:start_dialog("chores.cat_fed", function()
          hero:unfreeze()
          -- Go to next chore.
          game:set_value("introduction_chore_step", 1)
        end)
      end)
    end)
  end)
end