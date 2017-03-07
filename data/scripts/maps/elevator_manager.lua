-- This scripts allows to implement an elevator
-- with a menu to choose the floor.
-- 
-- Usage:
-- local elevator_manager = require("scripts/maps/elevator_manager")
-- elevator_manager:create_elevator(map, elevator_prefix, min_floor, max_floor, destination_name)
-- - map: The map where to create an elevator.
-- - elevator_prefix: Prefix of the name of elevator entities.
--   There should exist the following entities:
--   - elevator_prefix .. sensor: Where to trigger the elevator.
--   - elevator_prefix .. door: A door to close when the hero is in the elevator.
-- - min_floor: lowest floor accessible from the elevator.
-- - max_floor: highest floor accessible from the elevator.
-- - destination_name: Name of the destination entity on destination maps.

local elevator_manager = {}

local floors_img = sol.surface.create("floors.png", true)

local function get_map_suffix(floor)

  if floor >= 0 then
    return (floor + 1) .. "f"
  else
    return "b" .. floor
  end
end

function elevator_manager:create_elevator(map, elevator_prefix, min_floor, max_floor, destination_name)

  local sensor_name = elevator_prefix .. "_sensor"
  local elevator_sensor = map:get_entity(sensor_name)
  assert(elevator_sensor ~= nil, "Cannot set up elevator: missing elevator sensor '" .. sensor_name .. "'")

  local door_name = elevator_prefix .. "_door"
  local elevator_door = map:get_entity(door_name)
  assert(elevator_door ~= nil, "Cannot set up elevator: missing elevator door '" .. door_name .. "'")

  assert(map:get_floor() ~= nil, "Cannot set up elevator: this map has no floor information")

  local game = map:get_game()
  local hero = map:get_entity("hero")
  local camera = map:get_camera()
  local current_floor = tonumber(map:get_floor())
  local map_prefix = map:get_id():gsub(get_map_suffix(current_floor), "")

  local menu = {}
  local selected_floor = current_floor

  local function cancel_elevator()
    map:open_doors(elevator_door:get_name())
    local x, y = elevator_sensor:get_position()
    hero:set_position(x, y + 8)
    hero:set_direction(3)
    sol.menu.stop(menu)
  end

  local function draw_floor(floor, src_x, dst_surface)

    local elevator_x, elevator_y = elevator_sensor:get_center_position()
    local camera_x, camera_y, camera_width, camera_height = camera:get_bounding_box()

    local src_x, src_y = src_x, 180 - 12 * floor
    local src_width, src_height = 32, 13
    local dst_x = elevator_x - camera_x - 16
    local dst_y = elevator_y - camera_y + 8 + (max_floor - floor) * 12
    floors_img:draw_region(src_x, src_y, src_width, src_height, dst_surface, dst_x, dst_y)
  end

  function menu:on_draw(dst_surface)

    -- Show all floors accessible by the elevator.
    for i = min_floor, max_floor do
      draw_floor(i, 32, dst_surface)
    end

    -- Show the current floor with another color.
    draw_floor(current_floor, 64, dst_surface)

    -- Show the selected floor with another color.
    draw_floor(selected_floor, 0, dst_surface)
  end

  function menu:on_command_pressed(command)

    local handled = false
    if command == "action" then
      if selected_floor == current_floor then
        cancel_elevator()
      else
        sol.audio.play_sound("zonzifleur/solarus_team_logo")
        local destination_map_id = map_prefix .. get_map_suffix(selected_floor)
        hero:teleport(destination_map_id, destination_name)
      end
      handled = true
    elseif command == "attack" then
      cancel_elevator()
      handled = true
    elseif command == "up" then
      sol.audio.play_sound("cursor")
      selected_floor = selected_floor + 1
      if selected_floor > max_floor then
        selected_floor = min_floor
      end
      handled = true
    elseif command == "down" then
      sol.audio.play_sound("cursor")
      selected_floor = selected_floor - 1
      if selected_floor < min_floor then
        selected_floor = max_floor
      end
      handled = true
    end

    return handled
  end

  function menu:on_finished()
    game:set_suspended(false)
    hero:set_visible(true)
  end

  function elevator_sensor:on_activated()

    game:set_suspended(true)
    sol.audio.play_sound("door_closed")
    hero:set_visible(false)
    map:close_doors(elevator_door:get_name())
    local timer = sol.timer.start(map, 200, function()
      sol.menu.start(map, menu)
    end)
    timer:set_suspended_with_map(false)
  end

  -- Always open the door initially.
  map:set_doors_open(elevator_door:get_name())
end

return elevator_manager
