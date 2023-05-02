if settings.startup["better-linked-chest-required-research"].value~=nil then
    local val=settings.startup["better-linked-chest-required-research"].value
    local blc_count=10
    local blc_ingredients=
    {
        {"automation-science-pack", 1},
    }
    local blc_time=10
    local blc_prerequisites=
    {
        "logistics",
        "electronics",
        "steel-processing"
    }
    if val=="automation" then
        blc_count=10
        blc_ingredients=
        {
            {"automation-science-pack", 1},
        }
        blc_prerequisites=
        {
            "logistics",
            "electronics",
            "steel-processing"
        }
    elseif val=="logistic" then
        blc_count=50
        blc_ingredients=
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        }
        blc_prerequisites=
        {
            "logistics",
            "fast-inserter",
            "steel-processing",
            "logistic-science-pack"
        }
    elseif val=="chemical" then
        blc_count=100
        blc_ingredients=
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        }
        blc_prerequisites=
        {
            "logistics-2",
            "stack-inserter",
            "logistic-science-pack",
            "chemical-science-pack"
        }
    elseif val=="production" then
        blc_count=200
        blc_ingredients=
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        }
        blc_prerequisites=
        {
            "logistics-3",
            "stack-inserter",
            "advanced-electronics",
            "logistic-science-pack",
            "chemical-science-pack",
            "production-science-pack"
        }
    elseif val=="utility" then
        blc_count=500
        blc_ingredients=
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        }
        blc_prerequisites=
        {
            "logistics-3",
            "stack-inserter",
            "inserter-capacity-bonus-1",
            "logistic-science-pack",
            "chemical-science-pack",
            "production-science-pack",
            "utility-science-pack"
        }
    elseif val=="space" then
        blc_count=1000
        blc_ingredients=
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1}
        }
        blc_prerequisites=
        {
            "logistics-3",
            "stack-inserter",
            "inserter-capacity-bonus-1",
            "logistic-science-pack",
            "chemical-science-pack",
            "production-science-pack",
            "utility-science-pack",
            "space-science-pack"
        }
    end
    data:extend({{
        type = "technology",
        name = "better-linked-chest",
        icon = "__Better-Linked-Chest__/graphics/technology/better-linked-chest.png",
        icon_size = 128,
        effects = { { type = "unlock-recipe", recipe = "better-linked-chest" } },
        unit = {
            count=blc_count,
            ingredients=blc_ingredients,
            time=blc_time
        },
        prerequisites = blc_prerequisites,
        order = "a-b-b",
        }
    })
end