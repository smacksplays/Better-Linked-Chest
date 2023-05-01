data:extend({  
    {
        type = "item",
        name = "better-linked-chest",
        icon = "__Better-Linked-Chest__/graphics/icons/better-linked-chest-icon.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "storage",
        order = "a[steel-chest]-a[better-linked-chest]",
        place_result = "better-linked-chest",
        stack_size = 100
    }--[[,
    {
        type = "item",
        name = "ultra-fast-long-inserter",
        icon = "__UltraFastMagnecticInserterExtra__/graphics/long-inserter.png",
        icon_size = 32,
        subgroup = "inserter",
        order = "z[stack-inserter]",
        place_result = "ultra-fast-long-inserter",
        stack_size = 50
    }]]
})