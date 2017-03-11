local enemy = ...

local other_script = sol.main.load_file("enemies/alttp/bubble")
other_script(enemy)

local other_on_started = enemy.on_started
function enemy:on_started()
  other_on_started(enemy)
  enemy:remove_sprite()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end
