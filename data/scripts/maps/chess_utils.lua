-- Provides useful functions to implement chess puzzles.

local chess_utils = {}

-- Returns the type of chess piece of an entity or nil.
function chess_utils:get_piece_type(entity)

  local sprite = entity:get_sprite()
  if sprite == nil then
    return
  end

  return sprite:get_animation_set():match("enemies/chess/([a-z]*)_")
end

-- Returns whether an entity is in the range of a knight.
function chess_utils:is_controlled_by_knight(entity, knight)

  local x1, y1 = entity:get_position()
  local x2, y2 = knight:get_position()

  local dx = math.abs(x2 - x1)
  local dy = math.abs(y2 - y1)

  return (dx == 16 and dy == 32) or (dx == 32 and dy == 16)

end

-- Returns whether an entity is in the range of a rook.
function chess_utils:is_controlled_by_rook(entity, rook)

  local x1, y1 = entity:get_position()
  local x2, y2 = rook:get_position()

  return x1 == x2 or y1 == y2
end

local is_controlled_predicates = {
  knight = chess_utils.is_controlled_by_knight,
  rook = chess_utils.is_controlled_by_rook,
}

-- Returns whether an entity is in the range of the given chess piece.
function chess_utils:is_controlled_by_piece(entity, piece)

  local x, y = entity:get_bounding_box()
  if x % 8 ~= 0 or y % 8 ~= 0 then
    return 0
  end

  x, y = piece:get_bounding_box()
  if x % 8 ~= 0 or y % 8 ~= 0 then
    return 0
  end

  local piece_type = chess_utils:get_piece_type(piece)
  return is_controlled_predicates[piece_type](chess_utils, entity, piece)
end

-- Returns how many pieces with the given prefix
-- control an entity.
function chess_utils:get_num_pieces_controlling(entity, prefix)

  local map = entity:get_map()

  local x, y = entity:get_bounding_box()
  if x % 8 ~= 0 or y % 8 ~= 0 then
    return 0
  end

  local count = 0
  for other in map:get_entities(prefix) do
    if other ~= entity then
      if chess_utils:is_controlled_by_piece(entity, other) then
        count = count + 1
      end
    end
  end

  return count
end

return chess_utils
