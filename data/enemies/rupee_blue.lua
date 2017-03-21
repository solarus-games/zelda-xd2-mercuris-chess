local enemy = ...

local other_script = sol.main.load_file("enemies/rupee_green")
other_script(enemy)

enemy:set_damage(4)
enemy:set_money_value(5)
enemy:set_projectile_speed(240)
