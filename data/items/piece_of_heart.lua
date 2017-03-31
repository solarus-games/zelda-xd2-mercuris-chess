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

  return 40
end


function item:on_created()

  item:set_sound_when_picked(nil)
  item:set_sound_when_brandished("piece_of_heart")
end

function item:on_obtained(variant)

  local num_pieces_of_heart = item:get_num_pieces_of_heart()

  game:start_dialog(message_id[num_pieces_of_heart + 1], function()

    game:set_value("num_pieces_of_heart", (num_pieces_of_heart + 1) % 4)
    game:set_value("total_pieces_of_heart", item:get_total_pieces_of_heart() + 1)
    if num_pieces_of_heart == 3 then
      game:add_max_life(4)
    end
    game:set_life(game:get_max_life())
  end)
end

-- 4 hearts initially (9 and then 4 because of Zelda).

-- 10 hearts from 40 pieces of hearts:
-- - 5 in Dungeon 2
-- - 28 in Pieces of heart cave
-- - 1 in Lost and Found Office
-- - 6 in outside world (1 per map, needs lens of truth)

-- 6 heart containers:
-- - 5 in the main village shop.
-- - 1 in the library.

-- Total: 20 hearts.