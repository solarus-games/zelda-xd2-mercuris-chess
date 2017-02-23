local item = ...
local game = item:get_game()

local message_id = {
  "found_piece_of_heart.first",
  "found_piece_of_heart.second",
  "found_piece_of_heart.third",
  "found_piece_of_heart.fourth"
}
-- Returns the current number of pieces of heart between 0 and 3.
function item:get_num_pieces_of_heart()

  return game:get_value("num_pieces_of_heart") or 0
end

-- Returns the total number of pieces of hearts already found.
function item:get_total_pieces_of_heart()

  return game:get_value("total_pieces_of_heart") or 0
end

-- Returns the number of pieces of hearts existing in the game.
function item:get_max_pieces_of_heart()

  -- TODO
  return 36
end


function item:on_created()

  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished("piece_of_heart")
end

function item:on_obtained(variant)

  local num_pieces_of_heart = item:get_num_pieces_of_heart()

  local nb_pieces_of_heart = game:get_value("i1030") or 0
  game:start_dialog(message_id[num_pieces_of_heart + 1], function()

    game:set_value("num_pieces_of_heart", (num_pieces_of_heart + 1) % 4)
    game:set_value("total_pieces_of_heart", item:get_total_pieces_of_heart() + 1)
    if num_pieces_of_heart == 3 then
      game:add_max_life(4)
    end
    game:set_life(game:get_max_life())
  end)
end

