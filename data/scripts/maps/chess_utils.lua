-- Provides useful functions to implement chess puzzles.

local chess_utils = {}

-- Returns whether two 16x16 entities are at knight distance.
function chess_utils:is_at_knight_distance(entity_1, entity_2)

  local x1, y1 = entity_1:get_position()
  local x2, y2 = entity_2:get_position()

  local dx = math.abs(x2 - x1)
  local dy = math.abs(y2 - y1)

  return (dx == 16 and dy == 32) or (dx == 32 and dy == 16)

end

return chess_utils
