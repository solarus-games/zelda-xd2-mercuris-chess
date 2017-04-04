local enemy = ...
local game = enemy:get_game()

local last_direction8 = 0

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
end

-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  local direction8 = math.random(4) * 2 - 1
  enemy:go(direction8)
end

-- An obstacle is reached: bounce.
function enemy:on_obstacle_reached()

  local dxy = {
    { x =  1, y =  0},
    { x =  1, y = -1},
    { x =  0, y = -1},
    { x = -1, y = -1},
    { x = -1, y =  0},
    { x = -1, y =  1},
    { x =  0, y =  1},
    { x =  1, y =  1}
  }

  -- The current direction is last_direction8:
  -- try the three other diagonal directions.
  local try1 = (last_direction8 + 2) % 8
  local try2 = (last_direction8 + 6) % 8
  local try3 = (last_direction8 + 4) % 8

  if not enemy:test_obstacles(dxy[try1 + 1].x, dxy[try1 + 1].y) then
    enemy:go(try1)
  elseif not enemy:test_obstacles(dxy[try2 + 1].x, dxy[try2 + 1].y) then
    enemy:go(try2)
  else
    enemy:go(try3)
  end
end

-- Makes the Bubble go towards a diagonal direction (1, 3, 5 or 7).
function enemy:go(direction8)

  local m = sol.movement.create("straight")
  m:set_speed(80)
  m:set_smooth(false)
  m:set_angle(direction8 * math.pi / 4)
  m:start(enemy)
  last_direction8 = direction8
end
