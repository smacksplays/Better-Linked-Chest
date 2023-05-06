return function(chest_name, source, container)
    local inv_size=settings.startup["blc-inventory-size"].value
    local crafting_cost = settings.startup["blc-crafting-cost"].value
    local blc_recipe

    if crafting_cost=="easy" then
        blc_recipe = {
            {"iron-plate", 20}
        }
    elseif crafting_cost=="medium" then
        blc_recipe = {
            {"steel-chest", 10},
            {"iron-plate", 100},
            {"copper-plate", 100},
            {"electronic-circuit", 50},
        }
    elseif crafting_cost=="hard" then
        blc_recipe = {
            {"steel-chest", 20},
            {"iron-plate", 100},
            {"copper-plate", 100},
            {"advanced-circuit", 50},
            {"processing-unit", 10}
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
    local steel_chest=table.deepcopy(data.raw["container"]["steel-chest"]) 

    local item=util.table.deepcopy(data.raw["item"][source])
    item.name=chest_name
    item.icon="__Better-Linked-Chest__/graphics/icons/"..chest_name.."-icon.png"
    item.icon_size=64
    item.icon_mipmaps=4
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
    entity.flags= 
    {
        "placeable-neutral", 
        "player-creation"
    }
    entity.circuit_wire_connection_points=steel_chest.circuit_wire_connection_point
    entity.circuit_connector_sprites=steel_chest.circuit_connector_spritess
    entity.circuit_wire_max_distance=steel_chest.circuit_wire_max_distance
    entity.icon="__Better-Linked-Chest__/graphics/icons/"..chest_name.."-icon.png"
    entity.icon_size=64
    entity.picture=
    {
        filename="__Better-Linked-Chest__/graphics/entity/"..chest_name..".png",
        width=128,
        height=128,
        scale=0.15,
        hr_version=
        {
            filename="__Better-Linked-Chest__/graphics/entity/"..chest_name..".png",
            width=128,
            height=128,
            scale=0.3
        }
    }
    entity.gui_mode="none"
    entity.corpse=""
    entity.selecttable_in_game=true
    entity.collision_box={{-0.25,-0.25},{0.25,0.25}}
    entity.selection_box = {{-0.5,-0.5},{0.5,0.5}}
    local logisticType="storage"
    if container=="logistic-container" then
        entity.type="logistic-container"
        entity.logistic_mode = logisticType
		entity.opened_duration = logistic_chest_opened_duration
		if logisticType == "requester" or logisticType == "buffer" then
			entity.logistic_slots_count = 25 + math.min(math.floor(unitSize*2.5),25)
		elseif logisticType == "storage" then
			entity.max_logistic_slots = 1
		end
    end

    local recipe=
    {
        type="recipe",
        name=chest_name,
        enabled=false,
        ingredients=blc_recipe,
        result=chest_name
    }

    local technology=
    {
        type = "technology",
        name = chest_name,
        icon = "__Better-Linked-Chest__/graphics/technology/"..chest_name..".png",
        icon_size = 128,
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

