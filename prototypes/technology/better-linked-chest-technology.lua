data:extend({
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
    }--[[,
    {
      type = "technology",
      name = "ultra-fast-configurable-inserter",
      icon = "__base__/graphics/technology/stack-inserter.png",
      icon_size = 128,
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "ultra-fast-configurable-inserter"
        },
        {
          type = "unlock-recipe",
          recipe = "ultra-fast-configurable-filter-inserter"
        }
      },
      prerequisites = {"ultra-fast-inserter"},
      unit =
      {
        count = 200,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
        },
        time = 30
      },
      upgrade = true,
      order = "c-o-a",
    }]]
  })