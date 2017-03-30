-- Lua script of map dungeon_1/b2.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local function spike_collision()
  local cam_x, cam_y = map:get_camera():get_position()
  print(cam_x)
  print(cam_y)
  if cam_x >= 1600 and cam_y >= 480 then
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
  if game:get_value("dungeon_1_miniboss_clear") then
    for enemy in map:get_entities("miniboss_enemy") do
      enemy:remove()
    end
  end
end

function map:on_finished()
  -- save rotating platform states
  local rp1_state = map:get_entity("rp_1"):get_state()
  local rp2_state = map:get_entity("rp_2"):get_state()
  game:set_value("dungeon_1_b2_rp1_state", rp1_state)
  game:set_value("dungeon_1_b2_rp2_state", rp2_state)
end

-- mini boss room
function miniboss_sensor:on_activated()
  if not game:get_value("dungeon_1_miniboss_clear") then
    map:close_doors("miniboss_door")
  end
end

local function miniboss_enemy_on_dead()
  if not map:has_entities("miniboss_enemy") and miniboss_door:is_closed() then
    sol.audio.play_sound("secret")
    map:open_doors("miniboss_door")
    game:set_value("dungeon_1_miniboss_clear", true)
  end
end

for enemy in map:get_entities("miniboss_enemy") do
  enemy.on_dead = miniboss_enemy_on_dead
end
