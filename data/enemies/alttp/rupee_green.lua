-- Rupee projectile.
local enemy = ...
local game = enemy:get_game()

local sprite

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_minimum_shield_needed(2)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")

  enemy:set_money_value(1)

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end

local function go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(192)
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

    local old_angle = movement:get_angle()
    local angle
    local hero_direction = hero:get_direction()
    if hero_direction == 0 or hero_direction == 2 then
      angle = math.pi - old_angle
    else
      angle = 2 * math.pi - old_angle
    end

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
