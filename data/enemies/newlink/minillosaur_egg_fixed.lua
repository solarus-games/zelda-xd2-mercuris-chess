local enemy = ...

-- Minillosaur waiting in eggs for the hero to drop by.

local behavior = require("enemies/lib/waiting_for_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 4,
  damage = 2,
  normal_speed = 32,
  faster_speed = 48,
  hurt_style = "normal",
  push_hero_on_sword = false,
  pushed_when_hurt = true,
  asleep_animation = "egg",
  awaking_animation = "egg_breaking",
  normal_animation = "walking",
  obstacle_behavior = "flying",
  awakening_sound = "stone"
}

behavior:create(enemy, properties)
