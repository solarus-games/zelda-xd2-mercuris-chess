-- Lua script for Zelda chores.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

-------------------------------------------------------------------------------

local zelda_chores = {}

local all_chores_done_key = "introduction_all_chores_done"
local chore_step_key = "introduction_chore_step"
local chore_done_key = "introduction_chore_done"

local game = sol.main.game

-- Get the chores step.
-- Returns 3 values:
-- (number) chore_step, (boolean) chore_done, (boolean) all_chores_done
function zelda_chores:get_chores_state()

  -- Read savegame file.
  local all_chores_done = game:get_value(all_chores_done_key) or false
  local chore_step = game:get_value(chore_step_key) or 0
  local chore_done = game:get_value(chore_done_key) or false

  return chore_step, chore_done, all_chores_done
end

-- Go to the next chore step.
function zelda_chores:go_to_next_chore_step()

  -- Get chores state.
  local chore_step, chore_done, all_chores_done = zelda_chores:get_chores_state()

  -- All steps have been done at least one time.
  if chore_step == 2 then
    all_chores_done = true
    game:set_value(all_chores_done_key, true)
  end

  -- Next chore.
  chore_step = (chore_step + 1) % 3
  chore_done = false

  -- Write in savegame.
  zelda_chores:set_chores_state(chore_step, chore_done, all_chores_done)
end

-- Modify the state in the savegame file.
function zelda_chores:set_chores_state(chore_step, chore_done, all_chores_done)

  game:set_value(all_chores_done_key, all_chores_done)
  game:set_value(chore_step_key, chore_step)
  game:set_value(chore_done_key, chore_done)

end

-- Validates the current chore but dont go to the next chore.
function zelda_chores:set_chore_done(done)

  -- Get chores state.
  local chore_step, chore_done, all_chores_done = zelda_chores:get_chores_state()

  game:set_value(chore_done_key, done)
end

-------------------------------------------------------------------------------

-- Return
return zelda_chores
