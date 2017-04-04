-- Title screen of the game.
-----------------------------------------------------------------

local title_screen = {}

-- Get font information.
local language_manager = require("scripts/language_manager")
local menu_font, menu_font_size = language_manager:get_menu_font()

-- Animation steps.
local NO_STATE, BLACK_SCREEN, FINAL, FADE_OUT = 0, 1, 2, 3

-----------------------------------------------------------------

-- Change the phase of this menu.
function title_screen:go_to_phase(phase)

  -- Phase BLACK_SCREEN:
  -- A black screen before showing something.
  if phase == BLACK_SCREEN then
    title_screen:phase_black_screen()

  -- Phase FINAL:
  -- Display everything.
  elseif phase == FINAL then
    title_screen:phase_final()

  -- Phase FADE_OUT:
  -- Simple fade-out
  elseif phase == FADE_OUT then
    title_screen:phase_fadeout()
  end

end

-- Start the phase where nothing is displayed.
function title_screen:phase_black_screen()
  self.phase = BLACK_SCREEN
  self.allow_skip = false

 -- Black screen during a small delay,
 -- then go to next phase.
  sol.timer.start(self, 200, function()
      self:go_to_phase(BLACK_SCREEN + 1)
  end)
end

-- Start the phase where the title is displayed.
-- Load all the necessary images and texts.
function title_screen:phase_final()
  -- Step
  self.phase = FINAL

  -- Start music.
  sol.audio.play_music("doctor_octoroc/demons_run")

  -- Create the surface where we draw.
  local surface_w = 320
  local surface_h = 240
  self.surface = sol.surface.create(surface_w, surface_h)

  -- Create background image.
  self.background_img = sol.surface.create("menus/title_screen/title_background.png")

  -- Create clouds images.
  self.cloud_img_1 = sol.surface.create("menus/title_screen/title_cloud_1.png")
  self.cloud_img_2 = sol.surface.create("menus/title_screen/title_cloud_2.png")
  self.cloud_img_3 = sol.surface.create("menus/title_screen/title_cloud_3.png")
  self.cloud_shapes = {
    self.cloud_img_1,
    self.cloud_img_2,
    self.cloud_img_3,
  }

  self.clouds_full_width = 480
  self.clouds_foreground = {
    { shape = 1,
      x = 2,
      y = 120,
    },
    { shape = 1,
      x = 160,
      y = 142,
    },
    { shape = 1,
      x = 480,
      y = 166,
    },
    { shape = 2,
      x = -18,
      y = 190,
    },
    { shape = 2,
      x = 220,
      y = 220,
    },
    { shape = 2,
      x = 520,
      y = 203,
    },
  }

  self.clouds_background = {
    { shape = 3,
      x = -4,
      y = 152,
    },
    { shape = 3,
      x = 112,
      y = 178,
    },
    { shape = 3,
      x = 162,
      y = 150,
    },
    { shape = 3,
      x = 196,
      y = 190,
    },
  }

  -- Create the cinematic black stripe.
  local black_stripe_height = 24
  self.black_stripes = sol.surface.create(surface_w, surface_h)
  self.black_stripes:fill_color(
    {0, 0, 0},
    0, 0,
    surface_w, black_stripe_height)
  self.black_stripes:fill_color(
    {0, 0, 0},
    0, surface_h - black_stripe_height,
    surface_w, black_stripe_height)

  -- Create logo image.
  self.logo_img = sol.surface.create("menus/title_screen/title_logo.png")
  local logo_w, logo_h = self.logo_img:get_size()
  self.logo_img:set_xy((surface_w - logo_w) / 2, 6)

  -- Create Mr Grump image.
  self.grump_img = sol.surface.create("menus/title_screen/title_grump.png")
  self.grump_img:set_xy(125, 93)

  -- Make Mr Grump laugh (shake him on the Y axis)
  self.grump_moved = false

  function switch_grump_moved()
    self.grump_moved = not self.grump_moved
    sol.timer.start(self, 180, switch_grump_moved)
  end

  switch_grump_moved()

  -- Create all texts
  self.copyright_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = {255, 255, 255},
    font = menu_font,
    font_size = menu_font_size,
    text_key = "title_screen.copyright",
  }
  self.press_space_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = "alttp",
    font_size = 16,
    text_key = "title_screen.press_space",
  }

  -- Make the "Press space" text clip every 500ms.
  self.show_press_space = false

  function switch_press_space()
    self.show_press_space = not self.show_press_space
    sol.timer.start(self, 500, switch_press_space)
  end
  switch_press_space()

  -- Make the clouds move.
  function move_foreground_clouds()
    -- Move all the clouds.
    for _, cloud in ipairs(self.clouds_foreground) do
      cloud.x = cloud.x + 1
      if cloud.x > self.clouds_full_width then
        cloud.x = -self.clouds_full_width / 2
      end
    end

    -- Repeat.
    sol.timer.start(self, 60, move_foreground_clouds)
  end

  sol.timer.start(self, 60, move_foreground_clouds)

  function move_background_clouds()
    -- Move all the clouds.
    for _, cloud in ipairs(self.clouds_background) do
      cloud.x = cloud.x + 1
      if cloud.x > self.clouds_full_width then
        cloud.x = -self.clouds_full_width / 2
      end
    end

    -- Repeat.
    sol.timer.start(self, 120, move_background_clouds)
  end

  sol.timer.start(self, 120, move_background_clouds)

  -- Show an opening transition.
  self.surface:fade_in(30)

  -- Allow to skip the menu after a delay.
  self.allow_skip = false
  sol.timer.start(self, 500, function()
    self.allow_skip = true
  end)
