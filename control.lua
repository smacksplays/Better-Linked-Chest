local mod_gui=require("mod-gui")
local blc_entity_name="better-linked-chest"
local reset_blc_gui=true

local blc_frame_scr, name_dropdown_scr, id_label_scr, link_name_label_scr
local name_textfield_scr, choose_elem_button_scr, link_id_label_scr
local id_textfield_scr

local blc_frame_rel, name_dropdown_rel, id_label_rel, link_name_label_rel
local name_textfield_rel, choose_elem_button_rel, link_id_label_rel
local id_textfield_rel

script.on_init(function()
    storage.name_id_table={}
    storage.name_id_table["player"]={}
end)

script.on_event(defines.events.on_player_created, function(event)
    create_blc_gui(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_force_created, function(event)
    storage.name_id_table[event.force.name]={}
end)

script.on_configuration_changed(function()
    storage.name_id_table["player"]={}
end)

------------------------------------------------------------
-- GUI OPEN
------------------------------------------------------------

script.on_event(defines.events.on_gui_opened, function(event)
    local player=game.get_player(event.player_index)
    if reset_blc_gui==true then
        reset_blc_gui=false
        create_blc_gui(player)
    end

    if player==nil then return end
    if event.entity==nil then return end
    if event.entity.name~=blc_entity_name then return end

    storage.blc_entity=event.entity

    local table_size=0
    for _ in pairs(storage.name_id_table[player.force.name]) do
        table_size=table_size+1
    end

    if table_size~=0 then
        fillDropdown(nil, player)
    end

    if storage.blc_entity.link_id==0 then
        name_dropdown_rel.selected_index=0
        id_label_rel.caption="ID: 0"
        name_textfield_rel.caption=""
        choose_elem_button_rel.elem_value=nil
    else
        id_label_rel.caption="ID: "..storage.blc_entity.link_id

        local selected_item=storage.name_id_table[player.force.name][storage.blc_entity.link_id]

        if selected_item~=nil then
            local name, quality=string.match(selected_item, "(%a+.+) %((%a+)%)")

            if name~=nil then
                local elem_value={}
                elem_value.name=name

                if script.feature_flags.quality and quality~=nil then
                    elem_value.quality=quality
                end

                choose_elem_button_rel.elem_value=elem_value
            else
                choose_elem_button_rel.elem_value=nil
            end
        else
            storage.blc_entity.link_id=storage.blc_entity.link_id
            id_label_rel.caption="ID: "..storage.blc_entity.link_id
            choose_elem_button_rel.elem_value=nil
        end
    end

    local first_free_id=getFirstFreeID(player)
    id_textfield_rel.text=""..first_free_id
    id_textfield_scr.text=""..first_free_id
end)

------------------------------------------------------------
-- GUI CLOSED
------------------------------------------------------------

script.on_event(defines.events.on_gui_closed, function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end
    if event.entity==nil then return end
    if event.entity.name~=blc_entity_name then return end

    if name_dropdown_rel~=nil then
        name_dropdown_rel.close_dropdown()
    end
end)

------------------------------------------------------------
-- CLICK EVENTS
------------------------------------------------------------

script.on_event(defines.events.on_gui_click, function(event)
    local player=game.get_player(event.player_index)
    player.print("quality flag="..tostring(script.feature_flags.quality))
    if player==nil then return end

    local element=event.element

    if element.name=="blc_sprite_button" then
        if blc_frame_scr.visible then
            blc_frame_scr.visible=false
        else
            blc_frame_scr.visible=true
            local first_free_id=getFirstFreeID(player)
            id_textfield_scr.text=""..first_free_id
        end

    elseif element.name=="blc.close_button" then
        blc_frame_scr.visible=false

    elseif element.name=="add_button" then
        addNameID(element, player)

    elseif element.name=="remove_button" then
        removeNameID(element, player)
    end
end)

------------------------------------------------------------
-- ADD / REMOVE
------------------------------------------------------------

function addNameID(element, player)
    local blc_frame=element.parent

    if not isInteger(blc_frame.id_textfield.text) then
        player.print({"blc.pos_int_error"})
        return
    end

    local id=tonumber(blc_frame.id_textfield.text)
    local errors={}

    if id > 4294967295 then
        table.insert(errors, {"blc.id_to_big_error"})
    elseif id==0 then
        table.insert(errors, {"blc.id_zero_error"})
    end

    if blc_frame.name_textfield.text=="" then
        table.insert(errors, {"blc.name_empty_error"})
    end

    for key, value in pairs(storage.name_id_table[player.force.name]) do
        if key==id then
            table.insert(errors, {"blc.id_alredy_set_1_error", id, key})
        end
        if value==blc_frame.name_textfield.text then
            table.insert(errors, {"blc.name_alredy_set_1_error", blc_frame.name_textfield.text, id})
        end
    end

    if next(errors)~=nil then
        for _, e in pairs(errors) do
            player.print(e)
        end
        return
    end

    storage.name_id_table[player.force.name][id]=blc_frame.name_textfield.text
    blc_frame.id_label.caption="ID: "..id

    if element.parent==blc_frame_rel then
        storage.blc_entity.link_id=id
    end

    fillDropdown(element, player)

    blc_frame.name_textfield.text=""

    local first_free_id=getFirstFreeID(player)
    id_textfield_rel.text=""..first_free_id
    id_textfield_scr.text=""..first_free_id
end

function isInteger(str)
    return not (str=="" or str:find("%D"))
end

function removeNameID(element, player)
    local del_key

    if element.parent.parent.name=="relative" then
        del_key=string.match(id_label_rel.caption, "ID: (%d+)")
    elseif element.parent.parent.name=="screen" then
        del_key=string.match(id_label_scr.caption, "ID: (%d+)")
    end

    local temp={}

    for key, value in pairs(storage.name_id_table[player.force.name]) do
        if key~=tonumber(del_key) then
            temp[key]=value
        end
    end

    storage.name_id_table[player.force.name]=temp

    local dropdown=element.parent.name_dropdown
    local selected_index=dropdown.selected_index
    if selected_index < 0 then return end

    fillDropdown(element, player)

    local first_free_id=getFirstFreeID(player)
    id_textfield_rel.text=""..first_free_id
    id_textfield_scr.text=""..first_free_id
end

------------------------------------------------------------
-- SELECTION CHANGED
------------------------------------------------------------

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end

    local element=event.element
    if element.name~="name_dropdown" then return end

    local choose_elem_button=element.parent.choose_elem_button

    local name_dropdown=element.parent.name_dropdown
    local id_label=element.parent.id_label

    local selected_index=element.selected_index
    if selected_index <= 0 then return end

    local selected_item=getRawEntityString(element.get_item(selected_index), player)

    for key, _ in pairs(storage.name_id_table[player.force.name]) do
        local sel_id=getSelectedID(name_dropdown, player)
        id_label.caption="ID: "..sel_id

        if element.parent==blc_frame_rel then
            if type(sel_id)=="number" then
                storage.blc_entity.link_id=sel_id
            end
        end
    end

    if choose_elem_button~=nil and type(element.get_item(selected_index))=="table" then
        local name, quality=string.match(selected_item, "(%a+.+) %((%a+)%)")

        local elem_value={}
        elem_value.name=name

        if script.feature_flags.quality then
            elem_value.quality=quality
        end

        choose_elem_button.elem_value=elem_value
    end
end)

