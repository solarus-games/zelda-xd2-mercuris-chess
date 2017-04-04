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

local function start_kart(kart, properties)

  local initial_path_index = properties.initial_path_index
  local speed = properties.speed or 96
  local harmful = properties.harmful or false
  local hurt_sound = properties.hurt_sound
  local treasure = properties.treasure or {}

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

  local sprite = kart:get_sprite()
  sprite:set_animation("walking")

  local movement = sol.movement.create("path")

  movement:set_path(path)
  movement:set_speed(speed)
  movement:set_loop(true)
  movement:set_ignore_obstacles(true)
  movement:start(kart)

  function movement:on_changed()
    if not kart.banana_collision then
      sprite:set_direction(movement:get_direction4())
    end
  end

  if harmful then
    -- Hurt the hero.
    kart:add_collision_test("sprite", function(kart, other)
      if other ~= hero then
        return
      end

      if hero:is_invincible() then
        return
      end

      if kart.banana_collision then
        -- The kart was hurt.
        return
      end

      hero:start_hurt(kart, 6)
    end)

    -- React to banana skins.
    kart:add_collision_test("overlapping", function(kart, other)
      if other:get_type() ~= "pickable" then
        return
      end

      if other:get_treasure():get_name() ~= "banana_skin" then
        return
      end

      if kart.banana_collision then
        -- Already done.
        return
      end

      kart.banana_collision = true
      other:remove()

      if hurt_sound ~= nil then
        sol.audio.play_sound(hurt_sound)
      end

      -- Create the treasure if any.
      sol.timer.start(map, 300, function()
        local treasure_name, treasure_variant, treasure_savegame_variable = unpack(treasure)
        local x, y, layer = kart:get_position()
        map:create_pickable({
          x = x,
          y = y,
          layer = layer,
          treasure_name = treasure_name,
          treasure_variant = treasure_variant,
          treasure_savegame_variable = treasure_savegame_variable,
        })
      end)

      sol.timer.start(kart, 100, function()
        sprite:set_direction((sprite:get_direction() + 1) % 4)
        -- Keep turning while the movement is active.
        return kart:get_movement() ~= nil
      end)

      local hurt_movement = sol.movement.create("straight")
      local direction4 = movement:get_direction4()
      local random_angle = (math.random() * math.pi / 6) - math.pi / 12
      local angle = (direction4 * math.pi / 2) + random_angle
      hurt_movement:set_angle(angle)
      hurt_movement:set_speed(speed)
      hurt_movement:set_max_distance(192)
      hurt_movement:set_smooth(false)
      hurt_movement:start(kart, function()
        hurt_movement:on_obstacle_reached()
      end)

      function hurt_movement:on_obstacle_reached()
        kart:stop_movement()
        sol.timer.start(kart, 50, function()
          kart:set_visible(not kart:is_visible())
          return true
        end)
        sol.timer.start(kart, 1000, function()
          kart:set_enabled(false)
        end)
      end
    end)
  end

end

function map:on_started()

  local movement = sol.movement.create("random_path")
  movement:start(doc)

  start_kart(toad, {
    initial_path_index = 133,
    speed = math.random(96, 128),
    harmful = true,
    hurt_sound = "mk64_toad",
    treasure = {
      "piece_of_heart",
      1,
      "chill_valley_invisible_piece_of_heart",
      -- Savegame variable from 1.0.0 when the
      -- piece of heart was not in the kart.
    }
  })
  start_kart(mario, {
    initial_path_index = 7,
    speed = math.random(64, 128),
    harmful = true,
    hurt_sound = "mk64_mario_mammamia",
    treasure = {
      "rupee",
      3,
    }
  })
  start_kart(yoshi, {
    initial_path_index = 45,
    speed = math.random(96, 192),
    harmful = true,
    hurt_sound = "mk64_yoshi_hurt",
    treasure = {
      "rupee",
      2,
    }
  })
  start_kart(deloreane, {
    initial_path_index = 95,
    speed = math.random(64, 96),
    hurt_sound = false,
  })

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
