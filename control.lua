local mod_gui = require("mod-gui")
local blc_entity_name="better-linked-chest"

script.on_event(defines.events.on_gui_opened , function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    if event.entity==nil then return end
    if event.entity.name==blc_entity_name then
        global.blc_entity=event.entity
        local table_size=0
        for _ in pairs(global.name_id_table) do 
            table_size=table_size+1
        end
        if table_size~=0 then
            fillDropdown(nil, player)
        end
        if global.blc_entity.link_id==0 then
            player.gui.relative.blc_frame.name_dropdown.selected_index=0
            player.gui.relative.blc_frame.id_label.caption="ID: 0"
        else
            local index = getDropdownIndexByID(player.gui.relative.blc_frame.name_dropdown, global.blc_entity.link_id)
            if index~=nil then
                player.gui.relative.blc_frame.name_dropdown.selected_index=index
            end
            player.gui.relative.blc_frame.id_label.caption="ID: "..global.blc_entity.link_id
        end
        local first_free_id=getFirstFreeID()
        player.gui.relative.blc_frame.id_textfield.text=""..first_free_id
        player.gui.screen.blc_frame.id_textfield.text=""..first_free_id
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    if event.entity==nil then return end

    if event.entity.name==blc_entity_name then
        if player.gui.relative.blc_frame.blc_frame~=nil then
            player.gui.relative.blc_frame.name_dropdown.close_dropdown()
        end
    end
end)

script.on_configuration_changed(function(event)
    for i, player in pairs(game.players) do
        create_blc_gui(player)
    end
  end)

script.on_init(function(event)
    global.name_id_table={}
    for i, player in pairs(game.players) do
        create_blc_gui(player)
    end
end)
  
script.on_event(defines.events.on_player_created, function(event)
    create_blc_gui(game.get_player(event.player_index))
end)
  
script.on_event(defines.events.on_player_joined_game, function(event)
    create_blc_gui(game.get_player(event.player_index))
end)


script.on_event(defines.events.on_gui_click, function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    local element=event.element

    -- Sprite Button
    if element.name=="blc_sprite_button" then
        if player.gui.screen.blc_frame.visible then
            player.gui.screen.blc_frame.visible=false
        else
            player.gui.screen.blc_frame.visible=true
            local first_free_id=getFirstFreeID()
            player.gui.screen.blc_frame.id_textfield.text=""..first_free_id
        end
        return
    end
    if element.name=="blc.close_button" then
        player.gui.screen.blc_frame.visible=false
    end

    -- Add Button
    if element.name=="add_button" then
        addNameID(element, player)
        return
    end
    -- Remove Button
    if element.name=="remove_button" then
        removeNameID(element, player)
        return
    end
end)

function addNameID(element, player)
    local blc_frame=element.parent
    if isInteger(blc_frame.id_textfield.text) then 
        -- Check if 0 < id < 4294967295 and name~=""
        local id=tonumber(blc_frame.id_textfield.text)
        local errors = {}
        if id > 4294967295 then
            table.insert(errors, {"blc.id_to_big_error"})
        elseif id == 0 then
            table.insert(errors, {"blc.id_zero_error"})
        end
        if blc_frame.name_textfield.text=="" then
            table.insert(errors, {"blc.name_empty_error"})
        end
        
        -- Check if id or name is alredy in name_id_table
        for key,value in pairs(global.name_id_table) do
            if value[1]==id then
                table.insert(errors, {"blc.id_alredy_set_1_error", id, key})
            end
            if key==blc_frame.name_textfield.text then
                table.insert(errors, {"blc.name_alredy_set_1_error", blc_frame.name_textfield.text, id})
            end
        end
        if next(errors)~=nil then
            for _,e in pairs(errors) do
                player.print(e)
            end
            return
        end

        -- no errors => add to table
        local str=game.item_prototypes[string.lower(blc_frame.name_textfield.text)]
        if str~=nil then
            -- Entries that have been added using the choose elem button
            loc_string=localised_string(str, blc_frame.name_textfield.text)
            global.name_id_table[blc_frame.name_textfield.text]={id, loc_string}
        else
            -- Entires with custom names
            global.name_id_table[blc_frame.name_textfield.text]={id, blc_frame.name_textfield.text}
        end
        blc_frame.id_label.caption="ID: "..id
        if  element.parent==player.gui.relative.blc_frame then
            global.blc_entity.link_id=id
        end
        fillDropdown(element, player)
        blc_frame.name_textfield.text=""
        local first_free_id=getFirstFreeID()
        player.gui.relative.blc_frame.id_textfield.text=""..first_free_id
        player.gui.screen.blc_frame.id_textfield.text=""..first_free_id
        
        local index=getDropdownIndexByID(blc_frame.name_dropdown, id)
        blc_frame.name_dropdown.selected_index=index
        
        if blc_frame.choose_elem_button.elem_value~=nil then
            blc_frame.choose_elem_button.elem_value=nil
        end
    else
        player.print({"blc.pos_int_error"})
        return 
    end
