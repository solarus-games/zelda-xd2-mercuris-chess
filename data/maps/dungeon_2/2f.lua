local map = ...
local game = map:get_game()

local separator_manager = require("scripts/maps/separator_manager")
separator_manager:manage_map(map)
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)

local elevator_manager = require("scripts/maps/elevator_manager")
elevator_manager:create_elevator(map, "elevator_a", 0, 3)
elevator_manager:create_elevator(map, "elevator_b", 0, 8, "vip_card")

local slot_machine_manager = require("scripts/maps/slot_machine_manager")
slot_machine_manager:create_slot_machine(map, "slot_machine_a")
slot_machine_manager:create_slot_machine(map, "slot_machine_b")
slot_machine_manager:create_slot_machine(map, "slot_machine_c")

local chest_game_manager = require("scripts/maps/chest_game_manager")
local chest_game_rewards = {
  { "rupee", 1 },
  { "rupee", 2 },
  { "rupee", 3 },
  { "rupee", 4 },
  { "heart", 1 },
  { "heart", 1 },
  { "creeper", 1 },
  { "creeper", 1 },
  { "creeper", 1 },
  { "creeper", 1 },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
  { "small_key_brandished", 1, "dungeon_2_2f_chest_game_key" },
}
chest_game_manager:create_chest_game(map, "chest_game", 20, chest_game_rewards)

local vegas_enemies = {}

function map:on_started()

  -- Walking NPCs.
  local movement = sol.movement.create("random_path")
  movement:start(blue_haired_boy)
  movement = sol.movement.create("random_path")
  movement:start(green_hat_man)

  -- VIP card chest.
  if game:get_value("dungeon_2_2f_vip_card_chest_appeared") then
    ne_chest_switch:set_activated(true)
  else
    ne_chest:set_enabled(false)
  end

  n_fake_chest_for_compass_only:set_enabled(false)

end

function ne_chest_switch:on_activated()

  sol.audio.play_sound("chest_appears")
  ne_chest:set_enabled(true)
  game:set_value("dungeon_2_2f_vip_card_chest_appeared", true)
end

-- Cards enemy game.
local function vegas_on_immobilized(enemy)

  local direction = enemy:get_sprite():get_direction()
  local all_immobilized = true
  local all_same_direction = true
  for _, vegas in ipairs(vegas_enemies) do
    local sprite = vegas:get_sprite()
    if not vegas:is_symbol_fixed() then
      all_immobilized = false
    end
    if vegas:get_sprite():get_direction() ~= direction then
      all_same_direction = false
    end
  end

  if not all_immobilized then
    return
  end

  sol.timer.start(map, 500, function()

    if not all_same_direction then
      sol.audio.play_sound("wrong")
      for _, vegas in ipairs(vegas_enemies) do
        vegas:set_symbol_fixed(false)
      end
      return
    end

    -- Give the reward.
    if vegas_pickable == nil then
      sol.audio.play_sound("secret")
      local treasure_name, treasure_variant, treasure_savegame_variable = "small_key_brandished", 1, "dungeon_2_2f_vegas_key"
      if game:get_value(treasure_savegame_variable) then
        -- Already got the small key: give rupees instead.
        treasure_name, treasure_variant, treasure_savegame_variable = "rupee", 3, nil
      end
      local x, y, layer = vegas_reward_placeholder:get_position()
      map:create_pickable({
        name = "vegas_pickable",
        x = x,
        y = y,
        layer = layer,
        treasure_name = treasure_name,
        treasure_variant = treasure_variant,
        treasure_savegame_variable = treasure_savegame_variable,
      })
    end

    -- Kill them.
    for _, vegas in ipairs(vegas_enemies) do
      vegas:set_life(0)
    end

  end)

end

-- Sets up the Vegas card enemies game.
-- Needs to be called whenever the hero enters the room
-- (enemies are re-created when traversing separators).
local function initialize_vegas()
  vegas_enemies = {}
  if auto_enemy_vegas_1 == nil then
    -- Already dead.
    return
  end
  if auto_enemy_vegas_1.on_immobilized ~= nil then
    -- Already initialized.
    return
  end

  for vegas in map:get_entities("auto_enemy_vegas") do
    vegas.on_symbol_fixed = vegas_on_immobilized
    vegas_enemies[#vegas_enemies + 1] = vegas
  end
end

for vegas_room_sensor in map:get_entities("vegas_room_sensor") do
  vegas_room_sensor.on_activated = initialize_vegas
end

