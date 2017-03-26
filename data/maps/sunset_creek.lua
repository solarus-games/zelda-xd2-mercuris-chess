-- Lua script of map sunset_creek.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Overlay surface for changing colors.
local quest_w, quest_h = sol.video.get_quest_size()
local overlay_surface_1 = sol.surface.create(quest_w, quest_h)
overlay_surface_1:fill_color({112, 76, 0})
overlay_surface_1:set_blend_mode("add")

local overlay_surface_2 = sol.surface.create(quest_w, quest_h)
overlay_surface_2:fill_color({255, 155, 197})
overlay_surface_2:set_blend_mode("multiply")

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Call when map needs to be drawn.
function map:on_draw(dst_surface)
   overlay_surface_2:draw(dst_surface)
   overlay_surface_1:draw(dst_surface)
end
