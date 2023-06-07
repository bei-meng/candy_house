GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
BM={
    --hook旧函数
    SequenceFn = function(root, key, new_key,includeall_date)
		if type(root) ~= "table" then return end
		local old_fn = root[key]
        root[key] = function(...)
            local data ={old_fn(...)}
			local data_return=includeall_date and data or data[1]
            for i,v in ipairs({new_key(data_return, ...) }) do
                data[i] = v
            end
            return unpack(data)
        end
	end,
    --替换函数，能还原的
    Replace = function(root, key, replace)
		if type(root) ~= "table" then
			return
		end
		
		if replace ~= nil then
			if rawget(root, "__"..key) == nil then
				rawset(root, "__"..key, root[key])
			end
			root[key] = replace
		elseif rawget(root, "__"..key) ~= nil then
			root[key] = root["__"..key]
			root["__"..key] = nil
		end
	end,
    --划分矩形地区--可选是否仅仅边界
    Rectangle=function (grid, centered, getall, step)
        --grid为输入的字符串10X10
        --centered
        --getall为得到所有点的位置，或者仅仅周围建墙的位置
        local _x, _z = grid:match("(%d+)x(%d+)")
        _x, _z=_x-1,_z-1
        local data = {_x,_z}--存储边界，用来建墙
        table.insert(data, 0)--把0插入data
        --0->1，_x->2,_z->3
        data = table.invert(data)--反转--k,v-----------v,k
        local t = {}
        step=step or 1

        local offset = {x = 0, z = 0}
        if centered then
            offset.x = (_x+1) / 2
            offset.z = (_z+1) / 2
        end
        for x = 0, _x, step do
            for z = 0, _z, step do
                if getall or data[x] or data[z] then--得到所有瓷砖或者得到建墙的位置
                    table.insert(t, { x = x - offset.x, z = z - offset.z })
                end
            end
        end
        return t
    end,
}
rawset(GLOBAL, "BM", BM)
BM = GLOBAL.BM
-----------------------------------------------------------------------------------------------一些常量
local GARDEN_TILES = {}                 --花园的
local NU_GARDEN_TILES = {}              --用于营养物质的
TUNING.GARDEN =
{
	SANITYAURA = GetModConfigData("sanity") or -5,--降sanity的作用
	INSULATION = GetModConfigData("temperature") or -25,--降温作用
	MIST_DENSITY = GetModConfigData("mist") or 1,--迷雾
}
local CUSTOM_GARDEN_WORLD_STATE =
{
	DATA =
	{
		phase =	"day",
		cavephase =	"day",
		moonphase = "new",
        isnewmoon=true,
        isfullmoon=false,

		season = "autumn",
		iswinter = false,
		isspring = false,
		issummer = false,
		isautumn = true,

		isday = true,
        -- startday=
		isdusk = false,
		isnight = false,
		iscaveday = true,
		iscavedusk = false,
		iscavenight	= false,
	},
    NIGHT =
	{
		phase =	"night",
		cavephase =	"night",
		moonphase = "new",
        isnewmoon=true,
        isfullmoon=false,

		season = "autumn",
		iswinter = false,
		isspring = false,
		issummer = false,
		isautumn = true,

		isday = false,
        -- startday=
		isdusk = true,
		isnight = true,
		iscaveday = false,
		iscavedusk = true,
		iscavenight	= true,
	},
	STACK = 0,--用来保持不会多次压入
}

--压入世界状态
local prefablist={
    day={
        flower=true,--花冬天产生蝴蝶
        pighouse=true,--猪屋--不变疯猪
        pigman=true,--猪--不变疯猪
        beebox=true,
        grass=true,--冬天也长
        berries_juicy=true,--冬天也长
        berrybush2=true,
        berrybush=true,--浆果丛
        sapling=true,--树苗
        sapling_moon=true,--树苗
        deciduoustree=true,--桦木树
        red_mushroom=true,--红蘑菇
        reeds=true,--芦苇，如果有移植的话
        birdcage=true,--鸟笼
        beehive=true,--野外的蜂巢
        pond=true,--池塘
        beebox_hermit=true,
    },
    night={
        fireflies=true,
        pumpkin_lantern=true,
        green_mushroom=true,--绿蘑菇
        blue_mushroom=true,--蓝蘑菇
    }
}
--改变世界状态
function BM.PushGardenWorldState()
	CUSTOM_GARDEN_WORLD_STATE.STACK = CUSTOM_GARDEN_WORLD_STATE.STACK + 1
	if CUSTOM_GARDEN_WORLD_STATE.STACK > 1 then
		return
	end

	local state = {}
    for k,v in pairs(TheWorld.state) do
        if CUSTOM_GARDEN_WORLD_STATE.DATA[k] ~= nil then
            state[k] = CUSTOM_GARDEN_WORLD_STATE.DATA[k]
        else
            state[k] = v
        end
    end
	BM.Replace(TheWorld, "state", state)
end
--恢复原来的世界状态
function BM.PopGardenWorldState()
	CUSTOM_GARDEN_WORLD_STATE.STACK = math.max(CUSTOM_GARDEN_WORLD_STATE.STACK - 1, 0)
	if CUSTOM_GARDEN_WORLD_STATE.STACK > 1 then
		return
	end
	BM.Replace(TheWorld, "state")
end
-----------------------------------------------------------------------------------------------
-------------------------------[[配方禁止]]-----------------------------------------------------
-----------------------------------------------------------------------------------------------
------替换配方的testfn
-- local function MakeRecipeInvalidInGarden(name)
-- 	local recipe = AllRecipes[name]
-- 	if recipe ~= nil then
-- 		BM.Replace(recipe, "testfn", function (pt, rot)
--             return not TheWorld.Map:IsGardenAtPoint(pt:Get())
--         end)
-- 	end
-- end
-- local prefablist={
--     --"garden_entrance"-- "pighouse", "rabbithouse", "telebase","boat_item"
-- }
-- --禁止的配方
-- for i,v in ipairs(prefablist) do
-- 	MakeRecipeInvalidInGarden(v)
-- end
---------------------------------------------------------------------------------------------------
--------------------------------------[[ 地图组件的更改 ]]------------------------------------------
---------------------------------------------------------------------------------------------------
require "components/map"
--用来标记花园的瓷砖
local function GetInteriorTileKey(x,y,z)
    -- local x,z = TheWorld.Map:GetTileCoordsAtPoint(x,y,z)--获取点上的平铺坐标
    x,y,z=math.floor((x)/4), 0, math.floor((z)/4)
	return x.."_"..z
