-- Armos Tie boss.

local enemy = ...
local center
local radius

function enemy:on_created()

  enemy:set_life(16)
  enemy:set_damage(4)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_hurt_style("boss")
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_red")

  enemy:set_invincible()
  enemy:set_attack_consequence("sword", 1)
end

function enemy:on_restarted()

  enemy:set_center(center)
end

function enemy:set_color(color)

  enemy:remove_sprite()
  local sprite_id = "enemies/" .. enemy:get_breed() .. "_" .. color
  enemy:create_sprite(sprite_id)
end

function enemy:set_center(center_entity)

  center = center_entity

  if center ~= nil then
    local angle = center_entity:get_angle(enemy) * 360 / (2 * math.pi)
    radius = radius or center:get_distance(enemy)
    local movement = sol.movement.create("circle")
    movement:set_center(center)
    movement:set_radius(radius)
    movement:set_initial_angle(angle)
    movement:set_angle_speed(90)
    movement:set_ignore_obstacles(true)
    movement:start(enemy)
  end
end
