local func_blueprint = require("util/blueprint")
function gui_opened(event)
    if global.name_id_table==nil then
        global.name_id_table={}
    end

    local player=game.get_player(event.player_index)
    if player==nil then return end

    if event.entity~=nil and event.entity.name == "better-linked-chest" then

        local blc_frame=getBlcFrame(player)
        if global.reset_blc_gui==true and blc_frame~=nil then
            global.reset_blc_gui=false
            blc_frame.destroy()
        end
        local blc_frame=getBlcFrame(player)

        local name_dropdown=getChild(player, "blc.name_dropdown")
        local id_label=getChild(player, "blc.id_label")
        local remove_button=getChild(player, "blc.remove_button")
        local link_name_label=getChild(player, "blc.link_name_label")
        local name_textfield=getChild(player, "blc.name_textfield")
        local link_id_label=getChild(player, "blc.link_id_label")
        local id_textfield=getChild(player, "blc.id_textfield")
        local add_button=getChild(player, "blc.add_button")
        local choose_elem_button=getChild(player, "blc.choose_elem_button")
        local test_dropdown=getChild(player, "blc.test_dropdown")

        global.blc_entity=event.entity
        if global.blc_entity~=nil then
            if blc_frame==nil then
                local gui_relative=player.gui.relative
                -- gui_relative.children[1]
                blc_frame=gui_relative.add{
                    type="frame",
                    name="blc.blc_frame",
                    direction="vertical",
                    caption={"blc.blc_frame_cap"},
                    anchor={
                        gui=defines.relative_gui_type.linked_container_gui,
                        position=defines.relative_gui_position.right
                    }
                }
            end
            if name_dropdown==nil then
                -- blc_frame.children[1]
                name_dropdown=blc_frame.add{
                    type="drop-down",
                    name="blc.name_dropdown",
                    caption={"blc.name_dropdown_cap"}
                }
            end
            if id_label==nil then
                -- blc_frame.children[2]
                id_label=blc_frame.add{
                    type="label",
                    name="blc.id_label",
                    caption="ID:"
                }
            end
            if remove_button==nil then
                -- blc_frame.children[3]
                remove_button=blc_frame.add{
                    type="button",
                    name="blc.remove_button",
                    caption={"blc.remove_button_cap"}
                }
            end
            if link_name_label==nil then
                -- blc_frame.children[4]
                link_name_label=blc_frame.add{
                    type="label",
                    name="blc.link_name_label",
                    caption={"blc.link_name_label_cap"}
                }
            end
            if name_textfield==nil then
                -- blc_frame.children[5]
                name_textfield=blc_frame.add{
                    type="textfield",
                    name="blc.name_textfield"
                }
            end
            if choose_elem_button==nil then
                -- blc_frame.children[6]
                choose_elem_button=blc_frame.add{
                    type="choose-elem-button",
                    name="blc.choose_elem_button",
                    style="slot_button",
                    elem_type="item"
                }
            end
            if link_id_label==nil then
                -- blc_frame.children[7]
                link_id_label=blc_frame.add{
                    type="label",
                    name="blc.link_id_label",
                    caption={"blc.link_id_label_cap"}
                }
            end
            if id_textfield==nil then
                -- blc_frame.children[8]
                id_textfield=blc_frame.add{
                    type="textfield",
                    name="blc.id_textfield"
                }
            end
            if add_button==nil then
                -- blc_frame.children[9]
                add_button=blc_frame.add{
                    type="button",
                    name="blc.add_button",
                    caption={"blc.add_button_cap"}
                }
            end

            local table_size=0
            for _ in pairs(global.name_id_table) do 
                table_size=table_size+1
            end
            if table_size~=0 then
                fillDropdown(name_dropdown)
            end
            if global.blc_entity.link_id==0 then
                name_dropdown.selected_index=0
                id_label.caption="ID: 0"
            else
                local index = getIndexByGlobalId(name_dropdown)
                if index~=nil then
                    name_dropdown.selected_index=index
                end
                id_label.caption="ID: "..global.blc_entity.link_id
            end
            local first_free_id=getFirstFreeID()
            id_textfield.text=""..first_free_id
        end
    end
end

