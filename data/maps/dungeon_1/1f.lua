-- Lua script of map dungeon_1/1f.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local water_delay = 500

local boss = nil

function map:create_fake_heart_container()

  local fake_heart_container
  if hero:get_distance(fake_heart_container_1) > hero:get_distance(fake_heart_container_2) then
    fake_heart_container = fake_heart_container_1
  else
    fake_heart_container = fake_heart_container_2
  end
  fake_heart_container:set_drawn_in_y_order(true)
  fake_heart_container:set_enabled(true)
  local heart_container_sprite = fake_heart_container:create_sprite("entities/items")
  heart_container_sprite:set_animation("heart_container")
  sol.timer.start(map, 10, function()
    if hero:get_distance(fake_heart_container) > 32 then
      return true  -- Wait for the hero to get close.
    end
    
    hero:freeze()
    sol.audio.play_sound("enemy_awake")
    map:get_camera():shake()
    sol.timer.start(map, 500, function()
      sol.audio.play_sound("jump")
    end)
    local hand_sprite = heart_container_hand:get_sprite()
    hand_sprite:set_animation("closed")
    local movement = sol.movement.create("target")
    movement:set_target(fake_heart_container)
    movement:set_speed(192)
    movement:set_ignore_obstacles(true)
    movement:start(heart_container_hand, function()
      hand_sprite:set_animation("closed")
      sol.timer.start(map, 1500, function()
        local movement = sol.movement.create("straight")
        movement:set_angle(math.pi / 2)
        movement:set_speed(192)
        movement:set_max_distance(180)
        movement:set_ignore_obstacles(true)
        function heart_container_hand:on_position_changed()
          local x, y, layer = heart_container_hand:get_position()
          layer = layer - 1
          fake_heart_container:set_position(x, y, layer)
        end
        movement:start(heart_container_hand, function()
          heart_container_hand:set_enabled(false)
          fake_heart_container:set_enabled(false)

          sol.audio.play_music("alttp/victory")
          hero:set_direction(3)
          sol.timer.start(9000, function()
            sol.audio.play_sound("secret")
            map:open_doors("boss_door")
            game:set_value("dungeon_1_fake_heart_container_disappeared", true)
            hero:start_victory(function()
              hero:unfreeze()
            end)
          end)
        end)
      end)
    end)
  end)
end

function map:create_chicken_boss()
  -- Do not create boss if already dead.
  if game:get_value("dungeon_1_boss") then
    return
  end
  -- Close doors.
  map:close_doors("boss_door")

  -- Play boss music.
  sol.audio.play_music("alttp/ganon_appears", function()
    sol.audio.play_music("alttp/boss", true)
  end)

  -- Create boss.
  local dst = map:get_entity("boss_starting_point")
  local x, y, layer = dst:get_position()
  local prop = {x = x, y = y, layer = layer + 1, direction = 3,
    breed = "oclero/chicken_giant", name = "boss",
    savegame_variable = "dungeon_1_boss"}
  boss = map:create_enemy(prop)

  -- Put the boss on the correct layer only after some time
  -- so that he appears above the north tiles.
  sol.timer.start(boss, 1000, function()
    local x, y, layer = boss:get_position()
    boss:set_position(x, y, layer - 1)
  end)
  
  function boss:on_dead()

    -- Remove all smaller enemies.
    for enemy in map:get_entities_by_type("enemy") do
      enemy:remove()
    end

    -- Create a heart container but removing it with a falling hand
    -- when the hero gets close.
    map:create_fake_heart_container()
    game:set_dungeon_finished(1)
  end
end

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  map:set_doors_open("boss_door")
  map:add_pillar_collision_test()
  pool_switch_empty:set_activated(true)

  library_door:get_sprite():set_xy(16, 0)  -- Trick to show a fake door where we want without creating an obstacle there.
  west_fake_door:get_sprite():set_xy(0, 16)

  fake_heart_container_1:set_enabled(false)
  fake_heart_container_2:set_enabled(false)

  if game:get_value("dungeon_1_boss") then
    if not game:get_value("dungeon_1_fake_heart_container_disappeared") then
      map:create_fake_heart_container()
    end
    map:set_entities_enabled("pillar_", false)
  end
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished(destination)
  if destination == from_outside then
    game:start_dialog("dungeon_1.welcome")
  end
end

function mario_voice_1:on_interaction()
  sol.audio.play_sound("mk64_mario_yeah")
end

function mario_voice_2:on_interaction()
  sol.audio.play_sound("sm64_heehee")
end

function mario_voice_3:on_interaction()
  sol.audio.play_sound("sm64_memario")
end

function mario_switch_1:on_activated()
  map:get_entity("mario_reset_switch"):set_activated(false)
end

function mario_switch_2:on_activated()
  map:get_entity("mario_reset_switch"):set_activated(false)
end

function mario_switch_3:on_activated()
  map:get_entity("mario_reset_switch"):set_activated(false)
end

function mario_reset_switch:on_activated()
  local switches = map:get_entities("mario_switch")
  for switch in switches do
    switch:set_activated(false)
  end
end