------------------------------------------------------------
-- ELEMENT CHANGED
------------------------------------------------------------

script.on_event(defines.events.on_gui_elem_changed, function(event)
    local player=game.get_player(event.player_index)
    if player==nil then return end

    local element=event.element
    if element.parent==nil then return end

    local name_textfield=element.parent.name_textfield
    if name_textfield==nil then return end

    local name=element.elem_value
    if name==nil then return end

    if script.feature_flags.quality then
        name_textfield.text=name.name.." ("..name.quality..")"

        name_textfield.caption={"?",
            {"", {"entity-name."..name.name}, " (", {"quality-name."..name.quality}, ")"},
            {"", {"item-name."..name.name}, " (", {"quality-name."..name.quality}, ")"},
            {"", {"equipment-name."..name.name}, " (", {"quality-name."..name.quality}, ")"}
        }

        for key, value in pairs(storage.name_id_table[player.force.name]) do
            if name.name.." ("..name.quality..")"==value then
                if element.parent==blc_frame_rel then
                    storage.blc_entity.link_id=key
                end
                fillDropdown(element, player, key)
                element.parent.id_label.caption="ID: "..key
            end
        end
    else
        name_textfield.text=name.name

        name_textfield.caption={"?",
            {"", {"entity-name."..name.name}},
            {"", {"item-name."..name.name}},
            {"", {"equipment-name."..name.name}}
        }

        for key, value in pairs(storage.name_id_table[player.force.name]) do
            if name.name==value then
                if element.parent==blc_frame_rel then
                    storage.blc_entity.link_id=key
                end
                fillDropdown(element, player, key)
                element.parent.id_label.caption="ID: "..key
            end
        end
    end
end)

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

