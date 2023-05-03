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

function localised_param(str, name, index)
    local name_str={}
    local i=0
    if str=="item-name.textplate" then
        name_lower=string.lower(name)
        local t={}
        for str1 in string.gmatch(name_lower, "-(%w+)") do
                table.insert(t, str1)
        end
        return t[index]
    end
    if str=="item-name.solid-fluid" then
        name_lower=string.lower(name)
        local t={}
        for str1 in string.gmatch(name_lower, "-(%w+)") do
                table.insert(t, str1)
        end
        return t[index]
    end
    return "0"
end

if global.name_id_table~=nil then
    game.print("Better-Linked-Chest: Migration 1.0.14")
    temp=copy_table(global.name_id_table)
    global.name_id_table={}
    for key,value in pairs(temp) do
        local str=game.item_prototypes[string.lower(key)]
        if str~=nil then
            if str.localised_name~=nil then 
                str=str.localised_name
                if type(str)=="table" then
                    str=str[1]
                end
            end
            loc_para1=localised_param(str, key,1)
            loc_para2=localised_param(str, key,1)
            --if type(str)=="string" then game.print("str: "..str.." p1: "..loc_para1.." p2: "..loc_para2) end
            if loc_para1~=nil and loc_para2~=nil then
                game.print("Case 1: key: "..key.." old: {"..value.."} new: {"..value..","..str..","..loc_para1.."}")
                --global.name_id_table[key]={value, str, loc_para1}
            elseif loc_para1~=nil then
                game.print("Case 2: key: "..key.." old: {"..value.."} new: {"..value..","..str..","..loc_para1..","..loc_para2.."}")
                --global.name_id_table[key]={value, str, loc_para1, loc_para2}
            else
                game.print("Case 3: key: "..key.." old: {"..value.."} new: {"..value..","..str.."}")
                --global.name_id_table[key]={value, str}
            end
        else

            game.print("Case 4: key: "..key.." old: {"..value.."} new: {"..value..", nil}")
            --global.name_id_table[key]={value, nil}
        end
    end
end