local map = ...
local game = map:get_game()

local chess_utils = require("scripts/maps/chess_utils")

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_a", 0, 3)

elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

function map:on_started(destination)

  if destination == from_2f_w then
    map:set_doors_open("door_d")
  end

  -- Access to the kitchen.
  if game:get_value("dungeon_2_kitchen_guard_access") then
    kitchen_guard:set_position(kitchen_guard_access_placeholder:get_position())
  end
end

function map:on_opening_transition_finished(destination)

  if destination == from_outside then
    game:start_dialog("dungeon_2.welcome")
  end
end

-- Kitchen access.
function kitchen_guard:on_interaction()

  if not game:get_value("dungeon_2_kitchen_guard_access") then
    game:start_dialog("dungeon_2.1f.kitchen_guard_dont_pass")
  else
    game:start_dialog("dungeon_2.1f.kitchen_guard_go_wash")
  end
end

function unblock_kitchen_guard_sensor:on_activated()

  game:set_value("dungeon_2_kitchen_guard_access", true)
  kitchen_guard:set_position(kitchen_guard_access_placeholder:get_position())
end

-- Bartender.
function bartender:on_interaction()

  game:start_dialog("dungeon_2.1f.bartender", function(answer)
    if answer == 1 then
      if game:get_money() < 100 then
        game:start_dialog("_shop.not_enough_money")
      else
        game:remove_money(100)
        game:start_dialog("dungeon_2.1f.bartender_bought_red_potion_kir")
        game:add_life(4)
        local red_potion_kir_count = 0
        sol.timer.start(game, 3000, function()
          if game:get_life() < game:get_max_life() then
            game:add_life(1)
            sol.audio.play_sound("heart")
          end
          red_potion_kir_count = red_potion_kir_count + 1
          return red_potion_kir_count < 80
        end)
      end
    end
  end)
end

-- 4 knights puzzle.
local function check_knights()

  local solved = true
  for i = 1, 4 do
    local knight = map:get_entity("knight_" .. i)
    if chess_utils:get_num_knights_controlling(knight, "knight_") ~= 2 then
      solved = false
      break
    end
  end

  if solved and not door_d:is_open() then
    sol.audio.play_sound("secret")
    map:open_doors("door_d")
  elseif not solved and door_d:is_open() then
    map:close_doors("door_d")
  end

end

knight_1.on_position_changed = check_knights
knight_2.on_position_changed = check_knights
knight_3.on_position_changed = check_knights
knight_4.on_position_changed = check_knights
