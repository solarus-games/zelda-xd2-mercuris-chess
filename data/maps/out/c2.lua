local map = ...

local num_torches_lit = 0

function map:on_started()

  if not torches_chest:is_open() then
    torches_chest:set_enabled(false)
  end
end

local function torch_on_lit(torch)

  num_torches_lit = num_torches_lit + 1
  if num_torches_lit == 2 and not torches_chest:is_enabled() then
    local x, y = torches_chest:get_center_position()
    map:move_camera(x, y, 250, function()
      sol.audio.play_sound("chest_appears")
      torches_chest:set_enabled(true)
    end)
  end
end

for torch in map:get_entities("torch_") do
  torch.on_lit = torch_on_lit
end
