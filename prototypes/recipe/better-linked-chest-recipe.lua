if settings.startup["better-linked-chest-crafting-cost"].value~=nil then
    local val = settings.startup["better-linked-chest-crafting-cost"].value
    local blc_recipe
    if val=="easy" then
      blc_recipe = {
          {"iron-plate", 20}
      }
    elseif val=="medium" then
      blc_recipe = {
          {"steel-chest", 10},
          {"iron-plate", 100},
          {"copper-plate", 100},
          {"electronic-circuit", 50},
      }
    elseif val=="hard" then
      blc_recipe = {
          {"steel-chest", 20},
          {"iron-plate", 100},
          {"copper-plate", 100},
          {"advanced-circuit", 50},
          {"processing-unit", 10}
      }
    end
    data:extend({  
    {
        type = "recipe",
        name = "better-linked-chest",
        enabled = false,
        ingredients = blc_recipe,
        result = "better-linked-chest"
    }
    })
end