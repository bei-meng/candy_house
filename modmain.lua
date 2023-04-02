GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
PrefabFiles = { 
    "garden_walls",--墙
    "garden_entrance",--入口
    "garden_exit",--出口
    "garden_floor",--地板核心
	"floors_prefab",
	"placer_prefab",--增加的建筑
	"garden_cloud"--云
}
Assets = {
	Asset("ATLAS", "images/inventoryimages/candyhouse.xml"),--花园的建筑图标
	Asset("ATLAS", "images/ui/candyhouse.xml"),--更改
	Asset("ATLAS", "images/ui/placer_prefab.xml"),--可建造物品
	Asset("ATLAS", "images/inventoryimages/addlevel.xml"),--增加等级
	Asset("ATLAS", "images/inventoryimages/carrot_bm.xml"),--胡萝卜
	Asset("ATLAS", "images/inventoryimages/lightninggoat_bm.xml"),--增加等级
}
TUNING.LANG_BM=GetModConfigData("language")
TUNING.LARGE_BM=GetModConfigData("large")--
TUNING.LIGHT_BM=GetModConfigData("light")--是否添加渲染光辉
TUNING.BUILD_BM=GetModConfigData("builder")--是否仅仅在室内可制作
TUNING.WATER_BM=GetModConfigData("water")--是否仅仅在室内可制作
TUNING.MUSIC_BM=GetModConfigData("music")--背景音乐
TUNING.BIRD_BM=GetModConfigData("bird")--鸟
TUNING.FARM_BM=GetModConfigData("farm")--农场
TUNING.CLOUD_BM=GetModConfigData("cloud")--云雾环绕
TUNING.HAMER_BM=GetModConfigData("hamer")--锤子
modimport("main/small_garden")
modimport("main/garden_tech")
--------------------------------------------------------------------------------------花园入口的配方
AddRecipe("garden_entrance", {Ingredient("cutstone", 5), Ingredient("honey", 10),Ingredient("boards", 5)},
RECIPETABS["TOWN"], TECH["SCIENCE_TWO"], "garden_entrance_placer", 2, nil, nil, nil, "images/inventoryimages/candyhouse.xml", "candyhouse.tex",
function (pt,rot)
	return not TheWorld.Map:IsGardenAtPoint(pt:Get())
end)
---------------------------------------------------------------------------------------制作栏图标
AddRecipeTab("GARDEN", 888, "images/ui/candyhouse.xml", "candyhouse.tex", nil, true)
AddRecipeTab("PLACER_PREFAB", 889, "images/ui/placer_prefab.xml", "placer_prefab.tex", nil, false)
if TUNING.LANG_BM then
	STRINGS.TABS.GARDEN="糖果屋改造"
	STRINGS.TABS.PLACER_PREFAB="糖果屋装饰"
	modimport("scripts/lang/zh_cn")
else
	STRINGS.TABS.GARDEN="Candy House renovation"
	STRINGS.TABS.PLACER_PREFAB="Candy House decoration"
	modimport("scripts/lang/en_cn")
