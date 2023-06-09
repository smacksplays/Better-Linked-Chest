local automation={"setting.automation"}
local logistic={"setting.logistic"}
local chemical={"setting.chemical"}
local production={"setting.production"}
local utility={"setting.utility"}
local space={"setting.space"}

data:extend({
    {
		type = "int-setting",
		name = "blc-inventory-size",
		order = "c",
		setting_type = "startup",
		default_value = 120,
		minimum_value = 10,
		maximum_value = 4069
    },
    {
        type = "string-setting",
        name = "blc-required-research",
        setting_type = "startup",
        default_value = "chemical",
        allowed_values = { "automation", "logistic", "chemical", "production", "utility", "space" }
    },
    {
        type = "string-setting",
        name = "blc-crafting-cost",
        setting_type = "startup",
        default_value = "medium",
        allowed_values = { "easy", "medium", "hard"}
    }
  })
  