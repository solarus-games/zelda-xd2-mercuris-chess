-- Rupee projectile.
local enemy = ...
local game = enemy:get_game()

local sprite

local money_value
local projectile_speed

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_minimum_shield_needed(2)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")

  enemy:set_money_value(1)
  enemy:set_projectile_speed(192)

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end

local function go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(enemy:get_projectile_speed())
  movement:set_angle(angle)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  movement:start(enemy)
end

function enemy:on_restarted()

  local hero = enemy:get_map():get_hero()
  local angle = enemy:get_angle(hero:get_center_position())

  -- Add some randomness to the angle.
  angle = angle + (math.random() * math.pi / 8) - (math.pi / 16)

  go(angle)
end

-- Destroy the rupee and give money when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)

  hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
  game:add_money(enemy:get_money_value())
  enemy:remove()
end

-- Change the direction of the movement when hit with the sword.
function enemy:on_custom_attack_received(attack, sprite)

  if attack == "sword" then
    local hero = enemy:get_map():get_hero()
    local movement = enemy:get_movement()
    if movement == nil then
      return
    end

    local hero_x, hero_y = hero:get_position()
    local angle = enemy:get_angle(hero_x, hero_y - 5) + math.pi

    go(angle)
    sol.audio.play_sound("enemy_hurt")
  end
end

function enemy:get_money_value()
  return money_value
end

function enemy:set_money_value(value)
  money_value = value
end

function enemy:get_projectile_speed()
  return projectile_speed
end

function enemy:set_projectile_speed(speed)
  projectile_speed = speed
end