end
local garden_tech=TECH.GARDEN_ONE--TECH.NONE
------------------------------------------------------------------------------------------等级提升
AddRecipe("addlevel", { Ingredient("cutstone", 10), Ingredient("boards", 10) },	CUSTOM_RECIPETABS.GARDEN, garden_tech,
nil, nil, true, nil, "garden_member","images/inventoryimages/candyhouse.xml","candyhouse.tex")
---------------------------------------------------------------------------------------地板配方表
local FLOOR_RECIPES =
{--rooo_turf","wddd_turf","caaa_turf","gsss_turf
	rooo_turf={
		ingredients = { Ingredient("turf_road", 10), Ingredient("rocks", 10) }, image = "turf_road",name="卵石地皮"
	},
	wddd_turf={
		ingredients = { Ingredient("turf_woodfloor", 10), Ingredient("log", 10) }, image = "turf_woodfloor",name="木地板"
	},
	caaa_turf={
		ingredients = { Ingredient("turf_carpetfloor", 10), Ingredient("beefalowool", 10) },	image = "turf_carpetfloor",name="地毯地板"
	},
	gsss_turf={
		ingredients = { Ingredient("turf_grass", 10), Ingredient("petals", 10) },	image = "turf_grass",name="草地皮"
	},--brrr_turf
	brrr_turf={
		ingredients = { Ingredient("turf_deciduous", 10), Ingredient("acorn", 10) },	image = "turf_deciduous",name="桦树地皮"
	},
}
--所有的变量，依序是name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image。
for prefab, data in pairs(FLOOR_RECIPES) do
	AddRecipe(prefab, data.ingredients,	CUSTOM_RECIPETABS.GARDEN, garden_tech,
	nil, nil, true, nil, "garden_member","images/inventoryimages2.xml", data.image .. ".tex")
end
----------------------------------------------------------------------------------------花园围墙
local WALL_RECIPES =
{
	wall1={
		ingredients = { Ingredient("wall_stone_item", 20), Ingredient("flint", 4) }, image = "wall_stone_item",name="石墙"
	},
	wall2={
		ingredients = { Ingredient("wall_stone_item", 20), Ingredient("flint", 4) }, image = "wall_stone_ancientitem",name="石墙"
	},
	wall3={
		ingredients = { Ingredient("wall_ruins_item", 20), Ingredient("flint", 4) },	image = "wall_ruins_item",name="铥矿墙"
	},
	wall4={
		ingredients = { Ingredient("wall_ruins_item", 20), Ingredient("flint", 4) }, image = "wall_ruins_thuleciteitem",name="铥矿墙"
	},
	wall5={
		ingredients = { Ingredient("wall_moonrock_item", 8), Ingredient("flint", 4) }, image = "wall_moonrock_item",name="月岩墙"
	},
	wall6={
		ingredients = { Ingredient("wall_wood_item", 20), Ingredient("flint", 4) }, image = "wall_wood_item",name="木墙"
	},
}
--所有的变量，依序是name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image。
for prefab, data in pairs(WALL_RECIPES) do
	AddRecipe(prefab, data.ingredients,	CUSTOM_RECIPETABS.GARDEN, garden_tech,
	nil, nil, true, nil, "garden_member","images/inventoryimages2.xml", data.image .. ".tex")
end

------------------------------------------------------------------------------------------相关建筑的制作
local tmptab=CUSTOM_RECIPETABS["PLACER_PREFAB"]
local needtag="garden_member"
if not TUNING.BUILD_BM then
	needtag=nil
