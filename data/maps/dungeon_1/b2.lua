-- Lua script of map dungeon_1/b2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local fighting_miniboss = false
local previous_music = sol.audio.get_music()

local function spike_collision()
  if hero:is_in_same_region(crystal_sensor) then
    sol.audio.play_sound("switch")
    map:change_crystal_state()
  end
end

function map:on_started()
  -- rotating platform states
  local rp1_state = game:get_value("dungeon_1_b2_rp1_state")
  local rp2_state = game:get_value("dungeon_1_b2_rp1_state")
  map:get_entity("rp_1"):set_state(rp1_state)
  map:get_entity("rp_2"):set_state(rp2_state)

  -- spike and crystal
  crystal_sensor:add_collision_test("touching", spike_collision)

  -- miniboss
  map:set_doors_open("miniboss_door")
  map:set_entities_enabled("miniboss_enemy", false)

  for stopper in map:get_entities("miniboss_center_wall") do
    stopper:set_traversable_by(true)
    stopper:set_traversable_by("custom_entity", false)  -- Limit the movement of the center.
  end
end

function map:on_finished()
  -- save rotating platform states
  local rp1_state = map:get_entity("rp_1"):get_state()
  local rp2_state = map:get_entity("rp_2"):get_state()
  game:set_value("dungeon_1_b2_rp1_state", rp1_state)
  game:set_value("dungeon_1_b2_rp2_state", rp2_state)
end

function miniboss_weak_wall:on_opened()
  sol.audio.play_sound("secret")
end

-- mini boss room
function miniboss_sensor:on_activated()

  if game:get_value("dungeon_1_miniboss_clear") then
    return
  end

  if fighting_miniboss then
    return
  end

  map:close_doors("miniboss_door")
  miniboss_enemy_1:set_color("red")
  miniboss_enemy_2:set_color("green")
  miniboss_enemy_3:set_color("blue")
  miniboss_enemy_4:set_color("yellow")
  
  hero:freeze()
  sol.audio.stop_music()
  fighting_miniboss = true
  sol.timer.start(map, 1000, function()
    sol.audio.play_music("alttp/boss")
    hero:unfreeze()

    for enemy in map:get_entities("miniboss_enemy") do
      enemy:set_enabled(true)
      enemy:set_center(miniboss_center)
    end

    local movement = sol.movement.create("target")
    movement:set_target(hero)
    movement:set_speed(32)
    movement:start(miniboss_center)
  end)
end

function miniboss_sensor_2:on_activated()
  miniboss_sensor:on_activated()
end

local function miniboss_enemy_on_dying(enemy)

  -- The next move is fatal: change the hurt style to normal
  -- except for the last enemy, to avoid multiple
  -- series of explosions.
  if map:get_entities_count("miniboss_enemy") > 1 then
    enemy:set_hurt_style("normal")
  else
    enemy:set_hurt_style("boss")
  end
end

local function miniboss_enemy_on_dead(enemy)

  if not map:has_entities("miniboss_enemy") then
    sol.audio.play_sound("secret")
    sol.audio.play_music(previous_music)
    miniboss_center:remove()
    map:open_doors("miniboss_door")
    game:set_value("dungeon_1_miniboss_clear", true)
  end
end

for enemy in map:get_entities("miniboss_enemy") do
  enemy.on_dead = miniboss_enemy_on_dead
  enemy.on_dying = miniboss_enemy_on_dying
end
