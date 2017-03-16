local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_b", 0, 8)

function map:on_started()

  map:set_doors_open("nw_room_door")
  map:set_entities_enabled("nw_room_enemy", false)

  if nw_room_chest:is_open() then
    close_loud_nw_room_door_sensor:remove()
  else
    nw_room_chest:set_enabled(false)
  end

end

local function nw_room_enemy_on_dead()

  if map:get_entities_count("nw_room_enemy") == 0 and
      nw_room_door:is_closed() then
    sol.audio.play_sound("chest_appears")
    nw_room_chest:set_enabled(true)
    close_loud_nw_room_door_sensor:remove()
    map:open_doors("nw_room_door")
  end
end

for enemy in map:get_entities("nw_room_enemy") do
  enemy.on_dead = nw_room_enemy_on_dead
end

function close_loud_nw_room_door_sensor:on_activated()

  getmetatable(self).on_activated(self)
  map:set_entities_enabled("nw_room_enemy", true)
end
