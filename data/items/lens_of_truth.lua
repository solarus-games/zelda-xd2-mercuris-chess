local item = ...
local game = item:get_game()

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

    sol.audio.play_sound("lens_start")
    active = true
    local map = game:get_map()
    sol.menu.start(map, lens_menu, false)
    -- It should be a map menu to avoid ordering issues
    -- with the pause menu or the dialog box.

    game:remove_magic(1)
    sol.timer.start(lens_menu, 1500, function()
      game:remove_magic(1)
      if game:get_magic() == 0 then
        item:set_lens_active(false)
        return
      end
      return true
    end)

  else
    sol.audio.play_sound("lens_end")
    sol.menu.stop(lens_menu)
    active = false
  end
end

function item:on_created()

  item:set_savegame_variable("possession_lens_of_truth")
  item:set_assignable(true)
end

function item:on_obtained(variant, savegame_variable)

  -- Give the magic bar if necessary.
  local magic_bar = game:get_item("magic_bar")
  if not magic_bar:has_variant() then
    magic_bar:set_variant(1)
  end
end

function item:on_using()

  if item:is_lens_active() then
    item:set_lens_active(false)
    item:set_finished()
    return
  end

  if game:get_magic() <= 0 then
    sol.audio.play_sound("wrong")
    item:set_finished()
    return
  end

  item:set_lens_active(true)
  item:set_finished()
end

function item:on_map_changed(map)

  -- Keep the lens of truth active accross maps.
  if item:is_lens_active() then
    sol.menu.start(map, lens_menu, false)
  end
end
