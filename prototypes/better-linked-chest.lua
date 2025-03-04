return function(chest_name, source, container)
    local inv_size=settings.startup["blc-inventory-size"].value
    local crafting_cost = settings.startup["blc-crafting-cost"].value
    local blc_recipe

    if crafting_cost=="easy" then
        blc_recipe = {
            {type = "item", name = "iron-plate", amount = 20}
        }
    elseif crafting_cost=="medium" then
        blc_recipe = {
            {type = "item", name = "steel-chest", amount = 10},
            {type = "item", name = "iron-plate", amount = 100},
            {type = "item", name = "copper-plate", amount = 100},
            {type = "item", name = "electronic-circuit", amount = 50},
        }
    elseif crafting_cost=="hard" then
        blc_recipe = {
            {type = "item", name = "steel-chest", amount = 20},
            {type = "item", name = "iron-plate", amount = 100},
            {type = "item", name = "copper-plate", amount = 100},
            {type = "item", name = "advanced-circuit", amount = 50},
            {type = "item", name = "processing-unit", amount = 10}
        }
    end

    local val=settings.startup["blc-required-research"].value
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
            "logistics",
            "electronics",
            "steel-processing",
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
            "logistics",
            "electronics",
            "steel-processing",
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
            "logistics",
            "electronics",
            "steel-processing",
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
            "logistics",
            "electronics",
            "steel-processing",
            "logistic-science-pack",
            "chemical-science-pack",
            "production-science-pack",
            "utility-science-pack"
        }
    end
    local steel_chest=table.deepcopy(data.raw["container"]["steel-chest"]) 

    local item=util.table.deepcopy(data.raw["item"][source])
    item.name=chest_name
    item.icon="__Better-Linked-Chest__/graphics/"..chest_name.."/"..chest_name.."-icon.png"
    item.subgroup="storage"
    item.order="a[steel-chest]-a["..chest_name.."]"
    item.place_result=chest_name
    item.stack_size=100

    local entity=util.table.deepcopy(data.raw[container][source])
    entity.type="linked-container"
    entity.name=chest_name
    entity.minable=
    {
        mining_time=0.2,
        result=chest_name
    }
    entity.inventory_size=inv_size
    entity.circuit_wire_connection_points=steel_chest.circuit_wire_connection_point
    entity.circuit_connector_sprites=steel_chest.circuit_connector_spritess
    entity.circuit_wire_max_distance=steel_chest.circuit_wire_max_distance
    entity.icon="__Better-Linked-Chest__/graphics/"..chest_name.."/"..chest_name..".png"
    entity.picture=
    {
        layers = 
        {
            {
                filename = "__Better-Linked-Chest__/graphics/"..chest_name.."/"..chest_name..".png",
                priority = "extra-high",
                width = 68,
                height = 84,
                shift = util.by_pixel(0, -3),
                scale = 0.5
            },
            {
                filename = "__Better-Linked-Chest__/graphics/"..chest_name.."/"..chest_name.."-shadow.png",
                priority = "extra-high",
                width = 116,
                height = 48,
                shift = util.by_pixel(12, 6),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
    entity.gui_mode="all"
    entity.corpse=""
    entity.selecttable_in_game=true
    entity.collision_box={{-0.25,-0.25},{0.25,0.25}}
    entity.selection_box = {{-0.5,-0.5},{0.5,0.5}}

    local recipe=
    {
        type="recipe",
        name=chest_name,
        enabled=false,
        ingredients=blc_recipe,
        results = {
            {type = "item", name = chest_name, quality = "legendary", amount = 1}
        }
    }

    local technology=
    {
        type = "technology",
        name = chest_name,
        icon = "__Better-Linked-Chest__/graphics/"..chest_name.."/"..chest_name.."-icon.png",
        icon_size = 64,
        effects = { 
            { 
                type="unlock-recipe", 
                recipe=chest_name 
            } 
        },
        unit = 
        {
            count=blc_count,
            ingredients=blc_ingredients,
            time=blc_time
        },
        prerequisites = blc_prerequisites,
        order = "a-b-b",
    }

    return item, entity, recipe, technology
end

