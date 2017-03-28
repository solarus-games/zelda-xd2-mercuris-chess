local item = ...
local game = item:get_game()

local lens_menu = {}
local active = false

local lens_surface = sol.surface.create("hud/lens_of_truth.png")
lens_surface:set_opacity(128)

function lens_menu:on_draw(dst_surface)
  dst_surface:draw(lens_surface)
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

  if sol.menu.is_started(lens_menu) then
    sol.audio.play_sound("lens_end")
    sol.menu.stop(lens_menu)
    item:set_finished()
    return
  end

  if game:get_magic() <= 0 then
    sol.audio.play_sound("wrong")
    item:set_finished()
    return
  end

  sol.audio.play_sound("lens_start")
  sol.menu.start(game, lens_menu, false)

  -- TODO remove magic

  item:set_finished()
end
