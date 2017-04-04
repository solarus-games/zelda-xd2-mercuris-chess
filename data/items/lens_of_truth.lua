local item = ...
local game = item:get_game()

local sound_timer

local allowed_states = {
  ["free"] = true,
  ["carrying"] = true,
  ["running"] = true,
  ["stream"] = true,
  ["swimming"] = true,
  ["sword loading"] = true,
}

local lens_menu = {}
local lens_active = false

local lens_surface = sol.surface.create("hud/lens_of_truth.png")
lens_surface:set_opacity(128)

function lens_menu:on_draw(dst_surface)
  lens_surface:draw(dst_surface)
end

function item:is_lens_active()
  return lens_active
end

function item:set_lens_active(active)

  lens_active = active
  game:set_magic_decreasing(active)

  if active then

    active = true
    local map = game:get_map()
    sol.menu.start(map, lens_menu, false)
    -- It should be a map menu to avoid ordering issues
    -- with the pause menu or the dialog box.

    game:remove_magic(1)
    sol.timer.start(lens_menu, 1500, function()
      if game:is_suspended() then
        return true
      end
      game:remove_magic(1)
      if game:get_magic() == 0 then
        sol.audio.play_sound("lens_end")
        item:set_lens_active(false)
        return
      end
      return true
    end)

  else
    sol.menu.stop(lens_menu)
    active = false
  end
end

-- Shows an entity only when the lens is active.
function item:update_invisible_entity(entity)

  if item:is_lens_active() and not entity:is_visible() then
    entity:set_visible(true)
  elseif not item:is_lens_active() and entity:is_visible() then
    entity:set_visible(false)
  end

end

-- Shows an entity only when the lens is inactive.
function item:update_fake_entity(entity)

  if item:is_lens_active() and entity:is_visible() then
    entity:set_visible(false)
  elseif not item:is_lens_active() and not entity:is_visible() then
    entity:set_visible(true)
  end

end

function item:on_created()

  item:set_savegame_variable("possession_lens_of_truth")
  item:set_assignable(true)

  -- Allow to start and stop the lens of truth when in water.
  game:register_event("on_command_pressed", function(game, command)

    if game:is_suspended() then
      return
    end

    local lens_command
    local item_1 = game:get_item_assigned(1)
    local item_2 = game:get_item_assigned(2)
    if item_1 ~= nil and item_1:get_name() == "lens_of_truth" then
      lens_command = "item_1"
    elseif item_2 ~= nil and item_2:get_name() == "lens_of_truth" then
      lens_command = "item_2"
    end

    if lens_command == nil then
      return
    end

    if command ~= lens_command then
      return
    end

    local state = game:get_hero():get_state()
    if allowed_states[state] == nil then
      return
    end

    if item:is_lens_active() then
      sol.audio.play_sound("lens_end")
      item:set_lens_active(false)
      return true  -- Stop the propagation of the event.
    end

    if game:get_magic() <= 0 then
      if sound_timer == nil then
        sol.audio.play_sound("wrong")
        sound_timer = sol.timer.start(game, 500, function()
          sound_timer = nil
        end)
      end
      return true  -- Stop the propagation of the event.
    end

    sol.audio.play_sound("lens_start")
    item:set_lens_active(true)
    return true  -- Stop the propagation of the event.
  end)
end

function item:on_obtained(variant, savegame_variable)

  -- Give the magic bar if necessary.
  local magic_bar = game:get_item("magic_bar")
  if not magic_bar:has_variant() then
    magic_bar:set_variant(1)
  end
end

function item:on_map_changed(map)

  -- Keep the lens of truth active accross maps.
  if item:is_lens_active() then
    item:set_lens_active(false)
  end
end