function fillDropdown(element, player, left_id)
    name_dropdown_rel.selected_index=0
    name_dropdown_scr.selected_index=0
    name_dropdown_rel.clear_items()
    name_dropdown_scr.clear_items()

    local tvals={}
    local newTab={}

    for k in pairs(storage.name_id_table[player.force.name]) do
        table.insert(tvals, k)
    end

    table.sort(tvals)

    for _, k in ipairs(tvals) do
        newTab[k]=storage.name_id_table[player.force.name][k]
    end

    storage.name_id_table[player.force.name]=newTab

    local i=1

    for key, value in pairs(newTab) do
        if value~=nil then
            if script.feature_flags.quality then
                local name, quality=string.match(value, "(%a+.+) %((%a+)%)")

                if name~=nil and quality~=nil then
                    local new_value={"?",
                        {"", {"entity-name."..name}, " (", {"quality-name."..quality}, ")"},
                        {"", {"item-name."..name}, " (", {"quality-name."..quality}, ")"},
                        {"", {"equipment-name."..name}, " (", {"quality-name."..quality}, ")"}
                    }
                    name_dropdown_rel.add_item(new_value)
                    name_dropdown_scr.add_item(new_value)
                else
                    name_dropdown_rel.add_item(value)
                    name_dropdown_scr.add_item(value)
                end
            else
                local name=string.match(value, "(%a+.+)")

                if name~=nil then
                    local new_value={"?",
                        {"", {"entity-name."..name}},
                        {"", {"item-name."..name}},
                        {"", {"equipment-name."..name}}
                    }
                    name_dropdown_rel.add_item(new_value)
                    name_dropdown_scr.add_item(new_value)
                else
                    name_dropdown_rel.add_item(value)
                    name_dropdown_scr.add_item(value)
                end
            end
        end

        if storage.blc_entity.valid and storage.blc_entity.link_id==key then
            name_dropdown_rel.selected_index=i
        elseif left_id==key then
            name_dropdown_scr.selected_index=i
        end

        i=i+1
    end
end

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

function getSelectedID(dropdown, player)
    local selected_index=dropdown.selected_index
    if selected_index <= 0 then return end

    local selected_item=getRawEntityString(dropdown.get_item(selected_index), player)

    for key, value in pairs(storage.name_id_table[player.force.name]) do
        if value==selected_item then
            return key
        end
    end

    return "--"
end

function getRawEntityString(selected_item, player)
    local raw_string

    if type(selected_item)=="table" then
        local _, sel_name=string.match(selected_item[2][2][1], "(%a+-%a+).(%a+.+)")

        if script.feature_flags.quality then
            local _, sel_quality=string.match(selected_item[4][4][1], "(%a+-%a+).(%a+.+)")
            raw_string=sel_name.." ("..sel_quality..")"
        else
            raw_string=sel_name
        end
    else
        raw_string=selected_item
    end

    return raw_string
end

