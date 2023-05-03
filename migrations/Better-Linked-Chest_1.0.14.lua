function copy_table(table)
    t={}
    for k,v in pairs(table) do
        if k==nil or v == nil then
            game.print("NIL")
        end
        t[k]=v
    end
    return t
end

function localised_string(str, key)
    str=str.localised_name
    if str[1]~=nil and str[2]==nil and str[3]==nil then
        return {str[1]}
    elseif str[1]~=nil and str[2]~=nil and str[3]==nil then
        if type(str[2])=="table" then
            return {str[1], {str[2][1]}}
        end
    elseif str[1]~=nil and str[2]~=nil and str[3]~=nil then
        if type(str[3])=="table" then
            return {str[1], {str[2][1]}, {str[3][1]}}
        end
    else
        return str
    end
    return nil
end

if global.name_id_table~=nil then
    game.print("Better-Linked-Chest: Migration 1.0.14")
    temp=copy_table(global.name_id_table)
    global.name_id_table={}
    for key,value in pairs(temp) do
        local str=game.item_prototypes[string.lower(key)]
        if str~=nil then
            -- Entries that have been added using the choose elem button
            loc_string=localised_string(str, key)
            global.name_id_table[key]={value, loc_string}
        else
            -- Entires with custom names
            game.print(key)
            global.name_id_table[key]={value, key}
        end
    end
end