-- Lua script of map final_scene.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

local sunset_effect = require("scripts/maps/sunset_effect")
-- Cinematic black lines
local black_stripe = nil

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- Hide or show HUD.
  game:set_hud_enabled(false)

  -- Prevent or allow the player from pausing the game
  game:set_pause_allowed(false)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

  -- Freeze hero
  local hero = map:get_hero()
  hero:freeze()

end

function map:on_draw(dst_surface)
  sunset_effect:draw(dst_surface)
  map:draw_cinematic_stripes(dst_surface)
end


-- Draw the cinematic black stripes
function map:draw_cinematic_stripes(dst_surface)
  if black_stripe == nil then
    local quest_w, quest_h = sol.video.get_quest_size()
    black_stripe = sol.surface.create(quest_w, 24)
    black_stripe:fill_color({0, 0, 0})
  end
  
  black_stripe:draw(dst_surface, 0, 0)
  black_stripe:draw(dst_surface, 0, 216)
end