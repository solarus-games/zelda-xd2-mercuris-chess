local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local fire_script = sol.main.load_file("entities/fire")
fire_script(entity)

local sprite =  entity:get_sprite()
sprite:set_animation("repeating")
sprite:set_ignore_suspend(true)
