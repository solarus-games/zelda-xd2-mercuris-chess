local map = ...
local game = map:get_game()

local water_delay = 500
local num_torches_lit = 0

function map:on_started()

  if game:get_value("water_house_pool_empty") then
    map:set_entities_enabled("pool_", false)
    for torch in map:get_entities("torch_") do
      torch:set_lit(true)
    end
  else
    torch_2:set_lit(true)  -- Make a torch lit to give a hint.
    num_torches_lit = 1
  end
end

local function empty_pool()

  sol.audio.play_sound("water_fill_begin")
  sol.audio.play_sound("water_fill")
  hero:freeze()
  local water_tile_index = 1
  sol.timer.start(water_delay, function()
    local next_tile = map:get_entity("pool_" .. water_tile_index)
    local previous_tile = map:get_entity("pool_" .. water_tile_index - 1)
    if next_tile == nil then
      previous_tile:set_enabled(false)
      sol.audio.play_sound("secret")
      hero:unfreeze()
      game:set_value("water_house_pool_empty", true)
      water_guy:get_sprite():set_direction(1)
      sol.timer.start(map, 500, function()
        game:start_dialog("main_village.water_house.upset")
      end)
      return false
    end
    next_tile:set_enabled(true)
    if previous_tile ~= nil then
      previous_tile:set_enabled(false)
    end
    water_tile_index = water_tile_index + 1
    return true
  end)
end

local function torch_on_lit(torch)

  num_torches_lit = num_torches_lit + 1
  if num_torches_lit == 4 and not game:get_value("water_house_pool_empty") then
    empty_pool()
  end
end

for torch in map:get_entities("torch_") do
  torch.on_lit = torch_on_lit
end

function water_guy:on_interaction()

  if game:get_value("water_house_pool_empty") then
    game:start_dialog("main_village.water_house.upset")
  else
    game:start_dialog("main_village.water_house.hello")
  end
end
