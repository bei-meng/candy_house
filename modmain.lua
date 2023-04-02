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
TUNING.WATER_BM=GetModConfigData("water")--降雨
TUNING.MUSIC_BM=GetModConfigData("music")--背景音乐
TUNING.BIRD_BM=GetModConfigData("bird")--鸟
TUNING.FARM_BM=GetModConfigData("farm")--农场
TUNING.CLOUD_BM=GetModConfigData("cloud")--云雾环绕
TUNING.HAMER_BM=GetModConfigData("hamer")--锤子
modimport("main/small_garden")
modimport("main/garden_tech")
modimport("scripts/modframework")
--------------------------------------------------------------------------------------花园入口的配方

-- env.AddRecipe2 = function(name, ingredients, tech, config, filters)
---------------------------------------------------------------------------------------制作栏图标
if TUNING.LANG_BM then
	STRINGS.UI.CRAFTING_STATION_FILTERS[string.upper("garden_exit")]="糖果屋改造"
	STRINGS.UI.CRAFTING_FILTERS.PLACER_PREFAB="糖果屋装饰"
	modimport("scripts/lang/zh_cn")
else
	STRINGS.UI.CRAFTING_STATION_FILTERS[string.upper("garden_exit")]="Candy House renovation"
	STRINGS.UI.CRAFTING_FILTERS.PLACER_PREFAB="Candy House decoration"
	modimport("scripts/lang/en_cn")
end
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
