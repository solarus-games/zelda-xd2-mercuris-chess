-- A torch that can be lit by fire and unlit by ice.
-- Methods: is_lit(), set_lit()
-- Events: on_lit(), on_unlit()
-- The initial state depends on the direction: unlit if direction 0, lit otherwise.
--
-- Torches whose name starts with "timed_torch" have a limited light duration.
-- You can also use torch:set_duration() for more control.
local torch = ...
local map = torch:get_map()
local sprite

function torch:on_created()

  torch:set_size(16, 16)
  torch:set_origin(8, 13)
  torch:set_traversable_by(false)
  if torch:get_sprite() == nil then
    torch:create_sprite("entities/torch")
  end
  sprite = torch:get_sprite()

  local lit = torch:get_direction() ~= 0

  sprite:set_direction(0)
  torch:set_lit(lit)

  local name = torch:get_name()
  if name ~= nil and name:match("^timed_torch") then
    torch:set_duration(10000)
  end
end

function torch:is_lit()
  return sprite:get_animation() == "lit"
end

function torch:set_lit(lit)

  if lit then
    sprite:set_animation("lit")
    if torch.duration ~= nil then
      sol.timer.start(torch, torch.duration, function()
        torch:set_lit(false)
      end)
    end
  else
    sprite:set_animation("unlit")
  end

  if map.torch_changed ~= nil then
    map:torch_changed(torch, lit)
  end
end

function torch:get_duration()
  return torch.duration
end

-- Sets the light duration. nil means unlimited.
function torch:set_duration(duration)
  torch.duration = duration
end

local function on_collision(torch, other, torch_sprite, other_sprite)

  if other:get_type() == "custom_entity" then

    local other_model = other:get_model()
    if other_model == "fire" then
      if not torch:is_lit() then
        torch:set_lit(true)
        if torch.on_lit ~= nil then
          torch:on_lit()
        end

        sol.timer.start(other, 50, function()
          other:stop_movement()
          other:get_sprite():set_animation("stopped")
        end)

      end

    elseif other_model == "ice_beam" then
      if torch:is_lit() then
        torch:set_lit(false)
        if torch.on_unlit ~= nil then
          torch:on_unlit()
        end
      end

      sol.timer.start(other, 50, function()
        other:stop_movement()
        sol.timer.start(other, 150, function()
          other:remove()
        end)
      end)

    end

  elseif other:get_type() == "enemy" then

    local other_model = other:get_breed()
    if other_model == "fireball_red_small" then
      if not torch:is_lit() then
        torch:set_lit(true)
        if torch.on_lit ~= nil then
          torch:on_lit()
        end
      end
      other:remove()
    end
  end
end

torch:set_traversable_by("custom_entity", function(torch, other)
  return other:get_model() == "fire" or other:get_model() == "ice"
end)

torch:add_collision_test("sprite", on_collision)
torch:add_collision_test("overlapping", on_collision)
