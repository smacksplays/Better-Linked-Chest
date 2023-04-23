-- data
local BetterLinkedChest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
BetterLinkedChest.name = "Oem-linked-chest"
BetterLinkedChest.minable.result = "Oem-linked-chest"
BetterLinkedChest.inventory_size = 120

BetterLinkedChest.circuit_wire_connection_point = circuit_connector_definitions["chest"].points
BetterLinkedChest.circuit_connector_sprites = circuit_connector_definitions["chest"].sprites
BetterLinkedChest.circuit_wire_max_distance = default_circuit_wire_max_distance

data:extend({
  BetterLinkedChest,
  {
    type = "item",
    name = "Oem-linked-chest",
    icon = "__LinkedChestCircuit__/graphics/icons/linked-chest-icon.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "storage",
    order = "a[items]-a[Oem-linked-chest]",
    place_result = "Oem-linked-chest",
    stack_size = 10
  },
  {
    type = "recipe",
    name = "Oem-linked-chest",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 20},
    },
    result = "Oem-linked-chest"
  },
  {
    type = "technology",
    name = "Oem-linked-chest",
    icon = "__LinkedChestCircuit__/graphics/technology/linked-chest.png",
    icon_size = 128,
    effects = { { type = "unlock-recipe", recipe = "Oem-linked-chest" } },
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
--table.insert(data.raw["technology"]["automation"].effects, { type = "unlock-recipe", recipe = "Oem-linked-chest" } )