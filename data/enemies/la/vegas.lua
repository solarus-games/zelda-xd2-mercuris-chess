local enemy = ...
local sprite

function enemy:on_created()

  enemy:set_life(4)
  enemy:set_damage(4)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "immobilized")
  enemy:set_attack_consequence("arrow", "immobilized")
  enemy:set_attack_consequence("boomerang", "immobilized")
  enemy:set_attack_consequence("fire", "immobilized")
  enemy:set_attack_consequence("thrown_item", "immobilized")
  enemy:set_hookshot_reaction("immobilized")
  enemy:set_fire_reaction("immobilized")

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_restarted()

  local movement = sol.movement.create("random_path")
  movement:set_speed(48)
  movement:start(enemy)

  -- Random symbol initially.
  sprite:set_direction(math.random(4) - 1)

  -- Switch symbol repeatedly.
  sol.timer.start(enemy, 400, function()
    if sprite:get_animation() ~= "walking" then
      return false
    end
    local direction4 = sprite:get_direction()
    sprite:set_direction((direction4 + 1) % 4)
    return true
  end)
end