end

local function GetInteriorTileKey_floor(x,y,z)
    x,z = TheWorld.Map:GetTileCoordsAtPoint(x,y,z)--获取点上的平铺坐标
	return x.."_"..z
end
Map.IsGardenAtPoint = function (self,x, y, z)
	return GARDEN_TILES[GetInteriorTileKey(x, y, z)]
end

Map.IsGardenAtPoint_floor = function (self,x, y, z)--用于种地
	return NU_GARDEN_TILES[GetInteriorTileKey_floor(x, y, z)]
end
--------------------------------------------------------------是不是可通行的点
local function IsPassableAtPoint(x, y, z)
    if type(x)~="number"then
        x,y,z=x.x or x,x.y or y,x.z or z
    end
    return GARDEN_TILES[GetInteriorTileKey(x, y, z)] ~= nil
end
--得到瓷砖中心点
local old_GetTileCenterPoint =	Map.GetTileCenterPoint
Map.GetTileCenterPoint= function(self, x, y, z)
    local map_width, map_height = TheWorld.Map:GetSize()
    if (type(x)=="number" and math.abs(x)>=map_width) and (type(z)=="number" and math.abs(z)>=map_height) then
        return math.floor((x)/4)*4+2, 0, math.floor((z)/4)*4+2
    end
    if z then
        return old_GetTileCenterPoint(self, x,y,z)
    else
        return old_GetTileCenterPoint(self, x,y)
    end
end
--是否可通行
local old_IsPassableAtPoint=Map.IsPassableAtPoint
Map.IsPassableAtPoint= function(self, x, y, z,...)
    return old_IsPassableAtPoint(self,x,y,z,...) or IsPassableAtPoint(x, y, z)
end
--在该点处是否可见
local old_IsVisualGroundAtPoint=Map.IsVisualGroundAtPoint
Map.IsVisualGroundAtPoint= function(self, x, y, z,...)
    return old_IsVisualGroundAtPoint(self, x,y,z,...) or IsPassableAtPoint(x, y, z)
end
--是否在地面上
local old_IsAboveGroundAtPoint=Map.IsAboveGroundAtPoint
Map.IsAboveGroundAtPoint= function(self, x, y, z,...)
    return old_IsAboveGroundAtPoint(self, x,y,z,...) or IsPassableAtPoint(x, y, z)
end
--能否展开--蜘蛛巢的
-- local old_CanDeployAtPoint=Map.CanDeployAtPoint
-- Map.CanDeployAtPoint= function(self, pt,...)
--     return old_CanDeployAtPoint(self,pt,...) or IsPassableAtPoint(pt.x, pt.y, pt.z)
-- end
-- --能不能放桅杆
-- local old_CanDeployMastAtPoint=Map.CanDeployMastAtPoint
-- Map.CanDeployMastAtPoint= function(self,pt,...)
--     return old_CanDeployMastAtPoint(self,pt,...) or IsPassableAtPoint(pt.x, pt.y, pt.z)
-- end
--能不能种植物
local old_CanPlantAtPoint=Map.CanPlantAtPoint
Map.CanPlantAtPoint= function(self,x,y,z,...)
    return old_CanPlantAtPoint(self,x,y,z,...) or IsPassableAtPoint(x, y, z)
end
--能不能产生耕地堆
local old_CanTillSoilAtPoint=Map.CanTillSoilAtPoint
Map.CanTillSoilAtPoint= function(self, x, y, z,ignore_tile_type,...)
    if IsPassableAtPoint(x,y,z) then
        return old_CanTillSoilAtPoint(self, x,y,z,true,...)
    else
        return old_CanTillSoilAtPoint(self, x,y,z,ignore_tile_type,...)
    end
end
-- --是否是正常的地皮
-- local old_IsValidTileAtPoint=Map.IsValidTileAtPoint
-- Map.IsValidTileAtPoint=function (self,x, y, z)
--     return old_IsValidTileAtPoint(self, x,y,z) or IsPassableAtPoint(x, y, z)
-- end

-- --能否挖地皮
-- local old_CanTerraformAtPoint=Map.CanTerraformAtPoint
-- Map.CanTerraformAtPoint=function(self,x, y, z)
--     return old_CanTerraformAtPoint(self, x,y,z) or IsPassableAtPoint(x, y, z)
-- end

-- --可以放地皮
-- local old_CanPlaceTurfAtPoint=Map.CanPlaceTurfAtPoint
-- Map.CanPlaceTurfAtPoint=function(self,x, y, z)
--     return old_CanPlaceTurfAtPoint(self, x,y,z) or IsPassableAtPoint(x, y, z)
-- end

-- BM.SequenceFn(Map, "IsPassableAtPoint",IsPassableAtPoint)           --是否可通行
-- BM.SequenceFn(Map, "IsVisualGroundAtPoint", IsPassableAtPoint)      --在该点处是否可见
-- BM.SequenceFn(Map, "IsAboveGroundAtPoint", IsPassableAtPoint)       --是否在地面上
-- BM.Replace(Map, "GetTileCenterPoint", GetTileCenterPoint)  --得到瓷砖中心点
-- BM.SequenceFn(Map,"CanDeployAtPoint",IsPassableAtPoint)             --能否展开
-- BM.SequenceFn(Map,"CanDeployMastAtPoint",IsPassableAtPoint)			--能不能放桅杆
-- BM.SequenceFn(Map,"CanDeployPlantAtPoint",IsPassableAtPoint)        --能不能种植物
-- BM.SequenceFn(Map,"CanTillSoilAtPoint",IsPassableAtPoint)        --能不能种植物


