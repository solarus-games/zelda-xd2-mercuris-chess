-- Provides useful functions to implement chess puzzles.

local chess_utils = {}

-- Returns whether an entity is in the range of a knight.
function chess_utils:is_controlled_by_knight(entity, knight)

  local x1, y1 = entity:get_position()
  local x2, y2 = knight:get_position()

  local dx = math.abs(x2 - x1)
  local dy = math.abs(y2 - y1)

  return (dx == 16 and dy == 32) or (dx == 32 and dy == 16)

end

-- Returns how many knights with the given prefix
-- control an entity.
function chess_utils:get_num_knights_controlling(entity, prefix)

  local map = entity:get_map()
  local count = 0
  for other in map:get_entities(prefix) do
    if other ~= entity then
      if chess_utils:is_controlled_by_knight(entity, other) then
        count = count + 1
      end
    end
  end

  return count
end

-- Returns whether an entity is in the range of a rook.
function chess_utils:is_controlled_by_rook(entity, rook)

  local x1, y1 = entity:get_position()
  local x2, y2 = rook:get_position()

  return x1 == x2 or x2 == y2
end

-- Returns how many rooks with the given prefix
-- control an entity.
-- TODO factorize with get_num_knights_controlling()
function chess_utils:get_num_rooks_controlling(entity, prefix)

  local map = entity:get_map()
  local count = 0
  for other in map:get_entities(prefix) do
    if other ~= entity then
      if chess_utils:is_controlled_by_rook(entity, other) then
        count = count + 1
      end
    end
  end

  return count
end

return chess_utils
