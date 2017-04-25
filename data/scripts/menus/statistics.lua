-- Statistics screen about completing the game.

local statistics_manager = {}

local language_manager = require("scripts/language_manager")

local title_color = { 242, 241, 229 }
local text_color = { 115, 59, 22 }

function statistics_manager:new(game)

  local statistics = {}

  local death_count
  local num_pieces_of_heart
  local max_pieces_of_heart
  local num_items
  local max_items
  local percent
  local tr = sol.language.get_string

  local menu_font, menu_font_size = language_manager:get_menu_font()
  local title_text = sol.text_surface.create{
    horizontal_alignment = "center",
    font = menu_font,
    font_size = menu_font_size,
    color = title_color,
    text_key = "stats_menu.title"
  }
  local background_img = sol.surface.create("menus/selection_menu_background.png")

  local function get_game_time_string()
    return tr("stats_menu.game_time") .. " " .. game:get_time_played_string()
  end

  local function get_death_count_string()
    death_count = game:get_value("death_count") or 0
    return tr("stats_menu.death_count"):gsub("%$v", death_count)
  end

  local function get_pieces_of_heart_string()
    local item = game:get_item("piece_of_heart")
    num_pieces_of_heart = item:get_total_pieces_of_heart()
    max_pieces_of_heart = item:get_max_pieces_of_heart()
    return tr("stats_menu.pieces_of_heart") .. " "  ..
        num_pieces_of_heart .. " / " .. max_pieces_of_heart
  end

  function statistics:on_command_pressed(command)

    local handled = false
    if command == "action" then
      sol.menu.stop(statistics)
      handled = true
    end
    return handled
  end

  function statistics:on_draw(dst_surface)

    background_img:draw(dst_surface, 37, 38)
    title_text:draw(dst_surface, 160, 54)
  end

  return statistics
end

return statistics_manager
