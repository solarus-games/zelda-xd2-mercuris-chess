local item = ...
local game = ...

function item:on_created()

  self:set_savegame_variable("possession_pegasus_shoes")
  self:set_assignable(true)

  -- TODO only if shoelaces
  game:set_ability("run", 1)
end

function item:on_using()

-- TODO
--  local hero = self:get_map():get_entity("hero")
--  hero:set_direction(math.random(0, 3))
  hero:start_running()
  self:set_finished()
end

function item:on_variant_changed(variant)

  -- TODO only if shoelaces
  game:set_ability("run", variant)
end

