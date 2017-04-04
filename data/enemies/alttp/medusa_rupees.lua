-- Like Medusa but shoots rupees sometimes.
local enemy = ...

local other_script = sol.main.load_file("enemies/alttp/medusa")
other_script(enemy)

-- Redefine the projectile choice.
function enemy:get_projectile_breed_and_sound()

  local n = math.random(100)

  if n <= 50 then
    return "rupee_green", "rupee_counter_end"
  end

  if n <= 80 then
    return "rupee_blue", "rupee_counter_end"
  end

  return "rupee_red", "rupee_counter_end"
end
