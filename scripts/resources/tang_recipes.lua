-- filters = {"TOOLS", "LIGHT"}
--env.AddRecipe2 = function(name, ingredients, tech, config, filters)
-- name, ingredients, tab, level, placer, min_spacing, nounlock,numtogive, builder_tag, atlas, image, testfn
local Recipes = {
    ------------------------------------建筑
    {--入口
        name="garden_entrance",
        ingredients={
            Ingredient("cutstone", 5),
            Ingredient("honey", 10),
            Ingredient("boards", 5)
        },
        level=TECH.SCIENCE_TWO,
        config={
            placer="garden_entrance_placer",
            min_spacing=2,
            atlas = "images/inventoryimages/candyhouse.xml",
            image="candyhouse.tex",
            testfn=function (pt,rot)
                return not TheWorld.Map:IsGardenAtPoint(pt:Get())
            end
        },
        filters={"CANDY_HOUSE"},
    },
    {--入口
        name="garden_entrance1",
        ingredients={
            Ingredient("cutstone", 5),
            Ingredient("honey", 10),
            Ingredient("boards", 5)
        },
        level=TECH.SCIENCE_TWO,
        config={
            placer="garden_entrance1_placer",
            min_spacing=2,
            atlas = "images/inventoryimages/candyhouse1.xml",
            image="candyhouse1.tex",
            testfn=function (pt,rot)
                return not TheWorld.Map:IsGardenAtPoint(pt:Get())
            end
        },
        filters={"CANDY_HOUSE"},
    },
    {--水晶盒
        name="candy_ball",
        ingredients={
            Ingredient("candy_log", 2,"images/inventoryimages/candy_log.xml"),
            Ingredient("boards", 3),
            Ingredient("crystal_ball", 1,"images/inventoryimages/crystal_ball.xml")
        },
        level=TECH.SCIENCE_TWO,
        config={
            placer="candy_ball_placer",
            min_spacing=2,
            atlas = "images/inventoryimages/candy_ball.xml",
            image="candy_ball.tex",
            -- testfn=function (pt,rot)
            --     return not TheWorld.Map:IsGardenAtPoint(pt:Get())
            -- end
        },
        filters={"CANDY_HOUSE"},
    },
    {--青红树
        name="candy_tree1",
        ingredients={
            -- Ingredient("palmcone_seed", 3),
            Ingredient("pinecone",5),
            Ingredient("acorn", 5),
            Ingredient("honey", 5),
        },
        level=TECH.SCIENCE_TWO,
        config={
            placer="candy_tree_placer",
            min_spacing=2,
            atlas = "images/inventoryimages/candy_tree.xml",
            image="candy_tree.tex",
            -- testfn=function (pt,rot)
            --     return not TheWorld.Map:IsGardenAtPoint(pt:Get())
            -- end
            product="candy_tree"
        },
        filters={"CANDY_HOUSE"},
    },
    {--封堵
        name="candy_entrance",
        ingredients={
            Ingredient("flint", 10),
            Ingredient("rocks", 10),
            Ingredient("candy_log", 1,"images/inventoryimages/candy_log.xml")
        },
        level=TECH.SCIENCE_TWO,
        config={
            placer="candy_entrance_placer",
            min_spacing=0,
            atlas = "images/inventoryimages/candy_closed.xml",
            image="candy_closed.tex",
            testfn=function (pt,rot)
                local x,y,z=TheWorld.Map:GetTileCenterPoint(pt:Get())
                local ents = TheSim:FindEntities(x,y,z,4,{"cave_entrance_open"})
                return #ents==1
            end
        },
        filters={"CANDY_HOUSE"},
    },
    {--水晶球
        name="crystal_ball",
        ingredients={
            Ingredient("honey", 3),
            Ingredient("moonglass", 2),
            Ingredient("candy_cotton", 1,"images/inventoryimages/candy_cotton.xml"),
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages/crystal_ball.xml",
            image="crystal_ball.tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    },
    {--升级
        name="addlevel",
        ingredients={
            Ingredient("cutstone", 5),
            Ingredient("boards", 5),
            Ingredient("candy_log", 3,"images/inventoryimages/candy_log.xml")
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages/addlevel.xml",
            image="addlevel.tex",
            nounlock=true,
            testfn=function (pt,rot)
                return TheWorld.Map:IsGardenAtPoint(pt:Get())
            end
        },
        filters={"CRAFTING_STATION"},
    },
    ---------------------------------------各种地皮
    -- {--卵石地板
    --     name="rooo_turf",
    --     ingredients={
    --         Ingredient("turf_road", 10),
    --         Ingredient("rocks", 10)
    --     },
    --     level=TECH.GARDEN_ONE,
    --     config={
    --         atlas = "images/inventoryimages2.xml",
    --         image="turf_road.tex",
    --     },
    --     filters={"CRAFTING_STATION"},
    -- },
    -- {--木地板
    --     name="wddd_turf",
    --     ingredients={
    --         Ingredient("turf_woodfloor", 10),
    --         Ingredient("log", 10)
    --     },
    --     level=TECH.GARDEN_ONE,
    --     config={
    --         atlas = "images/inventoryimages2.xml",
    --         image="turf_woodfloor.tex",
    --     },
    --     filters={"CRAFTING_STATION"},
    -- },
    -- {--地毯地板
    --     name="caaa_turf",
    --     ingredients={
    --         Ingredient("turf_carpetfloor", 10),
    --         Ingredient("beefalowool", 10)
    --     },
    --     level=TECH.GARDEN_ONE,
    --     config={
    --         atlas = "images/inventoryimages2.xml",
    --         image="turf_carpetfloor.tex",
    --     },
    --     filters={"CRAFTING_STATION"},
    -- },
    -- {--草地皮
    --     name="gsss_turf",
    --     ingredients={
    --         Ingredient("turf_grass", 10),
    --         Ingredient("petals", 10)
    --     },
    --     level=TECH.GARDEN_ONE,
    --     config={
    --         atlas = "images/inventoryimages2.xml",
    --         image="turf_grass.tex",
    --     },
    --     filters={"CRAFTING_STATION"},
    -- },
    -- {--桦树地皮
    --     name="brrr_turf",
    --     ingredients={
    --         Ingredient("turf_deciduous", 10),
    --         Ingredient("acorn", 10)
    --     },
    --     level=TECH.GARDEN_ONE,
    --     config={
    --         atlas = "images/inventoryimages2.xml",
    --         image="turf_deciduous.tex",
    --     },
    --     filters={"CRAFTING_STATION"},
    -- },
    {--石墙
        name="wall1",
        ingredients={
            Ingredient("wall_stone_item", 20),
            Ingredient("flint", 4)
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages2.xml",
            image="wall_stone_item.tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    },
    {--石墙
        name="wall2",
        ingredients={
            Ingredient("wall_stone_item", 20),
            Ingredient("flint", 4)
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages2.xml",
            image="wall_stone_ancientitem.tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    }, 
    {--铥矿墙
        name="wall3",
        ingredients={
            Ingredient("wall_ruins_item", 20),
            Ingredient("flint", 4)
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages2.xml",
            image="wall_ruins_item.tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    },
    {--铥矿墙
        name="wall4",
        ingredients={
            Ingredient("wall_ruins_item", 20),
            Ingredient("flint", 4)
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages2.xml",
            image="wall_ruins_thuleciteitem.tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    },
    {--月岩墙
        name="wall5",
        ingredients={
            Ingredient("wall_moonrock_item", 20),
            Ingredient("flint", 4)
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages2.xml",
            image="wall_moonrock_item.tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    },
    {--木墙
        name="wall6",
        ingredients={
            Ingredient("wall_wood_item", 20),
            Ingredient("flint", 4)
        },
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages2.xml",
            image="wall_wood_item.tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    },

    ------------------------------------------------装饰物品
    {--空心树桩
        name="test_build1",
        ingredients={
            Ingredient("coontail", 2),--猫尾巴2
            Ingredient("boards", 2),--木板
            Ingredient("cutgrass", 5),--草
        },
        level=TECH.NONE,
        config={
            atlas = "minimap/minimap_data.xml",
            image="catcoonden.png",
            placer="catcoonden_placer",
            product="catcoonden",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--高鸟巢穴
        name="tallbirdnest",
        ingredients={
            Ingredient("tallbirdegg", 2),--高脚鸟蛋
            Ingredient("cutgrass", 5),
        },
        level=TECH.NONE,
        config={
            atlas = "minimap/minimap_data.xml",
            image="tallbirdnest.png",
            placer="tallbirdnest_placer",
            product="tallbirdnest",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--蜗牛巢穴
        name="test_build2",
        ingredients={
            Ingredient("slurtle_shellpieces", 4),--壳碎片
            Ingredient("slurtleslime", 5)--黏液
        },
        level=TECH.NONE,
        config={
            atlas = "minimap/minimap_data.xml",
            image="slurtle_den.png",
            placer="slurtlehole_placer",
            product="slurtlehole",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--杀人蜂巢穴
        name="test_build3",
        ingredients={
            Ingredient("honeycomb", 1),--蜂巢
            Ingredient("honey", 5),
            Ingredient("killerbee", 2)
        },
        level=TECH.NONE,
        config={
            atlas = "minimap/minimap_data.xml",
            image="wasphive.png",
            placer="wasphive_placer",
            product="wasphive",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--蜂巢
        name="test_build4",
        ingredients={
            Ingredient("honeycomb", 1),--蜂巢
            Ingredient("honey", 5),
            Ingredient("bee", 2)
        },
        level=TECH.NONE,
        config={
            atlas = "minimap/minimap_data.xml",
            image="beehive.png",
            placer="beehive_placer",
            product="beehive",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--猴子桶
        name="test_build5",
        ingredients={--香蕉，便便桶，木板
            Ingredient("cave_banana", 3),
            Ingredient("fertilizer",1),
            Ingredient("boards", 2)
        },
        level=TECH.NONE,
        config={
            placer="monkeybarrel_placer",
            atlas = "minimap/minimap_data.xml",
            image="monkeybarrel.png",
            product="monkeybarrel",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--池塘
        name="pond",
        ingredients={--多用斧，石砖
            Ingredient("multitool_axe_pickaxe", 1), 
            Ingredient("cutstone",3)
        },
        level=TECH.NONE,
        config={
            placer="pond_placer",
            atlas = "minimap/minimap_data.xml",
            image="pond.png",
            -- product="pond",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--香蕉树
        name="cave_banana_tree",
        ingredients={--香蕉2，活木2
            Ingredient("cave_banana", 2),
            Ingredient("livinglog",2)
        },
        level=TECH.NONE,
        config={
            placer="cave_banana_tree_placer",
            atlas = "minimap/minimap_data.xml",
            image="cave_banana_tree.png",
            -- product="pond",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--大理石树
        name="marbletree",
        ingredients={----大理石
            Ingredient("marble",3)
        },
        level=TECH.NONE,
        config={
            placer="marbletree_placer",
            atlas = "minimap/minimap_data.xml",
            image="marbletree.png",
            -- product="pond",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--大理石树
        name="meatrack_hermit",
        ingredients={----大理石
            Ingredient("log", 5),
            Ingredient("livinglog",2)
        },
        level=TECH.NONE,
        config={
            placer="meatrack_hermit_placer",
            atlas = "minimap/minimap_data.xml",
            image="meatrack_hermit.png",
            -- product="pond",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--老奶奶蜂巢
        name="beebox_hermit",
        ingredients={--蜂巢，木板，花瓣
            Ingredient("honeycomb", 1),
            Ingredient("boards",2),
            Ingredient("petals",5)
        },
        level=TECH.NONE,
        config={
            placer="beebox_hermit_placer",
            atlas = "minimap/minimap_data.xml",
            image="beebox_hermitcrab.png",
            -- product="pond",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--小牛
        name="test_build6",
        ingredients={--牛毛牛角噩梦
            Ingredient("beefalowool", 10),
            Ingredient("horn",1),
            Ingredient("nightmarefuel",5)
        },
        level=TECH.NONE,
        config={
            -- placer="meatrack_hermit_placer",
            atlas = "minimap/minimap_data.xml",
            image="beefalo_domesticated.png",
            product="babybeefalo",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--电羊
        name="test_build7",
        ingredients={--牛毛牛角噩梦
            Ingredient("lightninggoathorn", 1),
            Ingredient("goatmilk",1),
            Ingredient("nightmarefuel",5)
        },
        level=TECH.NONE,
        config={
            -- placer="meatrack_hermit_placer",
            atlas = "images/inventoryimages/lightninggoat_bm.xml",
            image="lightninggoat_bm.tex",
            product="lightninggoat",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--蝴蝶
        name="test_build8",
        ingredients={--花瓣
            Ingredient("petals",2)
        },
        level=TECH.NONE,
        config={
            -- placer="meatrack_hermit_placer",
            atlas = "images/inventoryimages1.xml",
            image="butterfly.tex",
            product="butterfly",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--蘑菇
        name="red_mushroom",
        ingredients={--花瓣
            Ingredient("red_cap",2)
        },
        level=TECH.NONE,
        config={
            placer="red_mushroom_placer",
            atlas = "minimap/minimap_data.xml",
            image="mushroom_tree_med.png",
            -- product="butterfly",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--蘑菇
        name="green_mushroom",
        ingredients={--花瓣
            Ingredient("green_cap",2)
        },
        level=TECH.NONE,
        config={
            placer="green_mushroom_placer",
            atlas = "minimap/minimap_data.xml",
            image="mushroom_tree_small.png",
            -- product="butterfly",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--蘑菇
        name="blue_mushroom",
        ingredients={--花瓣
            Ingredient("blue_cap",2)
        },
        level=TECH.NONE,
        config={
            placer="blue_mushroom_placer",
            atlas = "minimap/minimap_data.xml",
            image="mushroom_tree.png",
            -- product="butterfly",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--胡萝卜
        name="carrot_planted",
        ingredients={--花瓣
            Ingredient("carrot",2)
        },
        level=TECH.NONE,
        config={
            placer="carrot_planted_placer",
            atlas = "images/inventoryimages/carrot_bm.xml",
            image="carrot_bm.tex",
            -- product="butterfly",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--多肉
        name="succulent_plant",
        ingredients={--花瓣
            Ingredient("petals",2)
        },
        level=TECH.NONE,
        config={
            placer="succulent_plant_placer",
            atlas = "images/inventoryimages2.xml",
            image="succulent_picked.tex",
            -- product="butterfly",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
    {--多肉
        name="dug_berrybush2",
        ingredients={--花瓣
            Ingredient("dug_berrybush",1)
        },
        level=TECH.NONE,
        config={
            -- placer="succulent_plant_placer",
            atlas = "images/inventoryimages1.xml",
            image="dug_berrybush2.tex",
            -- product="butterfly",
            min_spacing=1,
        },
        filters={"CANDY_HOUSE"},
    },
}
local turf=require"def/floor_def"
for k,v in pairs(turf) do
    ---------------------------------------------------------------主地皮
    --配方材料
    local ingredients_tmp={}
    for name,num in pairs(v.materials)do
        table.insert(ingredients_tmp,Ingredient(name,num))
    end
    --配方
    table.insert(Recipes,{
        name=k.."_turf",
        ingredients=ingredients_tmp,
        level=TECH.GARDEN_ONE,
        config={
            atlas = "images/inventoryimages/candy_turf.xml",
            image=k..".tex",
            nounlock=true,
        },
        filters={"CRAFTING_STATION"},
    })
end
if TUNING.BACK_BM then
    for k,v in pairs(turf) do
        ---------------------------------------------------------------背景
        --配方材料
        local ingredients_tmp={}
        ingredients_tmp={}
        for name,num in pairs(v.materials)do
            table.insert(ingredients_tmp,Ingredient(name,num/2))
        end
        --配方
        table.insert(Recipes,{
            name=k.."_back",
            ingredients=ingredients_tmp,
            level=TECH.GARDEN_ONE,
            config={
                atlas = "images/inventoryimages/candy_turf.xml",
                image=k..".tex",
                nounlock=true,
            },
            filters={"CRAFTING_STATION"},
        })
    end
end

local IngredientValues = {
    -- {
    --     names = {"card"}, -- prefab名，可以设置多个
    --     tags = {fruit = 1}, -- 属性值，可以设置多个
    --     cancook = false, -- 是否可以烹饪
    --     candry = false -- 是否可以晾干
    -- },
    -- {
    --     names = {"seeds"}, -- prefab名，可以设置多个
    --     tags = {seeds = 1}, -- 属性值，可以设置多个
    --     cancook = true, -- 是否可以烹饪
    --     candry = false -- 是否可以晾干
    -- },
    -- {
    --     names = {"beardhair"}, -- prefab名，可以设置多个
    --     tags = {beardhair = 1}, -- 属性值，可以设置多个
    --     cancook = true, -- 是否可以烹饪
    --     candry = false -- 是否可以晾干
    -- },
}
return {Recipes = Recipes, IngredientValues = IngredientValues}
