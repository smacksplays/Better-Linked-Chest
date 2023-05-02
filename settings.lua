data:extend({
    {
		type = "int-setting",
		name = "better-linked-chest-inventory-size",
		order = "c",
		setting_type = "startup",
		default_value = 64,
		minimum_value = 0,
		maximum_value = 4069,
    },
    {
        type = "string-setting",
        name = "better-linked-chest-required-research",
        setting_type = "startup",
        default_value = "chemical",
        allowed_values = { "automation", "logistic", "chemical", "production", "utility", "space" },
    },
    {
        type = "string-setting",
        name = "better-linked-chest-crafting-cost",
        setting_type = "startup",
        default_value = "medium",
        allowed_values = { "easy", "medium", "hard"},
    }
  })
  