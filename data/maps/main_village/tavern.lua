local map = ...
local game = map:get_game()

function map:on_started()

  if heart_container_1 ~= nil then
    heart_container_2:set_enabled(false)
    heart_container_3:set_enabled(false)
    heart_container_4:set_enabled(false)
    heart_container_5:set_enabled(false)
  elseif heart_container_2 ~= nil then
    heart_container_3:set_enabled(false)
    heart_container_4:set_enabled(false)
    heart_container_5:set_enabled(false)
  elseif heart_container_3 ~= nil then
    heart_container_4:set_enabled(false)
    heart_container_5:set_enabled(false)
  elseif heart_container_4 ~= nil then
    heart_container_5:set_enabled(false)
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)

  local next_heart_container
  if savegame_variable == "main_village_shop_heart_container_1" then
    next_heart_container = heart_container_2
  elseif savegame_variable == "main_village_shop_heart_container_2" then
    next_heart_container = heart_container_3
  elseif savegame_variable == "main_village_shop_heart_container_3" then
    next_heart_container = heart_container_4
  elseif savegame_variable == "main_village_shop_heart_container_4" then
    next_heart_container = heart_container_5
  elseif savegame_variable == "main_village_shop_heart_container_5" then
    game:start_dialog("main_village.tavern.heart_containers_done")
  end

  if next_heart_container ~= nil then
    game:start_dialog("main_village.tavern.heart_container_price_increasing", function()
      next_heart_container:set_enabled(true)
    end)
  end
end