-- map.IsFarmableSoilAtPoint(x, y, z)								--能否种地

-- BM.SequenceFn(Map,"CanDeployAtPointInWater",IsPassableAtPoint)

--------------------------------------------------------------添加自己的瓷砖
BM.Map={}
--记录哪里是对应的小房子的地皮--用于限制玩家的位置
BM.Map.AddSyntTile=function(x, y, z, source)
	if TheWorld.Map:GetTileAtPoint(x, y, z) == GROUND.INVALID then
		GARDEN_TILES[GetInteriorTileKey(x, y, z)] = source or true
        NU_GARDEN_TILES[GetInteriorTileKey_floor(x, y, z)] = source or true
	end
end
--记录哪里是对应的小房子的地皮
BM.Map.AddMySyntTile=function(x, y, z, source)
	if TheWorld.Map:GetTileAtPoint(x, y, z) == GROUND.INVALID then
		NU_GARDEN_TILES[GetInteriorTileKey(x, y, z)] = source or true
	end
end
--清除对应的地皮
BM.Map.RemoveSyntTile=function(...)
	GARDEN_TILES[GetInteriorTileKey(...)] = nil
	NU_GARDEN_TILES[GetInteriorTileKey_floor(...)] = nil
end
BM.Map.ClearSyntTiles=function()GARDEN_TILES = {}end

--------------------------------------------------------------------------------------------
----------------------------------[[ entityscript ]]----------------------------------------
--------------------------------------------------------------------------------------------
require("entityscript")
--实体是否在虚空的房间里面
function EntityScript:IsInGarden()
	return TheWorld.Map:IsGardenAtPoint(self:GetPosition():Get())
end
--推入事件
local _PushEvent = EntityScript.PushEvent
function EntityScript:PushEvent(event, data)
	if not self.eventmuted or not self.eventmuted[event] then--没有静默
		_PushEvent(self, event, data)
		if self.eventlistening_shared and self.eventlistening_shared[event] then--是否分享
			local parent = self.entity:GetParent()
			if parent  and parent:IsValid() then
				parent:PushEvent(event, data)
			end
		end
	end
end
--事件监听静默
function EntityScript:SetEventMute(event, muted)
	if self.eventmuted == nil then
		self.eventmuted = {}
	end
    -- print(event)
	self.eventmuted[event] = muted and true or nil
end
--事件监听共享--会同时分享给上一级
function EntityScript:SetEventShare(event, shared)
	if self.eventlistening_shared == nil then
		self.eventlistening_shared = {}
	end
	self.eventlistening_shared[event] = shared and true or nil
end
--------------------------------------------------------------------------------------------
----------------------------------[[ 相关物品hook ]]-----------------------------------------
--------------------------------------------------------------------------------------------
local old_CanEntitySeePoint=GLOBAL.CanEntitySeePoint
GLOBAL.CanEntitySeePoint=function (inst,...)
    return old_CanEntitySeePoint(inst,...) or inst:IsInGarden()
end

local old_CanEntitySeeInDark=GLOBAL.CanEntitySeeInDark
GLOBAL.CanEntitySeeInDark=function (inst)
    return old_CanEntitySeeInDark(inst) or inst:IsInGarden()
end

--以下大部分来自花花的神话方寸山
AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
		return
	end
    inst:AddComponent("getposition")
end)
AddPrefabPostInit("dirtpile", function(inst)
	if TheWorld.ismastersim then
	inst:DoTaskInTime(0,function(...)
		if inst:IsInGarden() then
			inst:Remove()
		end
	end)
	end
end)
local dog = {"hound","firehound","icehound","moonhound","mutatedhound","warg"}
for i, v in ipairs(dog) do--
    AddPrefabPostInit(v, function(inst)
        if TheWorld.ismastersim then
        inst:DoTaskInTime(0,function(...)
            if inst:IsInGarden() then
                inst:Remove()
            end
        end)
        end
    end)
end
AddPrefabPostInit("telestaff", function(inst)
	if inst.components.spellcaster then
		local old = inst.components.spellcaster.CastSpell
		inst.components.spellcaster.CastSpell = function(self,target, pos,...)
			local caster = inst.components.inventoryitem.owner or target
			if caster and caster:IsInGarden()then
                if TheWorld:HasTag("cave") then
                    TheWorld:PushEvent("ms_miniquake", { rad = 3, num = 5, duration = 1.5, target = inst })
                else
                    SpawnPrefab("thunder_close")
                end
                if inst.components.finiteuses ~= nil then
                    inst.components.finiteuses:Use(1)
                end
                return
			end
			return old(self,target, pos,...)
		end
	end
end)

--陷坑
AddComponentPostInit("sinkholespawner", function(self, inst)
	local old_SpawnSinkhole=self.SpawnSinkhole
    self.SpawnSinkhole=function(self, spawnpt, ...)
		if TheWorld.Map:IsGardenAtPoint(spawnpt.x, 0, spawnpt.z) then
			return false
		else
			old_SpawnSinkhole(self,spawnpt, ...)
		end
	end
end)--farming_manager
AddComponentPostInit("farming_manager", function(self, inst)
    if not TheWorld.ismastersim then
		return
	end
	local old_GetTileNutrients=self.GetTileNutrients
    self.GetTileNutrients=function(self,x,y,...)
        if NU_GARDEN_TILES[tostring(x).."_"..tostring(y)] then
            return 100,100,100
        end
        return old_GetTileNutrients(self,x,y,...)
	end
end)--farmplantstress
if TUNING.FARM_BM then
    AddComponentPostInit("farmplantstress", function(self, inst)
        if not TheWorld.ismastersim then
            return
        end
        --[[
                self.final_stress_state = stress <= 1 and FARM_PLANT_STRESS.NONE		-- allow one mistake
                                or stress <= 6 and FARM_PLANT_STRESS.LOW		-- one and half categories can fail, take your pick
                                or stress <= 11 and FARM_PLANT_STRESS.MODERATE  -- almost 3 categories can fail
                                or FARM_PLANT_STRESS.HIGH	
        ]]
        local old_CalcFinalStressState=self.CalcFinalStressState
        self.CalcFinalStressState=function(...)
            if self.inst:IsInGarden() then
                if TUNING.FARM_BM==100 then
                    self.stress_points=0
                    self.final_stress_state=GLOBAL.FARM_PLANT_STRESS.NONE
                else
                    self.stress_points=math.max(self.stress_points-TUNING.FARM_BM,0)
                end
            end
            old_CalcFinalStressState(...)
        end
    end)