function getFirstFreeID(player)
    if storage.name_id_table[player.force.name]==nil then return 1 end

    for i=1, 4294967295, 1 do
        local isInTable=false

        for key, value in pairs(storage.name_id_table[player.force.name]) do
            if key==i then
                isInTable=true
            end
        end

        if not isInTable then
            return i
        end
    end
end

------------------------------------------------------------
-- GUI BUILD / DESTROY
------------------------------------------------------------

function destory_blc_gui(player)
    if player.gui.relative["blc.blc_frame"]~=nil then player.gui.relative["blc.blc_frame"].destroy() end
    if player.gui.relative.blc_frame~=nil then player.gui.relative.blc_frame.destroy() end
    if player.gui.screen.blc_frame~=nil then player.gui.screen.blc_frame.destroy() end
    if mod_gui.get_button_flow(player).blc_sprite_button~=nil then
        mod_gui.get_button_flow(player).blc_sprite_button.destroy()
    end
end

function create_mod_gui(player)
    mod_gui.get_button_flow(player).add({
        type="sprite-button",
        name="blc_sprite_button",
        tooltip={ "blc.blc_sprite_button_tooltip" },
        sprite="item/better-linked-chest",
        style="mod_gui_button"
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

        location.blc_frame.blc_titlebar.blc_filler.style.height=24
        location.blc_frame.blc_titlebar.blc_filler.style.horizontally_stretchable=true

        location.blc_frame.blc_titlebar.add{
            type="sprite-button",
            name="blc.close_button",
            style="frame_action_button",
            tooltip={"blc.close_instruction"},
            sprite="utility/close",
            hovered_sprite="utility/close_black",
            clicked_sprite="utility/close_black"
        }
    end

    location.blc_frame.add{
        type="drop-down",
        name="name_dropdown",
        tooltip={"blc.name_dropdown_tooltip"},
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
        tooltip={"blc.remove_button_tooltip"},
        caption={"blc.remove_button_cap"}
    }

    location.blc_frame.add{
        type="label",
        name="link_name_label",
        caption={"blc.link_name_label_cap"}
    }

    location.blc_frame.add{
        type="textfield",
        name="name_textfield",
        tooltip={"blc.name_textfield_tooltip"}
    }

    location.blc_frame.add{
        type="choose-elem-button",
        name="choose_elem_button",
        tooltip={"blc.choose_elem_tooltip"},
        style="slot_button",
        elem_type=script.feature_flags.quality and "item-with-quality" or "item"
    }

    location.blc_frame.add{
        type="label",
        name="link_id_label",
        caption={"blc.link_id_label_cap"}
    }

    location.blc_frame.add{
        type="textfield",
        name="id_textfield",
        tooltip={"blc.id_textfield_tooltip"}
    }

    location.blc_frame.add{
        type="button",
        name="add_button",
        tooltip={"blc.add_button_tooltip"},
        caption={"blc.add_button_cap"}
    }
end

function create_blc_gui(player)
    destory_blc_gui(player)
    create_mod_gui(player)
    create_setup_gui(player, player.gui.relative)
    create_setup_gui(player, player.gui.screen)

    blc_frame_rel=player.gui.relative.blc_frame
    name_dropdown_rel=blc_frame_rel.name_dropdown
    id_label_rel=blc_frame_rel.id_label
    link_name_label_rel=blc_frame_rel.link_name_label
    name_textfield_rel=blc_frame_rel.name_textfield
    choose_elem_button_rel=blc_frame_rel.choose_elem_button
    link_id_label_rel=blc_frame_rel.link_id_label
    id_textfield_rel=blc_frame_rel.id_textfield

    blc_frame_scr=player.gui.screen.blc_frame
    name_dropdown_scr=blc_frame_scr.name_dropdown
    id_label_scr=blc_frame_scr.id_label
    link_name_label_scr=blc_frame_scr.link_name_label
    name_textfield_scr=blc_frame_scr.name_textfield
    choose_elem_button_scr=blc_frame_scr.choose_elem_button
    link_id_label_scr=blc_frame_scr.link_id_label
    id_textfield_scr=blc_frame_scr.id_textfield

    fillDropdown(nil, player)
end