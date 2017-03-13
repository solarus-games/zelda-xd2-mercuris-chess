-- Lua script of map main_village/link_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local zelda_chores = require("scripts/maps/zelda_chores")

local has_passed_miaou_sensor_1 = false
local has_passed_miaou_sensor_2 = false
local has_passed_boss_fight_sensor = false
local has_passed_door_sensor = false
local boss_mode = false
local first_time = true

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- Open doors by default.
  map:set_doors_open("cave_door_")
  
  -- Check if the cat has already been fed: get chores state.
  local chore_step, chore_done, all_chores_done = zelda_chores:get_chores_state()
  
  first_time = not all_chores_done

  if chore_step == 0 and not chore_done then
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

-------------------------------------------------------------------------------

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
  
  -- Stop the hero.
  hero:freeze()

  -- Hide enemy.
  tigriss_enemy:set_enabled(false)

  -- Show a cute tigriss.
  local tigriss_x, tigriss_y = tigriss_enemy:get_position()
  tigriss_npc:set_enabled(false)
  tigriss_npc_docile:set_position(tigriss_x, tigriss_y)
  tigriss_npc_docile:set_enabled(true)

  -- Bypass explosion animation
  tigriss_enemy:remove()

  -- Reopen doors
  map:reopen_doors()

end

-- Called after the cat has been fed.
function map:reopen_doors()
  sol.audio.stop_music()
  hero:freeze()

  sol.timer.start(map, 1000, function()
    map:open_doors("cave_door_")

    sol.timer.start(map, 1000, function()
      -- The cute cat speaks.
      game:start_dialog("chores.miaou_4", function()
        hero:unfreeze()

        sol.audio.play_music("alttp/village")
      end)
    end)
  end)
end

-- Some sinisters sounds before fighting the boss...
function miaou_sensor_1:on_activated()
  if not boss_mode then
    return
  end
  
  if first_time and not has_passed_miaou_sensor_1 then
    has_passed_miaou_sensor_1 = true
    game:start_dialog("chores.miaou_1")
  end
end

-- Some sinisters sounds before fighting the boss...
function miaou_sensor_2:on_activated()
  if not boss_mode then
    return
  end

  if first_time and not has_passed_miaou_sensor_2 then
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

-- Called when the cat food is used.
function tigriss_npc_docile:use_food()
  -- The hero can feed the cat only in boss mode.
  if boss_mode then
    -- Freeze hero.
    hero:freeze()
    sol.timer.start(map, 200, function()
      -- The cat is eating the food.
      local tigriss_sprite = tigriss_npc_docile:get_sprite()
      tigriss_sprite:set_animation("eating")
      sol.timer.start(map, 4000, function()
        -- The cat has eaten the food.
        tigriss_sprite:set_animation("stopped")
        sol.audio.play_sound("secret")
        sol.timer.start(map, 500, function()
          game:start_dialog("chores.cat_fed", function()
            -- Unfreeze hero.
            hero:unfreeze()
            -- Validate the current chore.
            zelda_chores:set_chore_done(true)
          end)
        end)
      end)    
    end)
  -- If not in boss mode, a dialog tells the player that the
  -- cat has already been fed.
  else
    game:start_dialog("chores.cat_already_fed")
  end
end
