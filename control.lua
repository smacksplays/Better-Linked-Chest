function gui_opened(event)
    if global.name_id_table==nil then
        global.name_id_table={}
    end
    local player=game.get_player(event.player_index)
    if event.entity~=nil then
        if event.entity.name=="better-linked-chest" then
            global.blc_entity=event.entity
            if global.blc_entity~=nil then
                local gui_relative=player.gui.relative
                    
                -- gui_relative.children[1]
                local id_frame=gui_relative.add{
                    type="frame",
                    name="blc.id_frame",
                    direction="vertical",
                    caption={"blc.id_frame_cap"},
                    anchor={
                        gui=defines.relative_gui_type.linked_container_gui,
                        position=defines.relative_gui_position.right
                    }
                }
                -- id_frame.children[1]
                local id_frame_dropdown=id_frame.add{
                    type="drop-down",
                    name="blc.id_frame_dropdown",
                    caption={"blc.id_frame_dropdown_cap"}
                }
                -- id_frame.children[2]
                local id_frame_dropdown_t=id_frame.add{
                    type="label",
                    name="blc.id_frame_dropdown_t",
                    caption="ID: --"
                }
                -- id_frame.children[3]
                local id_frame_remove_b=id_frame.add{
                    type="button",
                    name="blc.id_frame_remove_b",
                    caption={"blc.id_frame_remove_b_cap"}
                }
                -- gui_relative.children[2]
                local setup_frame=gui_relative.add{
                    type="frame",
                    name="blc.setup_frame",
                    direction="vertical",
                    caption={"blc.setup_frame_cap"},
                    anchor={
                        gui=defines.relative_gui_type.linked_container_gui,
                        position=defines.relative_gui_position.right
                    }
                }
                -- setup_frame.children[1]
                local setup_frame_name_l=setup_frame.add{
                    type="label",
                    name="blc.setup_frame_name_l",
                    caption={"blc.setup_frame_name_l_cap"}
                }
                -- setup_frame.children[2]
                local setup_frame_name_t=setup_frame.add{
                    type="textfield",
                    name="blc.setup_frame_name_t",
                    caption={"blc.setup_frame_name_t_cap"}
                }
                -- setup_frame.children[3]
                local setup_frame_id_l=setup_frame.add{
                    type="label",
                    name="blc.setup_frame_id_l",
                    caption={"blc.setup_frame_id_l_cap"}
                }
                -- setup_frame.children[4]
                local setup_frame_id_t=setup_frame.add{
                    type="textfield",
                    name="blc.setup_frame_id_t",
                    caption={"blc.setup_frame_id_t_cap"}
                }
                -- setup_frame.children[5]
                local setup_frame_add_b=setup_frame.add{
                    type="button",
                    name="blc.setup_frame_add_b",
                    caption={"blc.setup_frame_add_b_cap"}
                } 
        
                fillDropdown(id_frame_dropdown)
                if id_frame_dropdown.selected_index>0 then
                    local sel_id=getSelectedID(id_frame_dropdown)
                    id_frame_dropdown_t.caption="ID: "..sel_id
                end
                local first_free_id=getFirstFreeID()
                setup_frame_id_t.text=""..first_free_id
            end
        end
    end
end

function gui_closed(event)
    local player=game.get_player(event.player_index)
    if event.entity~=nil then
        if global.blc_entity.name=="better-linked-chest" then
            local screen_element=player.gui.relative.clear()
        end
    end
end

local function isInteger(str)
    return not (str == "" or str:find("%D"))  -- str:match("%D") also works
end