end
--空心树桩
AddRecipe("test_build1", {Ingredient("coontail", 2), Ingredient("boards", 2),Ingredient("cutgrass", 5)},--猫尾巴2，木板2
tmptab, TECH.NONE, "catcoonden_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "catcoonden.png",nil,"catcoonden")
--高鸟巢穴
AddRecipe("tallbirdnest", {Ingredient("tallbirdegg", 2), Ingredient("cutgrass", 5)},--高鸟蛋，草
tmptab, TECH.NONE, "tallbirdnest_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "tallbirdnest.png")
--蜗牛巢穴
AddRecipe("test_build2", {Ingredient("slurtle_shellpieces", 4), Ingredient("slurtleslime", 5)},--壳碎片，黏液
tmptab, TECH.NONE, "slurtlehole_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "slurtle_den.png",nil,"slurtlehole")
--杀人蜂巢穴
AddRecipe("test_build3", {Ingredient("honeycomb", 1), Ingredient("honey", 5),Ingredient("killerbee", 2)},--蜂巢，蜂蜜，蜜蜂
tmptab, TECH.NONE, "wasphive_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "wasphive.png",nil,"wasphive")
--蜂巢
AddRecipe("test_build4", {Ingredient("honeycomb", 1), Ingredient("honey", 5),Ingredient("bee", 2)},--蜂巢，蜂蜜，蜜蜂
tmptab, TECH.NONE, "beehive_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "beehive.png",nil,"beehive")
--猴子桶
AddRecipe("test_build5", {Ingredient("cave_banana", 3), Ingredient("fertilizer",1),Ingredient("boards", 2)},--香蕉，便便桶，木板
tmptab, TECH.NONE, "monkeybarrel_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "monkeybarrel.png",nil,"monkeybarrel")
--池塘
AddRecipe("pond", {Ingredient("multitool_axe_pickaxe", 1), Ingredient("cutstone",3)},--多用斧，石砖
tmptab, TECH.NONE, "pond_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "pond.png")
--香蕉树
AddRecipe("cave_banana_tree", {Ingredient("cave_banana", 2), Ingredient("livinglog",2)},--香蕉2，活木2
tmptab, TECH.NONE, "cave_banana_tree_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "cave_banana_tree.png")
--大理石树
AddRecipe("marbletree", {Ingredient("marble",3)},--大理石树
tmptab, TECH.NONE, "marbletree_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "marbletree.png")
--晾肉架
AddRecipe("meatrack_hermit", {Ingredient("log", 5), Ingredient("livinglog",2)},--木头5，活木2
tmptab, TECH.NONE, "meatrack_hermit_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "meatrack_hermit.png")
--蜂巢
AddRecipe("beebox_hermit", {Ingredient("honeycomb", 1), Ingredient("boards",2),Ingredient("petals",5)},--蜂巢，木板，花瓣
tmptab, TECH.NONE, "beebox_hermit_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "beebox_hermitcrab.png")
--小牛
AddRecipe("test_build6", {Ingredient("beefalowool", 10), Ingredient("horn",1),Ingredient("nightmarefuel",5)},--牛毛牛角噩梦
tmptab, TECH.NONE, nil, 1, true, nil, needtag, "minimap/minimap_data.xml", "beefalo_domesticated.png",nil,"babybeefalo")
--电羊
AddRecipe("test_build7", {Ingredient("lightninggoathorn", 1), Ingredient("goatmilk",1),Ingredient("nightmarefuel",5)},--牛毛牛角噩梦
tmptab, TECH.NONE, nil, 1, true, nil, needtag, "images/inventoryimages/lightninggoat_bm.xml", "lightninggoat_bm.tex",nil,"lightninggoat")
--Ingredient("butterflywings", 1),
--蝴蝶
AddRecipe("test_build8", {Ingredient("petals",2)},--蝴蝶翅膀，花瓣2
tmptab, TECH.NONE, nil, 1, true, nil, needtag, "images/inventoryimages1.xml", "butterfly.tex",nil,"butterfly")
--蘑菇
AddRecipe("red_mushroom", {Ingredient("red_cap",2)},--蝴蝶翅膀，花瓣2
tmptab, TECH.NONE, "red_mushroom_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "mushroom_tree_med.png")

AddRecipe("green_mushroom", {Ingredient("green_cap",2)},--蝴蝶翅膀，花瓣2
tmptab, TECH.NONE, "green_mushroom_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "mushroom_tree_small.png")

AddRecipe("blue_mushroom", {Ingredient("blue_cap",2)},--蝴蝶翅膀，花瓣2
tmptab, TECH.NONE, "blue_mushroom_placer", 1, true, nil, needtag, "minimap/minimap_data.xml", "mushroom_tree.png")

AddRecipe("carrot_planted", {Ingredient("carrot",2)},--蝴蝶翅膀，花瓣2
tmptab, TECH.NONE, "carrot_planted_placer", 1, true, nil, needtag, "images/inventoryimages/carrot_bm.xml", "carrot_bm.tex")

AddRecipe("succulent_plant", {Ingredient("petals", 2)},--多肉
tmptab, TECH.NONE, "succulent_plant_placer", 1, true, nil, needtag, "images/inventoryimages2.xml", "succulent_picked.tex")

AddRecipe("dug_berrybush2", {Ingredient("dug_berrybush",1)},--蝴蝶翅膀，花瓣2
tmptab, TECH.NONE, nil, 1, true, nil, needtag, "images/inventoryimages1.xml", "dug_berrybush2.tex")


--berrybush2
-- red_mushroom
-- beebox_hermit
--babybeefalo
--marbletree	
--[[lightninggoat	butterfly	
	return MakePlacer("catcoonden_placer","catcoon_den","catcoon_den","idle"),                  --中空树桩
MakePlacer("tallbirdnest_placer","tallbird_egg","egg","eggnest"),                           --高脚鸟巢穴
MakePlacer("slurtlehole_placer","slurtle_mound","slurtle_mound","idle"),                    --蛞蝓鬼巢穴
MakePlacer("wasphive_placer","wasphive","wasphive","cocoon_small"),                         --杀人蜂巢穴
MakePlacer("beehive_placer","beehive","beehive","cocoon_small"),                            --蜂巢
MakePlacer("monkeybarrel_placer","barrel","monkey_barrel","idle"),                          --猴子
MakePlacer("pond_placer","marsh_tile","marsh_tile","idle"),                                 --池塘
MakePlacer("cave_banana_tree_placer","cave_banana_tree","cave_banana_tree","idle_loop"),    --香蕉树
MakePlacer("meatrack_hermit_placer","meatrack_hermit","meatrack_hermit","idle_empty")       --老奶奶的晾肉架
]]
--catcoonden--狸猫巢穴
--tallbirdnest	高脚鸟巢
--slurtlehole	蛞蝓龟窝
-- wasphive	杀人蜂蜂窝
--beehive蜂窝
--monkeybarrel	穴居猴桶
-- oceanvine_cocoon--海蜘蛛巢穴
--pond	普通池塘
--cave_banana_tree	洞穴香蕉树


-- dustmothden	整洁洞穴	--地下月光远古区的那个



--pond_cave	池塘--地下的
--pond_mos	池塘--沼泽的
-- critterlab	岩石巢穴--宠物的
-- if ent.userid == inst.owner or BM.Return(TheNet:GetClientTableForUser(ent.userid), "admin") then
-- 	ent:AddTag("basement_owner")
-- end

-- grue.lua:
--[[
    local function SetLightWatcherAdditiveThresh(ent, thresh)
	thresh = thresh or 0
    local lightval = ent.LightWatcher:GetLightValue()
	print("光照为多少",lightval)
	-- ent.LightWatcher:SetLightThresh(0.075 + thresh)
	-- ent.LightWatcher:SetDarkThresh(0.05 + thresh)
	-- ent.LightWatcher:SetLightThresh(1)
	-- ent.LightWatcher:SetDarkThresh(1)
	local lightThresh = ent.lightThresh or 0.1
	local darkThresh = ent.darkThresh or 0.05
	print("阈值",lightThresh,darkThresh)
	local x, y, z = ent.Transform:GetWorldPosition()
	local light = TheSim:GetLightAtPoint(x, y, z, lightThresh)
	print("当前位置阈值",light)
	local move_to_light = ent.inLight == false and light >= lightThresh

	-- if move_to_light or (ent.inLight ~= false and light <= darkThresh) then
	-- 	ent.inLight = move_to_light
	-- end
	-- ent.lightThresh=-1
	-- ent.darkThresh=-1.05
	-- ent.LightWatcher:SetLightThresh(0)
	-- ent.LightWatcher:SetMinLightThresh(-1) --for sanity.
	-- ent.LightWatcher:SetDarkThresh(0)
	lightval = ent.LightWatcher:GetLightValue()
	print("光照为多少",lightval)
end
]]
