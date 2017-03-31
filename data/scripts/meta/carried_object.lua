-- Initialize carried object behavior specific to this quest.

local carried_object_meta = sol.main.get_metatable("carried_object")

function carried_object_meta:on_removed()
  local sprite = self:get_sprite()
  if sprite:get_animation_set() == "entities/dungeon_1/iron_ball" then
    local x, y, layer = self:get_position()
    local map = self:get_map()
    map:create_destructible({name = "iron_ball", layer = layer, x = x, y = y, sprite = sprite:get_animation_set()})
  end
end

function carried_object_meta:on_movement_started(movement)
  local sprite = self:get_sprite()
  if sprite:get_animation_set() == "entities/dungeon_1/iron_ball" then
    print("throwed")
  end
end

return true
