local enemy = ...

local pike_detect_script = sol.main.load_file("enemies/alttp/pike_auto")
pike_detect_script(enemy)

local other_on_started = enemy.on_started
function enemy:on_started()
  other_on_started(enemy)
  enemy:remove_sprite()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end
