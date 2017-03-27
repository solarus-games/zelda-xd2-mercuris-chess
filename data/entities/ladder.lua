-- Sets the ground below it to "ladder".
-- Useful if tiles don't have the appropriate ground.

local entity = ...

function entity:on_created()
  entity:set_modified_ground("ladder")
end
