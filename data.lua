-- data
local betterlinkedchest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
local steel_chest = table.deepcopy(data.raw["container"]["steel-chest"])

betterlinkedchest.name = "better-linked-chest"
betterlinkedchest.minable.result = "better-linked-chest"
betterlinkedchest.inventory_size = 120

betterlinkedchest.circuit_wire_connection_point = steel_chest.circuit_wire_connection_point
betterlinkedchest.circuit_connector_sprites = steel_chest.circuit_connector_sprites
betterlinkedchest.circuit_wire_max_distance = steel_chest.circuit_wire_max_distance

betterlinkedchest.icon="__Better-Linked-Chest__/graphics/icons/better-linked-chest-icon.png"
betterlinkedchest.icon_size=64
betterlinkedchest.picture.layers[1].filename="__Better-Linked-Chest__/graphics/entity/better-linked-chest.png"
betterlinkedchest.picture.layers[1].width=128
betterlinkedchest.picture.layers[1].height=128
betterlinkedchest.picture.layers[1].scale=0.15
betterlinkedchest.picture.layers[1].hr_version.filename="__Better-Linked-Chest__/graphics/entity/better-linked-chest.png"
betterlinkedchest.picture.layers[1].hr_version.width=128
betterlinkedchest.picture.layers[1].hr_version.height=128
betterlinkedchest.picture.layers[1].hr_version.scale=0.3

betterlinkedchest.gui_mode = "none"
betterlinkedchest.corpse=""


data:extend({
  betterlinkedchest,
  {
    type = "item",
    name = "better-linked-chest",
    icon = "__Better-Linked-Chest__/graphics/icons/better-linked-chest-icon.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "storage",
    order = "a[items]-a[better-linked-chest]",
    place_result = "better-linked-chest",
    stack_size = 100
  },
  {
    type = "recipe",
    name = "better-linked-chest",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 20},
    },
    result = "better-linked-chest"
  },
  {
    type = "technology",
    name = "better-linked-chest",
    icon = "__Better-Linked-Chest__/graphics/technology/better-linked-chest.png",
    icon_size = 128,
    effects = { { type = "unlock-recipe", recipe = "better-linked-chest" } },
    unit =
    {
      count = 10,
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 10
    },
    order = "a-b-b",
  },
})


local styles = data.raw["gui-style"].default

styles["blc_content_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on"
}

styles["blc_controls_flow"] = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    horizontal_spacing = 16
}

styles["blc_controls_textfield"] = {
    type = "textbox_style",
    width = 36
}

styles["blc_deep_frame"] = {
    type = "frame_style",
    parent = "slot_button_deep_frame",
    vertically_stretchable = "on",
    horizontally_stretchable = "on",
    top_margin = 16,
    left_margin = 8,
    right_margin = 8,
    bottom_margin = 4
}




--table.insert(data.raw["technology"]["automation"].effects, { type = "unlock-recipe", recipe = "better-linked-chest" } )