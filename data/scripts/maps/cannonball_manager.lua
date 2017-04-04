local cannonball_manager = {}

function cannonball_manager:create_cannons(map, prefix)

  -- Random cannonballs.
  local cannons = {}
  for cannon in map:get_entities(prefix) do
    if cannon:get_type() == "custom_entity" then
      cannons[#cannons + 1] = cannon
    end
  end
  if #cannons == 0 then
    return
  end
  sol.timer.start(map, 300, function()

    local hero = map:get_entity("hero")
    if hero:is_in_same_region(cannons[1]) then
      local index = math.random(#cannons)
      local cannon = cannons[index]
      local x, y, layer = cannon:get_position()
      map:create_enemy{
        name = "cannonball",
        breed = "cannonball",
        x = x,
        y = y,
        layer = layer,
        direction = cannon:get_direction(),
      }
    else
      map:remove_entities("cannonball")
    end
    return true  -- Repeat the timer.
  end)

end

return cannonball_manager
