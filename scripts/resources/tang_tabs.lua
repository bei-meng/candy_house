local Recipetabs = {
-- filter_def.name: This is the filter's id and will need the string added to STRINGS.UI.CRAFTING_FILTERS[name]
-- filter_def.atlas: atlas for the icon,  can be a string or function
-- filter_def.image: icon to show in the crafting menu, can be a string or function
-- filter_def.image_size: (optional) custom image sizing 
-- filter_def.custom_pos: (optional) This will not be added to the grid of filters
-- filter_def.recipes: !This is not supported! Create the filter and then pass in the filter to AddRecipe2() or AddRecipeToFilter()
-- AddRecipeFilter = function(filter_def, index)
-- AddPrototyperDef = function(prototyper_prefab, data)
    -- {--一些装饰物品
    --     filter_def={
    --         name = "PLACER_PREFAB",
    --         atlas = "images/ui/placer_prefab.xml",
    --         image = "placer_prefab.tex",
    --         image_size=62,
    --         custom_pos=nil,
    --         recipes=nil,
    --     },
    --     -- sort = 23,
    -- },
    {--一些装饰物品
        filter_def={
            name = "CANDY_HOUSE",
            atlas = "images/ui/candyhouse.xml",
            image = "candyhouse.tex",
            image_size=64,
            custom_pos=nil,
            recipes=nil,
        },
        -- sort = 23,
    },
    {--糖果屋改造的
        prototyper_prefab="garden_exit",
        data={
            icon_atlas = "images/ui/candyhouse.xml",
            icon_image = "candyhouse.tex",
            is_crafting_station = true,
            -- action_str = "CRITTERS",
            -- filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.GARDEN_EXIT,
        }
    },
    {--糖果屋改造的
        prototyper_prefab="garden_exit1",
        data={
            icon_atlas = "images/ui/candyhouse.xml",
            icon_image = "candyhouse.tex",
            is_crafting_station = true,
            -- action_str = "CRITTERS",
            -- filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.GARDEN_EXIT,
        }
    },
}

return {
    Recipetabs = Recipetabs,
}