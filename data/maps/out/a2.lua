local map = ...
local game = map:get_game()

local track_path = {
  0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0,
  7,7, 7,7, 7,7, 
  0,0, 0,0,
  1,1, 1,1,
  0,0, 0,0,
  7,7, 7,7, 
  6,6, 6,6, 6,6, 6,6, 6,6, 6,6, 
  5,5, 5,5, 5,5, 
  6,6, 6,6, 6,6, 6,6, 6,6,
  7,7, 7,7, 
  6,6, 
  5,5, 5,5, 5,5, 
  4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 4,4, 
  3,3, 3,3, 3,3, 3,3, 
  2,2, 2,2, 2,2, 
  3,3, 3,3, 3,3,
  2,2, 2,2, 2,2,
  1,1, 1,1, 1,1,
  2,2, 2,2, 2,2,
  1,1, 1,1, 1,1, 1,1,
}

local function start_kart(kart, initial_path_index)

  local path = {}
  for i = initial_path_index, #track_path do
    path[#path + 1] = track_path[i]
  end
  for i = 1, initial_path_index - 1 do
    path[#path + 1] = track_path[i]
  end

  local movement = sol.movement.create("path")

  movement:set_path(path)
  movement:set_speed(96)
  movement:set_loop(true)
  movement:set_ignore_obstacles(true)
  -- TODO different speed for each, and changing speeds
  movement:start(kart)

end

function map:on_started()

  local movement = sol.movement.create("random_path")
  movement:start(doc)

  deloreane:get_sprite():set_animation("flying")

  start_kart(toad, 133)
  start_kart(mario, 7)
  start_kart(yoshi, 45)
  start_kart(deloreane, 95)

end

function no_entry_sensor:on_activated()
  game:start_dialog("chill_valley.no_entry_2")
end
