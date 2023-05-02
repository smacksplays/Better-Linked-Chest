local steel_chest=table.deepcopy(data.raw["container"]["steel-chest"]) 
local betterLinkedChest = table.deepcopy(data.raw["linked-container"]["linked-chest"])
betterLinkedChest.name="better-linked-chest"
if settings.startup["better-linked-chest-inventory-size"].value~=nil then
    local inv_size=settings.startup["better-linked-chest-inventory-size"].value
    data:extend({
        betterLinkedChest,
        {
            type="linked-container",
            name="better-linked-chest",
            minable=
            {
                mining_time=0.5,
                result="better-linked-chest"
            },
            inventory_size=inv_size,
            flags = {"placeable-neutral", "player-creation"},
            circuit_wire_connection_points=steel_chest.circuit_wire_connection_point,
            circuit_connector_sprites=steel_chest.circuit_connector_spritess,
            circuit_wire_max_distance=steel_chest.circuit_wire_max_distance,
            icon="__Better-Linked-Chest__/graphics/icons/better-linked-chest-icon.png",
            icon_size=64,
            picture=
            {
                filename="__Better-Linked-Chest__/graphics/entity/better-linked-chest.png",
                width=128,
                height=128,
                scale=0.15,
                hr_version=
                {
                    filename="__Better-Linked-Chest__/graphics/entity/better-linked-chest.png",
                    width=128,
                    height=128,
                    scale=0.3
                }
            },
            gui_mode="none",
            corpse="",
            selecttable_in_game=true,
            collision_box={{-0.25,-0.25},{0.25,0.25}},
            selection_box = {{-0.5,-0.5},{0.5,0.5}}
        },
    })
end