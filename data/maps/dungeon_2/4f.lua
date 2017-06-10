local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_a", 0, 3)
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local cannonball_manager = require("scripts/maps/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")

function map:on_started()

  if auto_door_e:is_open() then
    auto_switch_auto_door_e:set_locked(true)
  end
end

auto_separator_1:register_event("on_activated", function()
  if auto_door_e:is_open() then
    auto_switch_auto_door_e:set_locked(true)
  end
end)

auto_separator_4:register_event("on_activated", function()
  if auto_door_e:is_open() then
    auto_switch_auto_door_e:set_locked(true)
  end
end)

function weak_wall_a:on_opened()
  sol.audio.play_sound("secret")
end
