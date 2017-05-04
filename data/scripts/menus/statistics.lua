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

  local title_text = sol.text_surface.create({
    horizontal_alignment = "center",
    font = menu_font,
    font_size = menu_font_size,
    color = title_color,
    text_key = "stats_menu.title",
  })
  title_text:set_xy(160, 54)

  local background_img = sol.surface.create("menus/selection_menu_background.png")
  background_img:set_xy(37, 38)

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

  local function get_hearts_string()

    local max_hearts = 20
    local num_hearts = math.floor(game:get_max_life() / 4)
    return tr("stats_menu.hearts") .. " "  ..
        num_hearts .. " / " .. max_hearts
  end

  local function get_treasures_string()

    local max_treasures = 20  -- TODO
    local num_treasures = 0  -- TODO
    return tr("stats_menu.treasures") .. " "  ..
        num_treasures .. " / " .. max_treasures
  end

  local function get_percent_string()

    local percent = 0  -- TODO
    return tr("stats_menu.percent"):gsub("$v", percent)
  end

  local time_played_text = sol.text_surface.create({
    font = menu_font,
    font_size = menu_font_size,
    color = text_color,
    text = get_game_time_string(),
  })
  time_played_text:set_xy(45, 75)

  local death_count_text = sol.text_surface.create({
    font = menu_font,
    font_size = menu_font_size,
    color = text_color,
    text = get_death_count_string(),
  })
  death_count_text:set_xy(45, 95)

  local pieces_of_heart_text = sol.text_surface.create({
    font = menu_font,
    font_size = menu_font_size,
    color = text_color,
    text = get_pieces_of_heart_string(),
  })
  pieces_of_heart_text:set_xy(45, 115)

  local hearts_text = sol.text_surface.create({
    font = menu_font,
    font_size = menu_font_size,
    color = text_color,
    text = get_hearts_string(),
  })
  hearts_text:set_xy(45, 135)

  local treasures_text = sol.text_surface.create({
    font = menu_font,
    font_size = menu_font_size,
    color = text_color,
    text = get_treasures_string(),
  })
  treasures_text:set_xy(45, 155)

  local percent_text = sol.text_surface.create({
    font = menu_font,
    font_size = menu_font_size,
    color = text_color,
    text = get_percent_string(),
  })
  percent_text:set_xy(45, 175)

  function statistics:on_command_pressed(command)

    local handled = false
    if command == "action" then
      sol.menu.stop(statistics)
      handled = true
    end
    return handled
  end

  function statistics:on_draw(dst_surface)

    background_img:draw(dst_surface)
    title_text:draw(dst_surface)
    time_played_text:draw(dst_surface)
    death_count_text:draw(dst_surface)
    pieces_of_heart_text:draw(dst_surface)
    hearts_text:draw(dst_surface)
    treasures_text:draw(dst_surface)
    percent_text:draw(dst_surface)
  end

  return statistics
end

return statistics_manager