end
--落石--warningshadow---警告阴影
AddPrefabPostInit("cavein_boulder", function(inst)
	inst:ListenForEvent("startfalling", function (inst)
        if inst:IsInGarden() then
            local x, y, z = inst.Transform:GetWorldPosition()
            local fx = SpawnPrefab("cavein_debris")
            fx.Transform:SetScale(1, 0.25 + math.random() * 0.07, 1)
            fx.Transform:SetPosition(x, 0, z)
            
            if inst:HasTag("FX") then
                inst:Hide()
            else
                inst:Remove()
            end
        end
    end)
end)
AddPrefabPostInit("farm_plow_item", function(inst)
    local old=inst._custom_candeploy_fn
    if old then
        inst._custom_candeploy_fn=function (...)
            if inst:IsInGarden() then
                return false
            else
                return old(...)
            end
        end

    end
end)
-- AddPrefabPostInit("deciduoustree", function(inst)
--     local old_load=inst.OnLoad or function (...) return end
--     inst.OnLoad=function (inst,...)
--         old_load(inst,...)
--         if inst and inst.components.growable and inst:IsInGarden() then
--             inst.components.growable:SetStage(3)
--         end
--     end
-- end)
--tall
--        inst.components.growable:SetStage(stage == 0 and math.random(1, 3) or stage)
--潮湿度--干燥
if TUNING.WATER_BM then
    AddComponentPostInit("moisture", function(self)																		--房子里面不会降雨
        local old = self.GetMoistureRate
        function self:GetMoistureRate()
            if self.inst:IsInGarden()then
                return 0
            end
            return old(self)
        end
    end)
end
--如果在区域内就更新滤镜
AddComponentPostInit("areaaware", function(self)
	local old = self.UpdatePosition
	function self:UpdatePosition(x, y, z,...)
		if TheWorld.Map:IsGardenAtPoint(x, 0, z) then
			if self.current_area_data ~= nil then
				self.current_area = -1
				self.current_area_data = nil
				self.inst:PushEvent("changearea", self:GetCurrentArea())
			end
			return
		end
		return old(self,x, y, z,...)
	end
end)
-- --这个地方应该渺无鸟烟
-- if TUNING.BIRD_BM then
--     AddComponentPostInit("birdspawner", function(self)
--         local old_GetSpawnPoint = self.GetSpawnPoint
--         function self:GetSpawnPoint(pt)
--             if TheWorld.Map:IsGardenAtPoint(pt:Get()) then
--                 return nil
--             end
--             return  old_GetSpawnPoint(self,pt)
--         end
--     end)
-- end
--清除积雪覆盖效果
local Old_MakeSnowCovered = GLOBAL.MakeSnowCovered
local function ClearSnowCoveredPristine(inst)
    inst.AnimState:ClearOverrideSymbol("snow", "snow", "snow")
    inst:RemoveTag("SnowCovered")
    inst.AnimState:Hide("snow")
end
GLOBAL.MakeSnowCovered = function(inst,...)
	Old_MakeSnowCovered(inst,...)
	inst:DoTaskInTime(0,function()
		if inst.Transform ~= nil then
			local x,y,z = inst.Transform:GetWorldPosition()
			if TheWorld.Map:IsGardenAtPoint(x,y,z) then
				 ClearSnowCoveredPristine(inst)
			end
		end
	end)
