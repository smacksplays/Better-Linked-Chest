data:extend({
    {
		type = "int-setting",
		name = "better-linked-chest-inventory-size",
		order = "c",
		setting_type = "startup",
		default_value = 120,
		minimum_value = 10,
		maximum_value = 4069,
    },
    {
        type = "string-setting",
        name = "better-linked-chest-required-research",
        setting_type = "startup",
        default_value = "chemical",
        allowed_values = { "automation", "logistic", "chemical", "production", "utility", "space" },
        --[[

        default_value = {"setting.chemical"},
        allowed_values = { {"setting.automation"}, {"setting.logistic"}, {"setting.chemical"}, {"setting.production"}, {"setting.utility"}, {"setting.space"} },
        ]]--
    },
    {
        type = "string-setting",
        name = "better-linked-chest-crafting-cost",
        setting_type = "startup",
        default_value = "medium",
        allowed_values = { "easy", "medium", "hard"},
    }
  })
  