end

function isInteger(str)
    return not (str == "" or str:find("%D"))
end

function removeNameID(element, player)
    local dropdown=element.parent.name_dropdown
    local selected_index=dropdown.selected_index
    if selected_index>0 then
        local selected_item=dropdown.get_item(selected_index)
        -- get key for selected item
        local selected_name
        for key,value in pairs(global.name_id_table) do
            if localised_name_equal(key, value[2], selected_item) or key==selected_item then 
                selected_name=key
                break 
            end
        end
        -- remove from table
        global.name_id_table[selected_name]=nil
        -- set link id to 0 if needed
        if element.parent==player.gui.relative.blc_frame then
            global.blc_entity.link_id=0
            player.gui.relative.blc_frame.id_label.caption="ID: 0"
            -- correct visuals for left frame
            local left_dropdown=player.gui.screen.blc_frame.name_dropdown
            if left_dropdown.selected_index>0 then
                left_selected_item=left_dropdown.get_item(left_dropdown.selected_index)
                if localised_name_equal(selected_item, selected_item, left_selected_item) then
                    player.gui.screen.blc_frame.id_label.caption="ID: 0"
                end
            end
        end
        -- reset dropdowns
        fillDropdown(element, player)
        local first_free_id=getFirstFreeID()
        player.gui.relative.blc_frame.id_textfield.text=""..first_free_id
        player.gui.screen.blc_frame.id_textfield.text=""..first_free_id
    end
end

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    local element=event.element
    if element.name=="name_dropdown" then
        local name_dropdown=element.parent.name_dropdown
        local id_label=element.parent.id_label
        local selected_index=element.selected_index
        local selected_item=element.get_item(selected_index)
        if selected_index>0 then
            for key,value in pairs(global.name_id_table) do
                local sel_id=getSelectedID(name_dropdown, player)
                id_label.caption="ID: "..sel_id
                if element.parent==player.gui.relative.blc_frame then
                    if type(sel_id)=="number" then global.blc_entity.link_id=sel_id end
                end
            end
        end
    end
end)

script.on_event(defines.events.on_gui_elem_changed, function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    local element=event.element
    if element.parent~=nil then
        local name_textfield=element.parent.name_textfield
        if name_textfield~=nil then
            local name=element.elem_value
            if name~=nil then
                if type(name)=="table" then
                    name=name.name
                end
                name=name:gsub("%f[%a].", string.upper)
                name_textfield.text=name
                --local first_free_id=getFirstFreeID()
                --element.parent.id_textfield.text=""..first_free_id
                for key,value in pairs(global.name_id_table) do
                    if name==key then
                        if element.parent==player.gui.relative.blc_frame then
                            global.blc_entity.link_id=value[1]
                        end
                        fillDropdown(element, player, value[1])
                        element.parent.id_label.caption="ID: "..value[1]
                        element.elem_value=nil
                    end
                end
            end
        end
    end
end)


function fillDropdown(element, player, left_id)
    local rel_dropdown=player.gui.relative.blc_frame.name_dropdown
    local left_dropdown=player.gui.screen.blc_frame.name_dropdown
    rel_dropdown.selected_index=0
    left_dropdown.selected_index=0
    local sel_index = left_dropdown.selected_index
    local old_selected
    if sel_index>0 then
        old_selected=left_dropdown.get_item(sel_index)
    end
    rel_dropdown.clear_items()
    left_dropdown.clear_items()
    local tkeys={}
    local newTab={}
    for k in pairs(global.name_id_table) do table.insert(tkeys, k) end
    table.sort(tkeys)
    for _,k in ipairs(tkeys) do newTab[k]=global.name_id_table[k] end
    global.name_id_table=newTab
    local i = 1
    for key,value in pairs(newTab) do
        if value[2]~=nil then
            rel_dropdown.add_item(value[2])
            left_dropdown.add_item(value[2])
        else
            rel_dropdown.add_item(key)
            left_dropdown.add_item(key)
        end
        if element==nil then
            if global.blc_entity.valid and global.blc_entity.link_id==value[1] then
                rel_dropdown.selected_index=i
            elseif left_id==value[1] then 
                left_dropdown.selected_index=i 
            end
        else
            if element.parent==player.gui.relative.blc_frame and global.blc_entity.valid and global.blc_entity.link_id==value[1] then
                rel_dropdown.selected_index=i
            elseif element.parent==player.gui.screen.blc_frame and left_id==value[1] then 
                left_dropdown.selected_index=i 
            end
        end
        i=i+1
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
    if global.name_id_table==nil then return 1 end
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