end
--是否枯萎
AddComponentPostInit("witherable", function(self)																		--产生脚印
	if self.inst then
		self.inst:DoTaskInTime(0.1,function(crop)
			local x,y,z = crop.Transform:GetWorldPosition()
			if TheWorld.Map:IsGardenAtPoint(x,y,z) then
				self:Enable(false)
				-- print("是否枯萎",crop.prefab)
			end
		end)
	end
end)
--是否睡觉
AddComponentPostInit("sleeper", function(self)																		--产生脚印
    local old_GoToSleep=self.GoToSleep
    self.GoToSleep=function (...)
        if self.inst:IsInGarden() then
            return
        else
            old_GoToSleep(...)
        end
    end
end)
local upvaluehelper = require "components/upvaluehelper"
local rain = false
AddPrefabPostInit("forest", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	if rain then return end
	rain = true
    --青蛙雨
    if TUNING.WATER_BM then
        local frograin = upvaluehelper.GetWorldHandle(inst,"israining","components/frograin")							--下雨
        if  frograin then
            -- print("找到了")
            local GetSpawnPoint = upvaluehelper.Get(frograin,"GetSpawnPoint")
            if GetSpawnPoint ~= nil then
                local old = GetSpawnPoint
                local function newGetSpawnPoint(pt)
                    if TheWorld.Map:IsGardenAtPoint(pt:Get()) then
                        -- print("成功")
                        return nil
                    end
                    return old(pt)
                end
                upvaluehelper.Set(frograin,"GetSpawnPoint",newGetSpawnPoint)
            end
        end
    end

	local wildfires = upvaluehelper.GetEventHandle(TheWorld,"ms_lightwildfireforplayer","components/wildfires")		--野火
	if  wildfires then
		local LightFireForPlayer = upvaluehelper.Get(wildfires,"LightFireForPlayer")
		if LightFireForPlayer ~= nil then
			local old = LightFireForPlayer
			local function NewLightFireForPlayer(player, rescheduleFn)
				if player ~= nil then
					local x, y, z = player.Transform:GetWorldPosition()
					if TheWorld.Map:IsGardenAtPoint(x,y,z) then
						return
					end
				end
				old(player, rescheduleFn)
			end
			upvaluehelper.Set(wildfires,"LightFireForPlayer",NewLightFireForPlayer)
		end
	end

    --BM.PushGardenWorldState()
    -- local ToggleUpdate = upvaluehelper.GetEventHandle(inst,"isday","components/butterflyspawner")
    -- local ToggleUpdate_w = upvaluehelper.GetEventHandle(inst,"iswinter","components/butterflyspawner")
    -- --iswinter
    -- print("是否有",ToggleUpdate,ToggleUpdate_w)
    -- if ToggleUpdate and ToggleUpdate_w then
    --     print("有效")
    --     inst:StopWatchingWorldState("isday",ToggleUpdate)
    --     inst:StopWatchingWorldState("iswinter",ToggleUpdate_w)
    --     local new_ToggleUpdate=function (...)
    --         ToggleUpdate(...)
    --         print("无效")
    --         if TheWorld.state.isday and not TheWorld.state.iswinter then return end
    --         local _activeplayers=upvaluehelper.Get(ToggleUpdate,"_activeplayers")
    --         local tmp_activeplayers={}
    --         local num=false
    --         for i,v in pairs(_activeplayers)do
    --             if v and v:IsValid() and v:IsInGarden()then
    --                 table.insert(tmp_activeplayers,v)
    --                 num=true
    --             end
    --         end
    --         if num and (not TheWorld.state.isday or TheWorld.state.iswinter) then
    --             upvaluehelper.Set(ToggleUpdate,"_activeplayers",tmp_activeplayers)
    --             BM.PushGardenWorldState()
    --             ToggleUpdate(...)
    --             BM.PopGardenWorldState()
    --             upvaluehelper.Set(ToggleUpdate,"_activeplayers",_activeplayers)
    --         end
    --     end
    --     inst:WatchWorldState("isday",new_ToggleUpdate)
    --     inst:WatchWorldState("iswinter",new_ToggleUpdate)
    -- end
end)
--Get

-- AddComponentPostInit("hounded", function(self)
--     local function RemovePendingSpawns(player,_spawninfo)
--         if _spawninfo ~= nil then
--             for i, info in ipairs(_spawninfo) do
--                 if info.players[player] ~= nil then
--                     info.players[player] = nil
--                     if next(info.players) == nil then
--                          table.remove(_spawninfo, i)
--                     end
--                     return
--                 end
--             end
--         end
--     end
--     local old_update=self.OnUpdate
--     self.OnUpdate=function (self,dt)
--         local old__spawninfo=upvaluehelper.Get(old_update,"_spawninfo")
--         -- print("有狗吗？",old__spawninfo)
--         for i, v in ipairs(AllPlayers) do
--             if v:IsInGarden() then
--                 RemovePendingSpawns(v,old__spawninfo)
--             end
--         end
--         old_update(self,dt)
--     end
-- end)
--[[
    fns.StartFarmingMusicEvent = function(inst)
	inst._parent:PushEvent("playfarmingmusic")
end

]]
AddPrefabPostInit("player_classified", function(inst)
	-- if not TheWorld.ismastersim then
	-- 	return
	-- end
    inst:DoTaskInTime(0.1,function ()
        local play_theme_music = upvaluehelper.GetEventHandle(inst,"play_theme_music")
        if play_theme_music ~= nil then
            inst:RemoveEventCallback("play_theme_music",play_theme_music)
            -- inst.entity:GetParent():RemoveEventCallback("play_theme_music",play_theme_music)
            local function new_play_theme_music(parent, data)
                if parent and parent:IsInGarden() then
                    return
                end
                if parent and TheWorld.Map:IsGardenAtPoint(parent.Transform:GetWorldPosition()) then
                    return
                end
                -- print("没有屏蔽")
                play_theme_music(parent, data)
            end
            inst:ListenForEvent("play_theme_music",new_play_theme_music, inst.entity:GetParent())
            -- inst.entity:GetParent()
        end
    end)
end)
--消除雨雪
local old_update = {rain = nil ,caverain = nil, snow = nil }
local emitters = GLOBAL.EmitterManager--发射器
local oldPostUpdate = emitters.PostUpdate or nil

function emitters:PostUpdate(...)
	for inst, data in pairs( self.awakeEmitters.infiniteLifetimes ) do
		if (--[[inst.prefab == "rain" or]] inst.prefab == "caverain" or inst.prefab == "snow")  and data.updateFunc ~= nil then
			if old_update[inst] == nil then
				old_update[inst] = data.updateFunc
			end
			local x, y, z = inst.Transform:GetWorldPosition()
			if TheWorld.Map:IsGardenAtPoint(x,y,z) then
				data.updateFunc = function(...)end
			else
				data.updateFunc = old_update[inst]
			end
		end
        if TUNING.WATER_BM then
            if inst.prefab == "rain" and data.updateFunc ~= nil then
                if old_update[inst] == nil then
                    old_update[inst] = data.updateFunc
                end
                local x, y, z = inst.Transform:GetWorldPosition()
                if TheWorld.Map:IsGardenAtPoint(x,y,z) then
                    data.updateFunc = function(...)end
                else
                    data.updateFunc = old_update[inst]
                end
            end
        end
	end
	if oldPostUpdate ~= nil then
		oldPostUpdate(emitters,...)
	end
