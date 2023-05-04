-- This file was written by kajacx for the Factorio mod Copy Paste Modules. https://mods.factorio.com/mod/CopyPasteModules
-- some modifications were made
local function direction_to_vector(direction)
    if direction == defines.direction.north then
        return { x = 0, y = -1 }
    end
    if direction == defines.direction.northeast then
        return { x = 1, y = -1 }
    end
    if direction == defines.direction.east then
        return { x = 1, y = 0 }
    end
    if direction == defines.direction.southeast then
        return { x = 1, y = 1 }
    end
    if direction == defines.direction.south then
        return { x = 0, y = 1 }
    end
    if direction == defines.direction.southwest then
        return { x = -1, y = 1 }
    end
    if direction == defines.direction.west then
        return { x = -1, y = 0 }
    end
    if direction == defines.direction.northwest then
        return { x = -1, y = -1 }
    end
    return { x = 0, y = -1 } -- north
end

local function vector_to_direction(vector)
    if vector.x == 0 and vector.y < 0 then
        return defines.direction.north
    end
    if vector.x > 0 and vector.y < 0 then
        return defines.direction.northeast
    end
    if vector.x > 0 and vector.y == 0 then
        return defines.direction.east
    end
    if vector.x > 0 and vector.y > 0 then
        return defines.direction.southeast
    end
    if vector.x == 0 and vector.y > 0 then
        return defines.direction.south
    end
    if vector.x < 0 and vector.y > 0 then
        return defines.direction.southwest
    end
    if vector.x < 0 and vector.y == 0 then
        return defines.direction.west
    end
    if vector.x < 0 and vector.y < 0 then
        return defines.direction.northwest
    end
    return defines.direction.north
end

local function multiply_matrix_vector(matrix, vector, player)
    return {
        x = matrix[1].x * vector.x + matrix[2].x * vector.y,
        y = matrix[1].y * vector.x + matrix[2].y * vector.y,
    }
end

local function multiply_matrix_matrix(matrix1, matrix2)
    return {
        multiply_matrix_vector(matrix1, matrix2[1]),
        multiply_matrix_vector(matrix1, matrix2[2]),
    }
end

return function(blueprint_entities, tiles, event, player)
    local cursor_position = event.position
    local rotation = event.direction or defines.direction.north
    -- first, rotate (and/or flip) the blueprint and compute it's size
    local rotated_entities = {}

    -- column-major tranformation matrix
    local location_tranform = {
        { x = 1, y = 0 },
        { x = 0, y = 1 },
    }

    if event.flip_horizontal then
        location_tranform[1].x = -1
    end
    if event.flip_vertical then
        location_tranform[2].y = -1
    end

    for _i=2,rotation,2 do
        -- multiply by the rotation matrix from the left
        local rotation_matrix = {
            { x =  0, y = 1 },
            { x = -1, y = 0 }
        }
        location_tranform = multiply_matrix_matrix(rotation_matrix, location_tranform)
    end

    local minX_entity =  1000000000
    local minY_entity =  1000000000
    local maxX_entity = -1000000000
    local maxY_entity = -1000000000
    if blueprint_entities==nil then return nil end
    for _,entity in pairs(blueprint_entities) do
        game.print(entity.name)
        local direction = defines.direction.north
        if game.entity_prototypes[entity.name].supports_direction then
            local direction_vector = direction_to_vector(entity.direction or defines.direction.north)
            direction = vector_to_direction(multiply_matrix_vector(location_tranform, direction_vector))
        end

        local position = multiply_matrix_vector(location_tranform, entity.position)

        table.insert(rotated_entities, {
            name = entity.name,
            position = position,
            direction = direction,
            items = entity.items,
            link_id = entity.link_id
        })

        local collision_box = game.entity_prototypes[entity.name].collision_box
        local width  = (collision_box.right_bottom.x - collision_box.left_top.x)
        local height = (collision_box.right_bottom.y - collision_box.left_top.y)
      
        if direction == defines.direction.east or direction == defines.direction.west then
            local swap = width
            width = height
            height = swap
        end

        minX_entity = math.min(minX_entity, math.floor(position.x - width  / 2 + 0.5))
        minY_entity = math.min(minY_entity, math.floor(position.y - height / 2 + 0.5))
        maxX_entity = math.max(maxX_entity, math.floor(position.x + width  / 2 + 0.5))
        maxY_entity = math.max(maxY_entity, math.floor(position.y + height / 2 + 0.5))
    end

    local blueprint_width  = maxX_entity - minX_entity
    local blueprint_height = maxY_entity - minY_entity
    game.print("w: "..blueprint_width.."h: "..blueprint_height)

    -- then, calculate the "align" so that entity pos + aligh = real position
    local alignX = math.floor(cursor_position.x - blueprint_width  / 2 + 0.5) - minX_entity 
    local alignY = math.floor(cursor_position.y - blueprint_height / 2 + 0.5) - minY_entity


    local minX_tile =  1000000000
    local minY_tile =  1000000000
    local maxX_tile = -1000000000
    local maxY_tile = -1000000000

    if tiles~=nil then
         for i,tile in ipairs(tiles) do
            local position = tile.position
            minX_tile = math.min(minX_tile, math.floor(position.x - 1  / 2 + 0.5))
            minY_tile = math.min(minY_tile, math.floor(position.y - 1 / 2 + 0.5))
            maxX_tile = math.max(maxX_tile, math.floor(position.x + 1  / 2 + 0.5))
            maxY_tile = math.max(maxY_tile, math.floor(position.y + 1 / 2 + 0.5))
        end
        blueprint_width  = maxX_tile - minX_tile
        blueprint_height = maxY_tile - minY_tile
        alignX = math.floor(cursor_position.x - blueprint_width  / 2 + 0.5) - minX_tile 
        alignY = math.floor(cursor_position.y - blueprint_height / 2 + 0.5) - minY_tile
    end
    
    game.print("w: "..blueprint_width.."h: "..blueprint_height)


    -- finally, add align to entity positions
    local final_entities = {}
    for _,entity in pairs(rotated_entities) do
        if entity.name=="better-linked-chest" then
            table.insert(final_entities, {
                name = entity.name,
                position = {
                  x = entity.position.x + alignX,
                  y = entity.position.y + alignY,
                },
                direction = entity.direction,
                link_id = entity.link_id
            })
        end
    end
    return final_entities
end