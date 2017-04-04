local enemy = ...
local map = enemy:get_map()
local game = map:get_game()
local hero = map:get_hero()
local sprite

-- Pike that always moves, horizontally or vertically
-- depending on its direction.

local recent_obstacle = 0

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("thrown_item", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_attack_consequence("hookshot", "protected")
  enemy:set_attack_consequence("boomerang", "protected")
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_restarted()

  local direction4 = sprite:get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(192)
  m:set_loop(true)
  m:start(enemy)
end

function enemy:on_obstacle_reached()

  local direction4 = sprite:get_direction()
  sprite:set_direction((direction4 + 2) % 4)

  if recent_obstacle == 0
      and not enemy:test_obstacles() then
    sol.audio.play_sound("sword_tapping")
  end

  recent_obstacle = 8
  enemy:restart()
end

function enemy:on_position_changed()

  if recent_obstacle > 0 then
    recent_obstacle = recent_obstacle - 1
  end
end