end
--脚步声音
local Old_PlayFootstep = GLOBAL.PlayFootstep
GLOBAL.PlayFootstep = function(inst, volume, ispredicted,...)
	if inst:IsInGarden() then
		local sound = inst.SoundEmitter
		if sound ~= nil then
            sound:PlaySound(
                inst.sg ~= nil and inst.sg:HasStateTag("running") and "dontstarve/movement/run_woods" or "dontstarve/movement/walk_woods"
                ..
                (   (inst:HasTag("smallcreature") and "_small") or
                    (inst:HasTag("largecreature") and "_large" or "")
                ),
                nil,
                volume or 1,
                ispredicted
            )
		end
	else
		Old_PlayFootstep(inst, volume, ispredicted,...)
	end
end



--进入房子的动作
local ENTER_GARDEN = GLOBAL.Action({ priority=3, mount_valid = true,ghost_valid=true, encumbered_valid=true})
ENTER_GARDEN.id = "ENTER_GARDEN"
ENTER_GARDEN.strfn = function(act)
    if act.doer ~= nil and act.doer:HasTag("playerghost") then
		return  "HAUNT"
	end
	return act.target ~= nil and string.upper(act.target.prefab) or nil
end
ENTER_GARDEN.fn = function(act)
    if act.doer ~= nil and
        act.doer.sg ~= nil and
        act.doer.sg.currentstate.name == "gardenin_pre" then--当前状态的名字
        if act.target ~= nil and
            act.target.components.teleporter ~= nil and
            act.target.components.teleporter:IsActive(act.doer) then
            act.doer.sg:GoToState("garden_jump", { target = act.target })
            return true
        end
        act.doer.sg:GoToState("idle")
		return false,"NOTIME"
    end
end
AddAction(ENTER_GARDEN)

AddComponentAction("SCENE", "teleporter" , function(inst, doer, actions, right)
    if inst:HasTag("garden_in") or inst:HasTag("garden_exit") then
		table.insert(actions, ACTIONS.ENTER_GARDEN)
    end
end)

--动作句柄，对应的state
AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENTER_GARDEN, "gardenin_pre"))
AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENTER_GARDEN, "gardenin_pre"))
--鬼魂的状态
AddStategraphActionHandler("wilsonghost",GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENTER_GARDEN, "gardenin_pre"))
AddStategraphActionHandler("wilsonghost_client",GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENTER_GARDEN, "gardenin_pre"))
-- local L = "CHINESE"--MK_MOD_LANGUAGE_SETTING
if TUNING.LANG_BM then
	GLOBAL.STRINGS.ACTIONS.ENTER_GARDEN = {
		HAUNT = "作祟",--GARDEN_ENTRANCE
		GARDEN_ENTRANCE = "进入",
		GARDEN_EXIT = "离开",
        GARDEN_ENTRANCE1 = "进入",
		GARDEN_EXIT1 = "离开",
	}
else
	GLOBAL.STRINGS.ACTIONS.ENTER_GARDEN = {
		HAUNT = "haunt",
		GARDEN_ENTRANCE = "Enter",
		GARDEN_EXIT = "Exit",
        GARDEN_ENTRANCE1 = "Enter",
		GARDEN_EXIT1 = "Exit",
	}
end

local function ToggleOffPhysics(inst)--关闭物理碰撞
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()--清除碰撞
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

AddStategraphState('wilson',

    State{
        name = "gardenin_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)--进入sg时的动画
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
			inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.bufferedaction ~= nil then
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    }
)
AddStategraphState('wilsonghost',

    State{
        name = "gardenin_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate", false)
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.bufferedaction ~= nil then
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    }
)

AddStategraphState('wilson',
    State{
        name = "garden_jump",
        tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.target
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()

            if data.target ~= nil and data.target.components.teleporter ~= nil then
                data.target.components.teleporter:RegisterTeleportee(inst)
            end
			inst.AnimState:PlayAnimation("give_pst", false)
			data.target.AnimState:PlayAnimation("door_closing",false)
            data.target.AnimState:PushAnimation("idle",false)
            local pos = data ~= nil and data.target and data.target:GetPosition() or nil
            if pos ~= nil then
                inst:ForceFacePoint(pos:Get())
            else
                inst.sg.statemem.speed = 0
            end
			inst.sg.statemem.teleportarrivestate = "idle"
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:Stop()
                end
                if inst.sg.statemem.target ~= nil then
                    if inst.sg.statemem.target:IsValid() then
                        inst.sg.statemem.target:PushEvent("starttravelsound", inst)
                    else
                        inst.sg.statemem.target = nil
                    end
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                -- print("动画结束了")
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.target ~= nil and
                        inst.sg.statemem.target:IsValid() and
                        inst.sg.statemem.target.components.teleporter ~= nil then
                        inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
                        if inst.sg.statemem.target.components.teleporter:Activate(inst) then
                            inst.sg.statemem.isteleporting = true
                            inst.components.health:SetInvincible(true)
                            if inst.components.playercontroller ~= nil then
                                inst.components.playercontroller:Enable(false)
                            end
                            inst:Hide()
                            inst.DynamicShadow:Enable(false)
                            return
                        end
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if inst.sg.statemem.target ~= nil and
				inst.sg.statemem.target:IsValid() then
					inst.sg.statemem.target.AnimState:SetDeltaTimeMultiplier(0.5)
			end
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            inst.Physics:Stop()

            if inst.sg.statemem.isteleporting then
                inst.components.health:SetInvincible(false)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
                inst.DynamicShadow:Enable(true)
            elseif inst.sg.statemem.target ~= nil
                and inst.sg.statemem.target:IsValid()
                and inst.sg.statemem.target.components.teleporter ~= nil then
                inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
            end
        end,
    }	
)

AddStategraphState('wilsonghost',
    State{
        name = "garden_jump",
        tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },
        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.target
            inst.sg.statemem.teleportarrivestate = "idle"

            inst.sg.statemem.target:PushEvent("starttravelsound", inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target.components.teleporter ~= nil
                and inst.sg.statemem.target.components.teleporter:Activate(inst) then
                inst.sg.statemem.isteleporting = true
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(false)
                end
                inst:Hide()
            else
                inst.sg:GoToState("idle")
            end
        end,		
        onexit = function(inst)
            if inst.sg.statemem.isteleporting then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
            end
        end,
    }
)

