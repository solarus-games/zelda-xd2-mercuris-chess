-- Initialize carried object behavior specific to this quest.

local carried_object_meta = sol.main.get_metatable("carried_object")

function carried_object_meta:on_removed()
  local sprite = self:get_sprite()
  if sprite:get_animation_set() == "entities/dungeon_1/iron_ball" then
    local x, y, layer = self:get_position()
    local map = self:get_map()

    if map.pillar_collision ~= nil then
      map:pillar_collision(self)
    end

    local next_ball = map:create_destructible({name = "iron_ball", layer = layer, x = x, y = y, sprite = sprite:get_animation_set()})
    --falling_movement = sol.movement.create("pixel")
    --falling_movement:start(next_ball)
 
    --next_ball
  end
end

function carried_object_meta:on_position_changed()
  local sprite = self:get_sprite()
  if sprite:get_animation_set() == "entities/dungeon_1/iron_ball" then
    self.real_x, self.real_y = self:get_position()
  end
end

return true