end

-- Fade-out then quit
function title_screen:phase_fadeout()
  -- Step
  self.phase = FADE_OUT

  -- Create troll image.
  self.troll_img = sol.surface.create("menus/title_screen/title_troll.png")

  -- Move the troll image.
  self.troll_image_y = 216
  function move_troll_face()
    self.troll_image_y = self.troll_image_y - 1
    if self.troll_image_y > 187 then
      sol.timer.start(self, 40, move_troll_face)
    end
  end
  move_troll_face()

  --All of this while fading out.
  self.surface:fade_out(60, function()
    sol.timer.start(self, 250, function()
      self:skip_menu()
    end)
  end)
end

-----------------------------------------------------------------

-- Update the surface.
function title_screen:update_surface()

  self.surface:fill_color({0, 0, 0})

  -- Draw the background.
  if self.background_img then
    self.background_img:draw(self.surface)
  end

  -- Draw the clouds.
  for _, cloud in ipairs(self.clouds_background) do
    self.cloud_shapes[cloud.shape]:draw(self.surface, cloud.x, cloud.y)
  end
  for _, cloud in ipairs(self.clouds_foreground) do
    self.cloud_shapes[cloud.shape]:draw(self.surface, cloud.x, cloud.y)
  end

  -- Draw Mr Grump.
  if self.grump_img then
    local grump_y = 0
    if self.grump_moved then
      grump_y = 1
    end

    self.grump_img:draw(self.surface, 0, grump_y)
  end

  -- Draw the Troll face.
  if self.troll_img and self.phase == FADE_OUT then
    self.troll_img:draw(self.surface, 26, self.troll_image_y)
  end

  -- Draw the cinematic black stripes.
  if self.black_stripes then
    self.black_stripes:draw(self.surface)
  end

  -- Draw the copyright text.
  if self.copyright_text then
    self.copyright_text:draw(self.surface, 160, 227)
  end

  -- Draw the logo.
  if self.logo_img then
    self.logo_img:draw(self.surface)
  end

  -- Draw the "Press Space" text.
  if self.show_press_space and self.phase == FINAL then
    self.press_space_text:draw(self.surface, 160, 190)
  end
end

-----------------------------------------------------------------

-- When the menu starts, load sounds, then
-- display the title
function title_screen:on_started()
  self.phase = NO_STATE

  self:go_to_phase(BLACK_SCREEN)

  -- Use the small delay of the black screen
  -- to preload all sound effects.
  sol.audio.preload_sounds()
end

-- Draws this menu on the quest screen.
function title_screen:on_draw(dst_surface)

  -- Update the local surface
  if self.phase >= FINAL then
    self:update_surface()
  end

  -- Draw local surface on dst_surface
  -- Note: dst_surface may be larger so we center the image
  if self.surface then
    local width, height = dst_surface:get_size()
    self.surface:draw(dst_surface, width / 2 - 160, height / 2 - 120)
  end
end

-- Key pressed: skip menu or quit Solarus.
function title_screen:on_key_pressed(key)
  local handled = false

  if key == "escape" then
    -- stop the program
    sol.main.exit()
    handled = true

  elseif key == "space" or key == "return" then
    handled = self:try_skip_menu()
  end

  return handled
end

-- Mouse pressed: skip menu.
function title_screen:on_mouse_pressed(button, x, y)
  local handled = false

  if button == "left" or button == "right" then
    handled = self:try_skip_menu()
  end

  return handled
end

-- Joypad pressed: skip menu.
function title_screen:on_joypad_button_pressed(button)

  return self:try_skip_menu()
end

-- Try to skip the title screen if possible
function title_screen:try_skip_menu()

  local handled = false

  if self.phase == FINAL and self.allow_skip and not self.finished then
    self.finished = true
    title_screen:go_to_phase(FADE_OUT)
    handled = true
  end

  return handled
end

-- End directly the title screen
function title_screen:skip_menu()

  sol.audio.stop_music()
  sol.menu.stop(self)
end

-----------------------------------------------------------------

-- Return the menu to the caller
return title_screen