AddStategraphState('wilson_client',

    State{
        name = "gardenin_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
			inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    }
)

AddStategraphState('wilsonghost_client',

    State
    {
        name = "gardenin_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("appear")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("appear")
            inst.sg:GoToState("idle", true)
        end,
    }
)

-------------------------------------------------------------------------------
--一些物品随世界时间改变
-- local nightprefab={
-- 	"fireflies",
-- 	"pumpkin_lantern",
-- 	-- "mushroom_farm",
-- }
-- for k,v in pairs(nightprefab)do
-- 	AddPrefabPostInit("v", function(inst)
-- 		local night = upvaluehelper.GetWorldHandle(inst,"isnight")
-- 		if v:IsInGarden() then
-- 			v:StopWatchingWorldState("isnight", night)
-- 			night(v)
-- 		else
-- 			inst:WatchWorldState("isnight", night)
-- 			night(v)
-- 		end
-- 	end)
-- end
--------------------------------------------------------------------------------------
--本部分来自模组--[[地下室]]--，如有不便，请联系我进行修改或下架本模组--qq：2943110025--感谢大佬的帮助
--房间里面生物状态的改变
local instlist={}
local function SetWorldStateWatchers(inst)
    local datastate=CUSTOM_GARDEN_WORLD_STATE.DATA
    if prefablist.night[inst.prefab] then
        datastate=CUSTOM_GARDEN_WORLD_STATE.NIGHT
    end
    local ALL_WORLDSTATE_WATCHERS=upvaluehelper.Get(GLOBAL.TheWorld.components.worldstate.AddWatcher, "_watchers")
	if ALL_WORLDSTATE_WATCHERS ~= nil then
		local istarget = { [inst] = true }
		-- for k,v in pairs(inst.components) do
		-- 	istarget[v] = true
		-- end
		--table.insert(watcherfns, { fn, target })--插入监听函数
		for var, varwatchers in pairs(ALL_WORLDSTATE_WATCHERS) do--对应天气状态，对应的监听者列表
            -- print("监听变量",var)
			-- for target, watcherfns in pairs(varwatchers) do--观察者，观察者函数和目标列表
                -- print("监听变量",var,"目标",target.prefab)
                --prefablist.night[target.prefab]or prefablist.day[target.prefab]
				if varwatchers[inst] and datastate[var] then
					-- print("有监听")
                    -- if datastate[var]~=nil then--如果在观察者列表里面，就执行对应的函数
                        -- print("监听的东西有",var,target.prefab)
                        for k, fn in pairs(varwatchers[inst]) do----观察者，观察者函数和目标
                            -- print("v是什么",type(v))
                            BM.PushGardenWorldState()
                            fn[1](fn[2], datastate[var])
                            BM.PopGardenWorldState()
                            if instlist[inst]~=true then
                                instlist[inst]=true
                                ALL_WORLDSTATE_WATCHERS[var][inst][k]={function (...)
                                    if inst:IsInGarden()then
                                        -- return
                                        BM.PushGardenWorldState()
                                        fn[1](fn[2], datastate[var])
                                        BM.PopGardenWorldState()
                                    else
                                        fn[1](fn[2], datastate[var])
                                    end
                                end,fn[2]}--执行函数之后就删除吧
                            end
                        end
                    -- end
				end
			-- end
		end
        upvaluehelper.Set(TheWorld.components.worldstate.AddWatcher,"_watchers",ALL_WORLDSTATE_WATCHERS)
	end
end
--重新生成物品的改变
local spawn_normal=GLOBAL.SpawnSaveRecord
local function SpawnSaveRecord(saved, ...)
	if saved.prefab ~= nil
	and prefablist[saved.prefab]
	and TheWorld.Map:GetTileAtPoint(saved.x or 0, saved.y or 0, saved.z or 0) == GROUND.INVALID then
		BM.PushGardenWorldState()
		local inst = spawn_normal(saved, ...)
        if inst:IsInGarden() then
            inst:DoTaskInTime(1,function (inst)
                SetWorldStateWatchers(inst)
            end)
        end
		BM.PopGardenWorldState()
		return inst
	end
	return spawn_normal(saved, ...)
end
GLOBAL.SpawnSaveRecord=SpawnSaveRecord

for i,v in pairs(prefablist)do
    for prefab,k in pairs(v)do
        AddPrefabPostInit(prefab, function(inst)
            inst:DoTaskInTime(0.1, function (inst)
                if inst:IsInGarden() then
                    SetWorldStateWatchers(inst)
                end
            end)
            -- local old_load=inst.OnLoad or function (...) return end
            -- inst.OnLoad=function (inst,...)
            --     old_load(inst,...)
            --     inst:DoTaskInTime(2,function (inst)
            --         SetWorldStateWatchers(inst)
            --     end)
            -- end
            local old_OnEntityWake=inst.OnEntityWake or function (...) return end
            inst.OnEntityWake=function (inst,...)
                old_OnEntityWake(inst,...)
                if inst:IsInGarden() then
                    inst:DoTaskInTime(1,function (inst)
                        SetWorldStateWatchers(inst)
                    end)
                end
            end
            --	inst.OnEntitySleep = OnEntitySleep
            local old_OnEntitySleep=inst.OnEntitySleep or function (...) return end
            inst.OnEntitySleep=function (inst,...)
                old_OnEntitySleep(inst,...)
                if inst:IsInGarden() then
                    inst:DoTaskInTime(1,function (inst)
                        SetWorldStateWatchers(inst)
                    end)
                end
            end
        end)
    end