function gui_click(event)
    local player=game.get_player(event.player_index)
    local element=event.element
    local gui_relative=player.gui.relative
    if gui_relative.children~=nil then
        local id_frame=gui_relative.children[1]
        if id_frame~= nil and id_frame.name=="blc.id_frame" then
            local id_frame_dropdown=id_frame.children[1]
            local id_frame_dropdown_t=id_frame.children[2]
            local setup_frame=gui_relative.children[2]
            local setup_frame_name_t=setup_frame.children[2]
            local setup_frame_id_t=setup_frame.children[4]
    
            if element.name=="blc.setup_frame_add_b" then
                if isInteger(setup_frame_id_t.text) then
                    local id = tonumber(setup_frame_id_t.text)
                    if id > 4294967295 then
                        player.print("ID can't be greater than 4,294,967,295!")
                    elseif id==0 then
                        player.print("ID can't be 0!")
                        local first_free_id=getFirstFreeID()
                        setup_frame_id_t.text=""..first_free_id
                    else
                        local isInTable=false
                        for key,value in pairs(global.name_id_table) do
                            if value==id then
                                isInTable=true
                                player.print("ID: "..id.." is alredy set with Name: " .. key)
                            end
                            if key==setup_frame_name_t.text then
                                isInTable=true
                                player.print("Name: "..setup_frame_name_t.text.." is alredy set with ID: " .. id)
                            end
                        end
                        if isInTable==false then
                            global.name_id_table[setup_frame_name_t.text]=id
                            fillDropdown(id_frame_dropdown)
                            setup_frame_name_t.text=""
                            local first_free_id=getFirstFreeID()
                            setup_frame_id_t.text=""..first_free_id
                            if id_frame_dropdown.selected_index>0 then
                                local sel_id=getSelectedID(id_frame_dropdown)
                                id_frame_dropdown_t.caption="ID: "..sel_id
                            end
                        end
                    end
                else
                    player.print("ID has to be a positive integer!")
                end
            elseif element.name=="blc.id_frame_remove_b" then
                removeDropdown(id_frame_dropdown,id_frame_dropdown_t)
                local first_free_id=getFirstFreeID()
                setup_frame_id_t.text=""..first_free_id
            end 
        end
    end
end

function gui_selection_state_changed(event)
    local player=game.get_player(event.player_index)
    local gui_relative=player.gui.relative
    if gui_relative.children~=nil then
        local id_frame=gui_relative.children[1]
        if id_frame~= nil and id_frame.name=="blc.id_frame" then
            local id_frame_dropdown=id_frame.children[1]
            local id_frame_dropdown_t=id_frame.children[2]
            local element=event.element
            if element.name=="blc.id_frame_dropdown" then
                local selected_index=element.selected_index
                local selected_item=element.get_item(selected_index)
                if selected_index>0 then
                    for key,value in pairs(global.name_id_table) do
                        if selected_item==key then
                            global.blc_entity.link_id=value
                            local sel_id=getSelectedID(id_frame_dropdown)
                            id_frame_dropdown_t.caption="ID: "..sel_id
                        end
                    end
                end
            end
        end
    end
end

function entity_settings_pasted(event)
    local player=game.get_player(event.player_index)
    if event.source~=nil and event.destination~=nil then
        if event.source.name=="better-linked-chest" and event.destination.name=="better-linked-chest" then
            event.destination.link_id=event.source.link_id
        end
    end
end

function fillDropdown(dropdown)
    dropdown.clear_items()
    local i = 1
    for key,value in pairs(global.name_id_table) do
        dropdown.add_item(key)
        if global.blc_entity.link_id~=0 then
            if value==global.blc_entity.link_id then
                dropdown.selected_index=i
            end
        end
        i=i+1
    end
end

function removeDropdown(dropdown,dropdown_t)
    local selected_id=dropdown.selected_index
    if selected_id>0 then
        local selected_item=dropdown.get_item(selected_id)
        global.name_id_table[selected_item]=nil
        fillDropdown(dropdown)
        global.blc_entity.link_id=0
        dropdown_t.caption="ID: --"
    end
end

function getSelectedID(dropdown)
    local selected_id=dropdown.selected_index
    if selected_id>0 then
        local selected_item=dropdown.get_item(selected_id)
        for key,value in pairs(global.name_id_table) do
            if key==selected_item then
                return value
            end
        end
    end
    return "--"
end

function getFirstFreeID()
    for i=1, 100, 1 do
        isInTable=false
        for key,value in pairs(global.name_id_table) do
            if value==i then
                isInTable=true
            end
        end
        if isInTable==false then
            return i
        end
    end
end

script.on_event(defines.events.on_gui_opened , gui_opened)
script.on_event(defines.events.on_gui_closed , gui_closed)
script.on_event(defines.events.on_gui_click, gui_click)
script.on_event(defines.events.on_gui_selection_state_changed, gui_selection_state_changed)
script.on_event(defines.events.on_entity_settings_pasted, entity_settings_pasted)
 