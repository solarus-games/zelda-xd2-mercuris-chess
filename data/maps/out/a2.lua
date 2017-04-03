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

local function start_kart(kart, initial_path_index, speed, harmful)

  local path = {}
  for i = initial_path_index, #track_path do
    path[#path + 1] = track_path[i]
  end
  for i = 1, initial_path_index - 1 do
    path[#path + 1] = track_path[i]
  end

  kart:set_drawn_in_y_order(true)
  kart:set_can_traverse("hero", true)
  kart:set_traversable_by("hero", true)
  kart:set_traversable_by("custom_entity", true)

  if harmful then
    -- Hurt the hero.
    kart:add_collision_test("sprite", function(kart, other)
      if other ~= hero then
        return
      end

      if not hero:is_invincible() then
        hero:start_hurt(kart, 6)
      end
    end)
  end

  local sprite = kart:get_sprite()
  sprite:set_animation("walking")

  local movement = sol.movement.create("path")

  movement:set_path(path)
  movement:set_speed(speed)
  movement:set_loop(true)
  movement:set_ignore_obstacles(true)
  movement:start(kart)

  function movement:on_changed()
    sprite:set_direction(movement:get_direction4())
  end

end

function map:on_started()

  local movement = sol.movement.create("random_path")
  movement:start(doc)

  start_kart(toad, 133, math.random(96, 128), true)
  start_kart(mario, 7, math.random(64, 128), true)
  start_kart(yoshi, 45, math.random(96, 192), true)
  start_kart(deloreane, 95, math.random(64, 96), false)

  deloreane:get_sprite():set_animation("flying_no_shadow")
  deloreane:set_traversable_by(true)  -- Because flying.
  deloreane:set_traversable_by("hero", true)
  deloreane:get_sprite():set_direction(2)

end

function no_entry_sensor:on_activated()
  game:start_dialog("chill_valley.no_entry_2")
end

function yoshi:on_position_changed()
  if lens_invisible_pickable_yoshi ~= nil then
    lens_invisible_pickable_yoshi:set_position(yoshi:get_position())
  end
end