end
-- AddPrefabPostInit("deciduoustree", function(inst)
--     local old_save=inst.OnSave or function (...) return end
--     inst.OnSave=function (inst,...)
--         if inst:IsInGarden() then
--             SetWorldStateWatchers(inst)
--             BM.PushGardenWorldState()
--             old_save(inst,...)
--             BM.PopGardenWorldState()
--         else
--             old_save(inst,...)
--         end
--     end
--     local old_load=inst.OnLoad or function (...) return end
--     inst.OnLoad=function (inst,...)
--         old_load(inst,...)
--         inst:DoTaskInTime(1,function (inst)
--             SetWorldStateWatchers(inst)
--         end)
--     end
--     inst:DoTaskInTime(0, function (inst)
--         if inst:IsInGarden() then
--             SetWorldStateWatchers(inst)
--         end
--     end)
-- end)
-- AddPrefabPostInit("deciduoustree", function(inst)
--     local old_load=inst.OnLoad or function (...) return end
--     inst.OnLoad=function (inst,...)
--         old_load(inst,...)
--         inst:DoTaskInTime(2,function (inst)
--             SetWorldStateWatchers(inst)
--         end)
--     end
-- end)
AddPrefabPostInit("pond", function(inst)
    local old_load=inst.OnLoad or function (...) return end
    inst.OnLoad=function (inst,...)
        old_load(inst,...)
        if inst:IsInGarden() then
            inst:DoTaskInTime(1,function (inst)
                SetWorldStateWatchers(inst)
            end)
        end
    end
end)
------------------------------------------------------------------------------更改相关生物的大脑
--猪在小房子里面不回家
local function MakePigsNotGoHome(brain)
    local flag=0
	for i,node in ipairs(brain.bt.root.children) do
		if node.name == "Parallel" and node.children[1].name == "IsDay" then
            node.children[1].fn=function() return TheWorld.state.isday or brain.inst:IsInGarden() end
            flag=flag+1
        elseif node.name=="Parallel" and node.children[1].name=="IsNight" then
            node.children[1].fn=function() return not TheWorld.state.isday and not brain.inst:IsInGarden() end
            flag=flag+1
		end
        if flag>=2 then break end
	end
end

AddBrainPostInit("pigbrain", MakePigsNotGoHome)
--蜜蜂晚上和冬天依然工作
local function MakeBeesNotGoHome(brain)
    local flag=0
	for i,node in ipairs(brain.bt.root.children) do
		if node.name == "Sequence" and node.children[1].name == "IsWinter" then
            local old_fn=node.children[1].fn
            node.children[1].fn=function(...) return old_fn(...) and not brain.inst:IsInGarden() end
            flag=flag+1
        elseif node.name=="Sequence" and node.children[1].name=="IsNight" then
            local old_fn=node.children[1].fn
            node.children[1].fn=function(...) return old_fn(...) and not brain.inst:IsInGarden() end
            flag=flag+1
		end
        if flag>=2 then break end
	end
end
AddBrainPostInit("beebrain", MakeBeesNotGoHome)
--晚上继续产生蝴蝶，蝴蝶不回家
local function MakeButterflyNotGoHome(brain)
    local flag=0
	for i,node in ipairs(brain.bt.root.children) do
        if node.name=="Sequence" and (node.children[1].name=="IsNight" or node.children[1].name=="IsFullOfPollen") then
            local old_fn=node.children[1].fn
            node.children[1].fn=function(...) return old_fn(...) and not brain.inst:IsInGarden() end
		end
	end
end
AddBrainPostInit("butterflybrain", MakeButterflyNotGoHome)

local function MakePerdNotGoHome(brain)
	for i,node in ipairs(brain.bt.root.children) do
        if node.name=="Parallel" and node.children[1].name=="IsNight" then
            node.children[1].fn=function() return not TheWorld.state.isday and not brain.inst:IsInGarden() end
		end
	end
end

AddBrainPostInit("perdbrain", MakePerdNotGoHome)






--水晶球回城动作
local CANDY_RETURN = GLOBAL.Action({ priority=3, mount_valid = true,ghost_valid=true, encumbered_valid=true})
CANDY_RETURN.id = "CANDY_RETURN"
CANDY_RETURN.strfn = function(act)
    if act.doer ~= nil and act.doer:HasTag("playerghost") then
		return  "HAUNT"
	end
	return "CRYSTAL_BALL"
end
CANDY_RETURN.fn = function(act)
    if act.doer ~= nil and act.doer.sg ~= nil then
        if act.invobject ~= nil and act.invobject.components.teleporter ~= nil and act.invobject.components.teleporter:IsActive() then
            act.invobject.components.teleporter:RegisterTeleportee(act.doer)
            if act.invobject.components.teleporter:Activate(act.doer) then
                act.invobject:Remove()
                return true
            end
        end
		return false,"NOTIME"
    end
end
AddAction(CANDY_RETURN)

AddComponentAction("INVENTORY", "teleporter" , function(inst, doer, actions, right)
    if inst:HasTag("crystal_ball")then
		table.insert(actions, ACTIONS.CANDY_RETURN)
    end
end)

--动作句柄，对应的state
AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(GLOBAL.ACTIONS.CANDY_RETURN, "doshortaction"))
AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(GLOBAL.ACTIONS.CANDY_RETURN, "doshortaction"))
--鬼魂的状态
AddStategraphActionHandler("wilsonghost",GLOBAL.ActionHandler(GLOBAL.ACTIONS.CANDY_RETURN, "doshortaction"))
AddStategraphActionHandler("wilsonghost_client",GLOBAL.ActionHandler(GLOBAL.ACTIONS.CANDY_RETURN, "doshortaction"))
-- local L = "CHINESE"--MK_MOD_LANGUAGE_SETTING
if TUNING.LANG_BM then
	GLOBAL.STRINGS.ACTIONS.CANDY_RETURN = {
		HAUNT = "传送",--GARDEN_ENTRANCE
        CRYSTAL_BALL="传送",
	}
else
	GLOBAL.STRINGS.ACTIONS.CANDY_RETURN = {
		HAUNT = "transfer",
        CRYSTAL_BALL="transfer",
	}
end