-- Lua script of enemy oclero/flying_chicken.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local shadow, shadow_sprite -- Custom entity shadow.
local height_for_small_shadow = 48 -- Height for small shadow.
local flying_timer

function enemy:on_created()

  enemy:set_invincible() -- Invincible while flying.
  self:set_can_attack(false) -- Cannot attack while flying.
  sprite = enemy:create_sprite("enemies/alttp/chicken_flying")
  enemy:set_life(1)
  enemy:set_damage(1)
  -- Create shadow and update it depending on the height.
  local x, y, layer = enemy:get_position()
  local shadow_prop = {x = x, y = y, layer = layer, direction = 0, width = 16, height = 16}
  shadow = map:create_custom_entity(shadow_prop)
  shadow_sprite = shadow:create_sprite("entities/shadow_dynamic")
  shadow:set_drawn_in_y_order()
  sol.timer.start(shadow, 1, function()
    local dx, dy = sprite:get_xy()
    local height = math.min(-dy, height_for_small_shadow)
    local num_frames = 8
    local frame = math.floor( ( height / height_for_small_shadow ) * num_frames )
    frame = math.min(frame, 7)
    shadow_sprite:set_frame(frame)
    shadow:set_position(enemy:get_position()) -- Follow enemy.
    return true
  end)
  -- Move to upper layer and fly high.
  local x, y, layer = enemy:get_position()
  enemy:set_position(x, y, layer + 1)
  enemy:fly_high()
end

function enemy:on_restarted()
end

function enemy:on_removed()

  -- Remove shadow when destroyed.
  if shadow then shadow:remove() end
end

-- Make the chicken fly high. Parameter is optional.
function enemy:fly_high(height)
  
  local height = height or height_for_small_shadow
  height = - math.abs(height) -- Take negative value.
  local dx, dy = sprite:get_xy()
  local shift = (dy < height) and 1 or -1
  sol.timer.start(shadow, 20, function()
    -- (Timer on the shadow to avoid problems if restarted.)
    -- Set height.
    local dx, dy = sprite:get_xy()
    if dy == height then return end
    dy = dy + shift
    sprite:set_xy(dx, dy)
    -- Allow to attack and be attacked when low.
    if dy <= -24 then
        enemy:set_invincible()
        enemy:set_can_attack(true)
    else
        enemy:set_default_attack_consequences()
        enemy:set_can_attack(false)
    end
    -- Restart timer.
    return true
  end)
end

-- Fly in circles around the boss.
function enemy:fly_around_boss(boss)

  -- Get angle and distance to boss.
  local boss = boss
  local r = boss:get_distance(enemy)
  local a = boss:get_angle(enemy)
  -- Start timer to move around.
  local period = 5000 -- Duration of each revolution.
  local angular_speed = 2 *math.pi / period 
  local t = 0 -- Time variable.
  local max_height = height_for_small_shadow
  local min_height = 8
  local current_state = "ascend"
  -- Timer on the shadow, to avoud
  flying_timer = sol.timer.start(shadow, 1, function()
    -- (Timer on the shadow to avoid problems if restarted.)
    -- Set position.
    t = (t + 1) % period
    local x, y, layer = boss:get_position() -- Boss position.
    local new_angle = (a + angular_speed * t) % (2 * math.pi)
    x = x  + r * math.cos(new_angle)
    y = (y - 16) - r * math.sin(new_angle)
    enemy:set_position(x, y, layer)
    -- Set sprite direction. 
    local dir = enemy:get_direction4_to(boss)
    sprite:set_direction(dir)
    -- Change height for certain angles (10 circle sectors).
    local sector = math.floor( (10 * new_angle) / (2* math.pi) )
    if sector % 2 == 0 and current_state == "ascend" then
      enemy:fly_high(min_height)
      current_state = "descend"
    elseif sector % 2 == 1 and current_state == "descend" then
      enemy:fly_high(max_height)
      current_state = "ascend"
    end
    -- Repeat timer.
    return true
  end)
end

-- Attack hero with fast flying attack.
-- After attack, replace the enemy with normal chicken!
function enemy:fly_to_hero()

  -- Stop moving around the boss (stop timers).
  sol.timer.stop_all(enemy)
  flying_timer:stop()
  -- Start movement towards hero. Stop ignoring obstacles after reaching his position.
  movement = sol.movement.create("target")
  local x, y, layer = hero:get_position()
  movement:set_target(x, y)
  movement:set_speed(64)
  movement:set_ignore_obstacles(true)
  movement:start(enemy)
  function movement:on_finished()
    enemy:stop_movement() -- Stop target movement.
    enemy:fly_high(0) -- Descend.
    sol.timer.start(enemy, 1500, function() -- Wait for descent.
      -- Replace flying chicken for normal one.
      local prop = {x = x, y = y, layer = layer, direction = 0, breed = "alttp/chicken_mortal"}
      local chick = map:create_enemy(prop)
      chick:set_life(1)
      enemy:remove()
    end)
  end
end
