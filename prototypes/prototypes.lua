-- load all required lua files

-- Better Linked Chest
local func_create_chest = require("better-linked-chest")

--require("item.better-linked-chest-item")
--require("recipe.better-linked-chest-recipe")
--require("entity.better-linked-chest-entity")
--require("technology.better-linked-chest-technology")

data:extend{func_create_chest("better-linked-chest", "iron-chest", "container")}