function getDropdownIndexByID(dropdown, id)
    local name
    for key,value in pairs(global.name_id_table) do
        if value[1]==id then
            name=key
        end
    end
    for i, item in ipairs(dropdown.items) do
        local value=global.name_id_table[name]
        if value~=nil and localised_name_equal(name, value[2], item) then
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
    elseif localised_name1==nil and type(localised_name2)=="string" then
        if key==localised_name2 then
            return true
        end
    elseif type(localised_name1)=="string" and type(localised_name2)=="string" then
        if localised_name1==localised_name2 then
            return true
        end
    end
    return false
end

function destory_blc_gui(player)
    if player.gui.relative["blc.blc_frame"]~=nil then player.gui.relative["blc.blc_frame"].destroy() end
    if player.gui.relative.blc_frame~=nil then player.gui.relative.blc_frame.destroy() end
    if player.gui.screen.blc_frame~=nil then player.gui.screen.blc_frame.destroy() end
    if mod_gui.get_button_flow(player).blc_sprite_button~=nil then mod_gui.get_button_flow(player).blc_sprite_button.destroy() end
end

function create_mod_gui(player)
    mod_gui.get_button_flow(player).add({
        type = "sprite-button",
        name = "blc_sprite_button",
        tooltip = { "blc.blc_sprite_button_tooltip" },
        sprite = "item/better-linked-chest",
        style = "mod_gui_button"
    })
end

function create_setup_gui(player, location)
    if location==player.gui.relative then
        location.add{
            type="frame",
            name="blc_frame",
            direction="vertical",
            caption={"blc.blc_frame_cap"},
            anchor={
                gui=defines.relative_gui_type.linked_container_gui,
                position=defines.relative_gui_position.right
            },
            visible=true
        }
    elseif location==player.gui.screen then
        location.add{
            type="frame",
            name="blc_frame",
            direction="vertical",
            --caption={"blc.blc_frame_cap"},
            visible=false,
            location={5, 50}
        }

        location.blc_frame.add{
            type="flow",
            name="blc_titlebar"
        }

        location.blc_frame.blc_titlebar.drag_target=location.blc_frame
        location.blc_frame.blc_titlebar.add{
            type="label",
            style="frame_title",
            caption={"blc.blc_frame_cap"},
            ignored_by_interaction=true
        }
        location.blc_frame.blc_titlebar.add{ 
            type="empty-widget", 
            style="draggable_space", 
            name="blc_filler",
            ignored_by_interaction=true
        }
        location.blc_frame.blc_titlebar.blc_filler.style.height = 24
        location.blc_frame.blc_titlebar.blc_filler.style.horizontally_stretchable = true
        location.blc_frame.blc_titlebar.add{
            type="sprite-button",
            name="blc.close_button",
            style="frame_action_button",
            tooltip={"blc.close-instruction"},
            sprite="utility/close_white",
            hovered_sprite="utility/close_black",
            clicked_sprite="utility/close_black"
        }
    end
    location.blc_frame.add{
        type="drop-down",
        name="name_dropdown",
        caption={"blc.name_dropdown_cap"}
    }
    location.blc_frame.add{
        type="label",
        name="id_label",
        caption="ID:"
    }
    location.blc_frame.add{
        type="button",
        name="remove_button",
        caption={"blc.remove_button_cap"}
    }
    location.blc_frame.add{
        type="label",
        name="link_name_label",
        caption={"blc.link_name_label_cap"}
    }
    location.blc_frame.add{
        type="textfield",
        name="name_textfield"
    }
    location.blc_frame.add{
        type="choose-elem-button",
        name="choose_elem_button",
        style="slot_button",
        elem_type="item"
    }
    location.blc_frame.add{
        type="label",
        name="link_id_label",
        caption={"blc.link_id_label_cap"}
    }
    location.blc_frame.add{
        type="textfield",
        name="id_textfield"
    }
    location.blc_frame.add{
        type="button",
        name="add_button",
        caption={"blc.add_button_cap"}
    }
end

function create_blc_gui(player)
    destory_blc_gui(player)
    create_mod_gui(player)
    create_setup_gui(player, player.gui.relative)
    create_setup_gui(player, player.gui.screen)
    fillDropdown(nil, player)
end