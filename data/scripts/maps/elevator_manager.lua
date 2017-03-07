-- This scripts allows to implement an elevator
-- with a menu to choose the floor.

local elevator_manager = {}

local floors_img = sol.surface.create("floors.png", true)

local function get_destination_map_id(map_prefix, selected_floor)

  if selected_floor >= 0 then
    return map_prefix .. (selected_floor + 1) .. "f"
  else
    return map_prefix .. "b" .. selected_floor
  end
end

local function draw_floor(floor, min_floor, max_floor, src_x, dst_surface)

  local screen_width, screen_height = dst_surface:get_size()

  local src_x, src_y = src_x, 180 - 12 * floor
  local src_width, src_height = 32, 13
  local dst_x = screen_width / 2 - src_width / 2
  local dst_y = (max_floor - floor) * 12 + 16
  floors_img:draw_region(src_x, src_y, src_width, src_height, dst_surface, dst_x, dst_y)
end

function elevator_manager:create_elevator(sensor, map_prefix, min_floor, max_floor, destination_name)

  local map = sensor:get_map()
  local game = map:get_game()
  local hero = map:get_entity("hero")
  assert(map:get_floor() ~= nil)
  local current_floor = tonumber(map:get_floor())

  local menu = {}
  local selected_floor = current_floor

  function menu:on_draw(dst_surface)

    -- Show all floors accessible by the elevator.
    for i = min_floor, max_floor do
      draw_floor(i, min_floor, max_floor, 32, dst_surface)
    end

    -- Show the current floor with another color.
    draw_floor(current_floor, min_floor, max_floor, 64, dst_surface)

    -- Show the selected floor with another color.
    draw_floor(selected_floor, min_floor, max_floor, 0, dst_surface)
  end

  function menu:on_command_pressed(command)
    if command == "action" then
      sol.audio.play_sound("zonzifleur/solarus_team_logo")
      local destination_map_id = get_destination_map_id(map_prefix, selected_floor)
      hero:teleport(destination_map_id, destination_name)
      sol.menu.stop(menu)
    elseif command == "attack" then
      sol.menu.stop(menu)
    elseif command == "up" then
      sol.audio.play_sound("cursor")
      selected_floor = selected_floor + 1
      if selected_floor > max_floor then
        selected_floor = min_floor
      end
    elseif command == "down" then
      sol.audio.play_sound("cursor")
      selected_floor = selected_floor - 1
      if selected_floor < min_floor then
        selected_floor = max_floor
      end
    end
  end

  function menu:on_finished()
    game:set_suspended(false)
  end

  function sensor:on_activated()

    game:set_suspended(true)
    sol.menu.start(map, menu)
  end
end

return elevator_manager