function gui_closed(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    if event.entity~=nil and event.entity.name == "better-linked-chest" then
        if global.blc_entity.name=="better-linked-chest" then
            local blc_frame = getBlcFrame(player.gui.relative)
            if blc_frame~=nil then
                local name_dropdown=getChild(player, "blc.name_dropdown")
                name_dropdown.close_dropdown()
            end
        end
    end
end

local function isInteger(str)
    return not (str == "" or str:find("%D"))  -- str:match("%D") also works
end

function gui_click(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    local element=event.element
    local blc_frame=getBlcFrame(player)
    if blc_frame~=nil and blc_frame.name=="blc.blc_frame" then
        local name_dropdown=getChild(player, "blc.name_dropdown")
        local id_label=getChild(player, "blc.id_label")
        local name_textfield=getChild(player, "blc.name_textfield")
        local id_textfield=getChild(player, "blc.id_textfield")
        local choose_elem_button=getChild(player, "blc.choose_elem_button")
        local test_dropdown=getChild(player, "blc.test_dropdown")
        if element.name=="blc.add_button" then
            if isInteger(id_textfield.text) then
                local id = tonumber(id_textfield.text)
                if id > 4294967295 then
                    player.print({"blc.id_to_big"})
                elseif id==0 then
                    local test={"blc.id_zero"}
                    player.print(test)
                    player.print({"blc.id_zero"})
                    local first_free_id=getFirstFreeID()
                    id_textfield.text=""..first_free_id
                elseif name_textfield.text=="" then
                    player.print({"blc.name_empty"})
                else
                    local isInTable=false
                    for key,value in pairs(global.name_id_table) do
                        if value[1]==id then
                            isInTable=true
                            player.print({"blc.id_alredy_set_1", id, key})
                        end
                        if key==name_textfield.text then
                            isInTable=true
                            player.print({"blc.name_alredy_set_1", name_textfield.text, id})
                        end
                    end
                    if isInTable==false then
                        local str=game.item_prototypes[string.lower(name_textfield.text)]
                        if str~=nil then
                            -- Entries that have been added using the choose elem button
                            loc_string=localised_string(str, name_textfield.text)
                            global.name_id_table[name_textfield.text]={id, loc_string}
                        else
                            -- Entires with custom names
                            global.name_id_table[name_textfield.text]={id, name_textfield.text}
                        end
                        id_label.caption="ID: "..id
                        global.blc_entity.link_id=id
                        fillDropdown(name_dropdown)
                        name_textfield.text=""
                        local first_free_id=getFirstFreeID()
                        id_textfield.text=""..first_free_id
                        
                        local index=getIndexById(name_dropdown, id)
                        name_dropdown.selected_index=index
                        
                        if choose_elem_button.elem_value~=nil then
                            choose_elem_button.elem_value=nil
                        end
                    end
                end
            else
                player.print("blc.pos_int_error")
            end
        elseif element.name=="blc.remove_button"then
            removeDropdown(name_dropdown,id_label)
            local first_free_id=getFirstFreeID()
            id_textfield.text=""..first_free_id
        end
    end
end

function gui_selection_state_changed(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    local element=event.element
    local blc_frame=getBlcFrame(player)
    if blc_frame~=nil and blc_frame.name=="blc.blc_frame" and element.name=="blc.name_dropdown" then
        local name_dropdown=getChild(player, "blc.name_dropdown")
        local id_label=getChild(player, "blc.id_label")
        local selected_index=element.selected_index
        local selected_item=element.get_item(selected_index)
        if selected_index>0 then
            for key,value in pairs(global.name_id_table) do
                local sel_id=getSelectedID(name_dropdown, player)
                id_label.caption="ID: "..sel_id
                if type(sel_id)=="number" then global.blc_entity.link_id=sel_id end
            end
        end
    end
end

function entity_settings_pasted(event)
    if event.source~=nil and event.destination~=nil then
        if event.source.name=="better-linked-chest" and event.destination.name=="better-linked-chest" then
            event.destination.link_id=event.source.link_id
        end
    end
end

function pre_build(event)
    local player=game.get_player(event.player_index)
    local surface=player.surface
    local cursor=player.cursor_stack
    local paste_position=event.position

    if player.is_cursor_blueprint() then
        local original_entities=player.get_blueprint_entities()
        local original_tiles
        if player.cursor_stack.valid_for_read==true then
            original_tiles=player.cursor_stack.get_blueprint_tiles()
        end
        if type(original_entities)=="table" then
            local contains_blc=false
            for i,e in ipairs(original_entities) do
                if e.name=="better-linked-chest" then
                    contains_blc=true
                end
            end
            if contains_blc==true then
                local blueprint_entities=func_blueprint(original_entities, original_tiles, event, player)
                for i,e in ipairs(blueprint_entities) do
                    local entity = surface.find_entity("better-linked-chest", e.position)
                    if entity~=nil then
                        entity.link_id=e.link_id
                    end
                end
            end
        end
    end
end

function gui_elem_changed(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    local element=event.element
    local blc_frame=getBlcFrame(player)
    if blc_frame~=nil then
        local name_textfield=getChild(player, "blc.name_textfield")
        if name_textfield~=nil then
            local name=element.elem_value
            if name~=nil then
                if type(name)=="table" then
                    name=name.name
                end
                name=name:gsub("%f[%a].", string.upper)
                name_textfield.text=name
                for key,value in pairs(global.name_id_table) do
                    if name==key then
                        global.blc_entity.link_id=value[1]
                        fillDropdown(getChild(player, "blc.name_dropdown"))
                        local id_label=getChild(player, "blc.id_label")
                        id_label.caption="ID: "..value[1]
                        element.elem_value=nil
                    end
                end
            end
        end
    end

end

function getBlcFrame(player)
    local children=player.gui.relative.children
    if children~=nil then
        for key,value in pairs(children) do
            if value.name=="blc.blc_frame" then
                return value
            end
        end
    end
end

function getChild(player, name)
    local blc_frame=getBlcFrame(player)
    if blc_frame~=nil then
        local children=blc_frame.children
        if children~=nil then
            for key,value in pairs(children) do
                if value.name==name then
                    return value
                end
            end
        end
    end
end

function fillDropdown(dropdown)
    dropdown.clear_items()
    local tkeys={}
    local newTab={}
    for k in pairs(global.name_id_table) do table.insert(tkeys, k) end
    table.sort(tkeys)
    for _,k in ipairs(tkeys) do newTab[k]=global.name_id_table[k] end
    global.name_id_table=newTab
    local i = 1
    for key,value in pairs(newTab) do
        if value[2]~=nil then
            dropdown.add_item(value[2])
        else
            dropdown.add_item(key)
        end
        if global.blc_entity.link_id ~= 0 and global.blc_entity.link_id==value[1] then
            dropdown.selected_index=i
        end
    end
end

function sortTableByName()
    local tkeys={}
    local newTab={}
    for k in pairs(global.name_id_table) do table.insert(tkeys, k) end
    table.sort(tkeys)
    for _,k in ipairs(tkeys) do newTab[k]=global.name_id_table[k] end
    global.name_id_table=newTab
end

function removeDropdown(dropdown,label)
    local selected_id=dropdown.selected_index
    if selected_id>0 then
        local selected_item=dropdown.get_item(selected_id)
        local selected_name=getNamebyId(global.blc_entity.link_id)
        global.name_id_table[selected_name]=nil
        fillDropdown(dropdown)
        global.blc_entity.link_id=0
        label.caption="ID: --"
    end
end

function getSelectedID(dropdown, player)
    local selected_index=dropdown.selected_index
    if selected_index>0 then
        local selected_item=dropdown.get_item(selected_index)
        for key,value in pairs(global.name_id_table) do
            if localised_name_equal(key, value[2], selected_item)==true then return value[1] end
        end
    end
    return "--"
end

function getFirstFreeID()
    for i=1, 4294967295, 1 do
        isInTable=false
        for key,value in pairs(global.name_id_table) do
            if value[1]==i then
                isInTable=true
            end
        end
        if isInTable==false then
            return i
        end
    end
end

function getNamebyId(id)
    for key,value in pairs(global.name_id_table) do
        if value[1]==id then
            return key
        end
    end
    return "--"
end

function getLocNamebyId(id)
    for key,value in pairs(global.name_id_table) do
        if value[1]==id then
            return value[2]
        end
    end
    return "--"
end

function getIndexByGlobalId(dropdown)
    local name=getNamebyId(global.blc_entity.link_id)
    local localised_name=getLocNamebyId(global.blc_entity.link_id)
    for i, item in ipairs(dropdown.items) do
        local value=global.name_id_table[name]
        if localised_name_equal(name, value[2], item) then
            return i
        end
    end
end

function getIndexById(dropdown, id)
    local name=getNamebyId(id)
    for i, item in ipairs(dropdown.items) do
        local value=global.name_id_table[name]
        if localised_name_equal(name, value[2], item) then
            return i
        end
    end
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

function localised_name_equal(key, localised_name1, localised_name2)
    if type(localised_name1)=="table" and type(localised_name2)=="table" then
        if localised_name1[1]~=nil and localised_name1[2]==nil and localised_name1[3]==nil and localised_name2[1]~=nil and localised_name2[2]==nil and localised_name2[3]==nil then
            if localised_name1[1]==localised_name2[1] then
                return true
            end
        elseif localised_name1[1]~=nil and localised_name1[2]~=nil and localised_name1[3]==nil and localised_name2[1]~=nil and localised_name2[2]~=nil and localised_name2[3]==nil then
            if localised_name1[1]==localised_name2[1] and localised_name1[2][1]==localised_name2[2][1] then
                return true
            end
        elseif localised_name1[1]~=nil and localised_name1[2]~=nil and localised_name1[3]~=nil and localised_name2[1]~=nil and localised_name2[2]~=nil and localised_name2[3]~=nil then
            if localised_name1[1]==localised_name2[1] and localised_name1[2][1]==localised_name2[2][1] and localised_name1[3][1]==localised_name2[3][1] then
                return true
            end
        end
    elseif localised_name1==nil and type(selected_index)=="string" then
        if key==selected_index then
            return true
        end
    elseif type(localised_name1)=="string" and type(localised_name2)=="string" then
        if localised_name1==localised_name2 then
            return true
        end
    end
    return false
end
script.on_event(defines.events.on_gui_opened , gui_opened)
script.on_event(defines.events.on_gui_closed , gui_closed)
script.on_event(defines.events.on_gui_click, gui_click)
script.on_event(defines.events.on_gui_selection_state_changed, gui_selection_state_changed)
script.on_event(defines.events.on_entity_settings_pasted, entity_settings_pasted) 
script.on_event(defines.events.on_pre_build, pre_build)
script.on_event(defines.events.on_gui_elem_changed, gui_elem_changed)

