-- Initialize carried object behavior specific to this quest.

local carried_object_meta = sol.main.get_metatable("carried_object")
local next_ball = nil
local arc_x, arc_yc = 0
local real_x, real_y = 0

local function ball_bounce_down()
  bounce_down_movement = sol.movement.create("target")
  bounce_down_movement:set_target(real_x, real_y)
  bounce_down_movement:set_speed(200)
  bounce_down_movement:start(next_ball)
end

local function ball_bounce_up()
  local mid_y = ((arc_y - real_y) / 4) + real_y
  bounce_up_movement = sol.movement.create("target")
  bounce_up_movement:set_target(real_x, mid_y)
  bounce_up_movement:set_speed(200)
  bounce_up_movement:start(next_ball, ball_bounce_down)
end

function carried_object_meta:on_removed()
  local sprite = self:get_sprite()
  if sprite:get_animation_set() == "entities/dungeon_1/iron_ball" then
    arc_x, arc_y, layer = self:get_position()
    local map = self:get_map()

    if map.pillar_collision ~= nil then
      map:pillar_collision(self)
    end

    next_ball = map:create_destructible({name = "iron_ball", layer = layer, x = arc_x, y = arc_y, sprite = sprite:get_animation_set()})
    falling_movement = sol.movement.create("target")
    falling_movement:set_target(real_x, real_y)
    falling_movement:set_speed(200)
    falling_movement:start(next_ball, ball_bounce_up)
  end
end

function carried_object_meta:on_position_changed()
  local sprite = self:get_sprite()
  if sprite:get_animation_set() == "entities/dungeon_1/iron_ball" then
    real_x, real_y = self:get_position()
  end
end

return true
