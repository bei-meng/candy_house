-- 代码作者：ti_Tout
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
local _G = GLOBAL
local require = _G.require
local TechTree = require("techtree")
TechTree.Create = function(t)
	t = t or {}
	for i, v in ipairs(TechTree.AVAILABLE_TECH) do
	    t[v] = t[v] or 0
	end
	return t
end
-------------------------------------------------------------------------------
table.insert(TechTree.AVAILABLE_TECH, "GARDEN_TECH")	--其实就是加个自己的科技树名称
table.insert(TechTree.BONUS_TECH, "GARDEN_TECH")	--有奖励的科技树
_G.TECH.NONE.GARDEN_TECH = 0
_G.TECH.GARDEN_ONE={GARDEN_TECH = 1}
for k,v in pairs(TUNING.PROTOTYPER_TREES) do
    v.GARDEN_TECH = 0
end
TUNING.PROTOTYPER_TREES.GARDEN_TECH = TechTree.Create({GARDEN_TECH = 1})
-- AddPrefabPostInit("player_classified", function(inst)
-- 	inst.techtrees = _G.deepcopy(_G.TECH.NONE)
-- end)
for i, v in pairs(_G.AllRecipes) do
	if v.level.GARDEN_TECH == nil then
		v.level.GARDEN_TECH = 0
	end
end