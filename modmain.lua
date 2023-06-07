GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
PrefabFiles = { 
    "garden_walls",--墙
    "garden_entrance",--入口
    "garden_exit",--出口
    "garden_floor",--地板核心
	"floors_prefab",
	"placer_prefab",--增加的建筑
	"garden_cloud",--云
	"item",
	"garden_entrance_new",
	"garden_exit_new",
	"candy_chest",--水晶箱子
	"candy_ball",--水晶球
	"candy_tree",--糖果树
	"candy_cotton",--棉花果
	"sanregenbuff",--回san的buf
	"candy_entrance",--封住洞穴的东西
	"candy_log",--青红木
}
Assets = {
	Asset("ATLAS", "images/inventoryimages/candyhouse.xml"),--花园的建筑图标
	Asset("ATLAS", "images/inventoryimages/candyhouse1.xml"),--花园的建筑图标
	Asset("ATLAS", "images/ui/candyhouse.xml"),--更改
	Asset("ATLAS", "images/ui/placer_prefab.xml"),--可建造物品
	Asset("ATLAS", "images/inventoryimages/addlevel.xml"),--增加等级
	Asset("ATLAS", "images/inventoryimages/carrot_bm.xml"),--胡萝卜
	Asset("ATLAS", "images/inventoryimages/lightninggoat_bm.xml"),--增加等级
	Asset("ATLAS", "images/inventoryimages/candy_ball.xml"),--糖果球
	Asset("ATLAS", "images/inventoryimages/candy_turf.xml"),--地板

	Asset("ANIM", "anim/candy_chest.zip"),--树的动画

	Asset("ATLAS", "images/map_icons/candy_tree.xml"),--树
}
TUNING.LANG_BM=GetModConfigData("language")
TUNING.LARGE_BM=true--GetModConfigData("large")--
-- TUNING.LIGHT_BM=GetModConfigData("light")--是否添加渲染光辉
TUNING.WATER_BM=GetModConfigData("water")--降雨
TUNING.MUSIC_BM=GetModConfigData("music")--背景音乐
-- TUNING.BIRD_BM=GetModConfigData("bird")--鸟
TUNING.FARM_BM=GetModConfigData("farm")--农场
-- TUNING.CLOUD_BM=GetModConfigData("cloud")--云雾环绕
TUNING.HAMER_BM=GetModConfigData("hamer")--锤子
TUNING.BACK_BM=GetModConfigData("background")--是否显示背景
TUNING.NO_WEED=GetModConfigData("wedd_clear")--杂草去除
TUNING.NO_PERISH=GetModConfigData("no_perishable")--大作物不腐烂
modimport("main/small_garden")
modimport("main/garden_tech")
modimport("scripts/modframework")
modimport("main/chest")




-- local recipes_status,recipes_data = pcall(require,"resources/tang_recipes")
-- if recipes_status then
--     if recipes_data.Recipes then
--         for _,data in pairs(recipes_data.Recipes) do
-- 			RemoveRecipeFromFilter(data.name,"MODS")
--         end
--     end
-- end
-------------------------------------------------------------------------------小地图
AddMinimapAtlas("images/map_icons/candy_tree.xml")
---------------------------------------------------------------------------------------制作栏图标
if TUNING.LANG_BM then
	STRINGS.UI.CRAFTING_STATION_FILTERS[string.upper("garden_exit")]="改造"
	STRINGS.UI.CRAFTING_STATION_FILTERS[string.upper("garden_exit1")]="改造"
	STRINGS.UI.CRAFTING_FILTERS.CANDY_HOUSE="建筑"
	STRINGS.UI.CRAFTING_FILTERS.PLACER_PREFAB="装饰"
	modimport("scripts/lang/zh_cn")
else
	STRINGS.UI.CRAFTING_STATION_FILTERS[string.upper("garden_exit")]="renovation"
	STRINGS.UI.CRAFTING_STATION_FILTERS[string.upper("garden_exit1")]="renovation"
	STRINGS.UI.CRAFTING_FILTERS.CANDY_HOUSE="architecture"
	STRINGS.UI.CRAFTING_FILTERS.PLACER_PREFAB="decoration"
	modimport("scripts/lang/en_cn")
end



---用于标记打开的洞穴，用于缝补
AddPrefabPostInit("cave_entrance_open", function (inst)
	inst:AddTag("cave_entrance_open")
end)




if TUNING.NO_WEED then
	--针对杂草的消去效果
	local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
	for k, v in pairs(WEED_DEFS) do
		if not v.data_only then --allow mods to skip our prefab constructor.
			AddPrefabPostInit(v.prefab, function (inst)
				if TheWorld.ismastersim then
					inst:ListenForEvent("on_planted", function (inst,data)
						if inst:IsInGarden() then
							if data.in_soil then
								SpawnAt("farm_soil",inst:GetPosition())
							end
							inst:Remove()
						end
					end)
				end
			end)
		end
	end
end



if TUNING.NO_PERISH then
	--针对糖果屋内部的大作物不腐烂
	AddComponentPostInit("perishable",function (self)
		local old_fn=self.StartPerishing
		self.StartPerishing=function (self)
			old_fn(self)
			local inst= self.inst
			if inst and inst:IsInGarden() and inst:HasTag("heavy") and inst:HasTag("oversized_veggie") then
				inst:ListenForEvent("perishchange",function (inst)
					inst.components.perishable:StopPerishing()
				end)
				inst.components.perishable:StopPerishing()
			end
		end
	end)
end