-- Pool fill switch mechanism
-- The switch fills up the champagne swimming pool
function pool_switch_fill:on_activated()
  pool_switch_empty:set_activated(false);
  sol.audio.play_sound("water_fill_begin")
  sol.audio.play_sound("water_fill")
  local water_tile_index = 5
  sol.timer.start(water_delay, function()
    local next_tile = map:get_entity("pool_" .. water_tile_index)
    local previous_tile = map:get_entity("pool_" .. water_tile_index + 1)
    if next_tile == nil then
      return false
    end
    next_tile:set_enabled(true)
    if previous_tile ~= nil then
      previous_tile:set_enabled(false)
    end
    water_tile_index = water_tile_index - 1
    return true
  end)
end

-- Pool empty switch mechanism
-- The switch drains the champagne swimming pool
function pool_switch_empty:on_activated()
  pool_switch_fill:set_activated(false);
  sol.audio.play_sound("water_drain_begin")
  sol.audio.play_sound("water_drain")
  local water_tile_index = 1
  sol.timer.start(water_delay, function()
    print(water_tile_index)
    local next_tile = map:get_entity("pool_" .. water_tile_index + 1)
    local previous_tile = map:get_entity("pool_" .. water_tile_index)
    if next_tile ~= nil then    
      next_tile:set_enabled(true)
    end
    if previous_tile ~= nil then
      previous_tile:set_enabled(false)
    end
    water_tile_index = water_tile_index + 1
    if next_tile == nil then
      return false
    end
    return true
  end)
end

-- Library Labyrinth
local function timer_finished()
  map:close_doors("library_door")
  map:get_entity("library_door_switch"):set_activated(false)
end

local old_man_blocks = true

local function old_man_moves_quickly()
  if not old_man_blocks then
    local movement = sol.movement.create("path")
    movement:set_speed(50)
    movement:set_path{4,4,4,4,2,2,2,2,2,2,4,4,4,4}
    local old_man = map:get_entity("library_old_man") 
    movement:start(old_man)
    sol.audio.play_sound("metallizer/trolololol")
  end
end

function library_door_switch:on_activated()
  map:open_doors("library_door")
  local timer = sol.timer.start(map, 5000, timer_finished)
  timer:set_with_sound(true)
  old_man_moves_quickly()
  old_man_blocks = true
end

function sensor_old_man_move_back:on_activated()
  map:get_entity("library_old_man"):set_position(1768, 349)
  old_man_blocks = true
end

function sensor_old_man_move_away:on_activated()
  map:get_entity("library_old_man"):set_position(1832, 397)
  old_man_blocks = false
end

-- River switch mechanism
-- The switch fills up the champagne river (yummy!)
function river_switch:on_activated()
  sol.audio.play_sound("water_drain_begin")
  sol.audio.play_sound("water_drain")
  local water_tile_index = 1
  sol.timer.start(water_delay, function()
    local next_tiles = map:get_entities("animated_river_" .. water_tile_index + 1)
    local previous_tiles = map:get_entities("animated_river_" .. water_tile_index)
    if next_tiles == nil then
      return false
    end
    for tile in next_tiles do
      tile:set_enabled(true)
    end
    for tile in previous_tiles do
      tile:set_enabled(false)
    end
    water_tile_index = water_tile_index + 1
    return true
  end)
  for tile in map:get_entities("static_river_") do
    tile:set_enabled(false)
  end
end

local pillar_count = 4

local function destroy_pillar(number)

  local pillar = map:get_entity("pillar_" .. number)
  local pillar_base = map:get_entity("pillar_base_" .. number)
  if pillar_base == nil then
    return  -- Already destroyed.
  end

  pillar_count = pillar_count - 1
  if pillar_count == 0 then
    -- Make sure the iron ball won't block the boss or the hero.
    for e in map:get_entities() do
      local sprite = e:get_sprite()
      if sprite and sprite:get_animation_set() == "portables/iron_ball" then
        e:remove()
      end
    end
  end

  local x, y, layer = pillar:get_position()

  sol.audio.play_sound("explosion")
  map:create_explosion({x = x, y = y + 16, layer = layer})
  sol.timer.start(water_delay, function()
    sol.audio.play_sound("explosion")
    map:create_explosion({x = x, y = y + 16, layer = layer})
    sol.timer.start(water_delay, function()
      sol.audio.play_sound("explosion")
      map:create_explosion({x = x, y = y + 16, layer = layer})
    end)
  end)

  map:remove_entities("pillar_base_" .. number)
  map:remove_entities("pillar_wall_" .. number)
  hero:freeze()

  pillar:get_sprite():set_animation("destroy", function() 
    pillar:remove()
    hero:unfreeze()

    if pillar_count == 0 then
      map:create_chicken_boss()
    end
  end)
end

function map:add_pillar_collision_test()
  local iron_ball_sprite = "portables/iron_ball"
  for i = 1, 4 do
    local pillar = map:get_entity("pillar_base_" .. i)
    if pillar ~= nil then
      pillar:add_collision_test("touching", function(pillar, object)
        local sprite = object:get_sprite()
        if object:get_type() == "custom_entity" -- Do not break columns while carrying.
        and sprite and sprite:get_animation_set() == iron_ball_sprite then
          destroy_pillar("" .. i)
        end
      end)
    end
  end
end
