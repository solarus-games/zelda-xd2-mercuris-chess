-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/doc/latest

require("scripts/features")
local game_manager = require("scripts/game_manager")
local solarus_logo = require("scripts/menus/solarus_logo")
local team_logo = require("scripts/menus/team_logo")

-- TODO
-- local language_menu = require("scripts/menus/language")
-- local title_screen = require("scripts/menus/title_screen")
-- local savegames_menu = require("scripts/menus/savegames")

local pre_game_menus = {
  solarus_logo,
  team_logo,
}

-- This function is called when Solarus starts.
function sol.main:on_started()

  -- Setting a language is useful to display text and dialogs.
  sol.language.set_language("fr")

  -- Show the initial menus.
  sol.menu.start(self, pre_game_menus[1])
  for i, menu in ipairs(pre_game_menus) do
    function menu:on_finished()
      if sol.main.game ~= nil then
        -- A game is already running (probably quick start with a debug key).
        return
      end
      local next_menu = pre_game_menus[i + 1]
      if next_menu ~= nil then
        sol.menu.start(sol.main, next_menu)
      end
    end
  end

end

-- Event called when the player pressed a keyboard key.
function sol.main:on_key_pressed(key, modifiers)

  local handled = false
  if key == "f5" then
    -- F5: change the video mode.
    sol.video.switch_mode()
    handled = true
  elseif key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.game == nil then
    -- Escape in title screens: stop the program.
    sol.main.exit()
    handled = true
  end

  return handled
end

-- Starts a game.
function sol.main:start_savegame(game)

  -- Skip initial menus if any.
  for _, menu in ipairs(pre_game_menus) do
    sol.menu.stop(menu)
  end

  sol.main.game = game
  game:start()
end
