require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/wddd1.zip"),
	Asset("ANIM", "anim/rooo1.zip"),
	Asset("ANIM", "anim/caaa1.zip"),
	Asset("ANIM", "anim/gsss1.zip"),
	Asset("ANIM", "anim/brrr1.zip"),
	Asset("ANIM", "anim/wddd2.zip"),
	Asset("ANIM", "anim/rooo2.zip"),
	Asset("ANIM", "anim/caaa2.zip"),
	Asset("ANIM", "anim/gsss2.zip"),
	Asset("ANIM", "anim/brrr2.zip"),
}

local GARDEN_WORLD_STATE = {}
GARDEN_WORLD_STATE =
{
	CAVE_TEMPERATURE_MULT =
	{
		autumn = -0.4,
		winter = -1.6,
		spring = -0.4,
		summer = 0.4,
	},
	
	ENABLED = false,
	TIME = nil,
	LAST = nil,
	STACK = 0,
	COLOURCUBE_PHASEFN =
	{
		blendtime = 1,
		events = {},
		-- fn = function()	return "night" end,
		fn = function()	return "day" end,
	},
	
	DSP =
	{
		lowdsp =
		{
			["set_ambience"] = 750,
			["set_sfx/set_ambience"] = 750,
			["set_music"] = 750,
			["set_sfx/movement"] = 750,
			["set_sfx/creature"] = 750,
			["set_sfx/player"] = 750,
			["set_sfx/voice"] = 500,
			["set_sfx/sfx"] = 750,
		},
		-- highdsp =
		-- {

		-- },
		duration = 0.5,
	},
}
--------------------------------------------------------------------------
---------------------[[ 地下室内部 ]]--------------------------------------
--------------------------------------------------------------------------
--划分矩形地区--可选是否仅仅边界
local function Rectangle(grid, centered, getall, step)
	local _x, _z = grid:match("(%d+)x(%d+)")
	_x, _z=_x-1,_z-1
	local data = { _x, _z }--存储边界，用来建墙
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
end
--清除地下室的瓷砖
local function RemoveSyntTiles(inst)
	-- print("删除瓷砖")
	if inst._synttiles ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		for _,v in pairs(inst._synttiles) do
			BM.Map.RemoveSyntTile(x + v.x, 0, z + v.z)
		end
	end
end
--增加26X26的瓷砖
--用来限制玩家位置的--需要是外墙减6
local level=7
local function AddSyntTiles(inst)
	-- print("增加瓷砖",inst.level)
	local str=tostring((inst.level_bm:value())*4-2).."x"..tostring((inst.level_bm:value())*4-2)
	inst._synttiles = Rectangle(str, true, true, 4)
	local x, y, z = inst.Transform:GetWorldPosition()
	for _,v in pairs(inst._synttiles) do
		BM.Map.AddSyntTile(x + v.x, 0, z + v.z)
	end
	inst:ListenForEvent("onremove", RemoveSyntTiles)
end
--增加我的34X34的瓷砖
local function AddMySyntTiles(inst)
	-- print("增加34的瓷砖")
	local str=tostring((inst.level_bm:value())*4+4).."x"..tostring((inst.level_bm:value())*4+2)
	inst._synttiless = Rectangle(str, true, true)
	local x, y, z = inst.Transform:GetWorldPosition()
	for _,v in pairs(inst._synttiless) do
		BM.Map.AddMySyntTile(x + v.x, 0, z + v.z)
	end
	inst:ListenForEvent("onremove", RemoveSyntTiles)
end
---------------------------------------------------------------------------------------------
------------------------------------[[      ]]-----------------------------------------------
---------------------------------------------------------------------------------------------
--删除花园
local function DespawnGarden(inst)
	-- print("删除地下室")
	if not(inst and inst:IsValid()) then return end
	local bx, by, bz = inst.garden.core.Transform:GetWorldPosition()
	local ex, ey, ez =inst.garden.entrance.Transform:GetWorldPosition()
    local range=20
	for _, entity in pairs(inst.garden) do
		if entity.OnEntitySleep then
			entity:OnEntitySleep()
            range=((entity.level or level)*5) or 20
		end
		BM.Replace(entity, "Remove")
		entity:Remove()
	end
	if not ex then																							--房子位置不存在，炫彩之门
		for k,v in pairs(Ents) do
			if v:HasTag("multiplayer_portal") then
				ex, ey, ez  = v.Transform:GetWorldPosition()
			end
		end
	end
	if not ex then
		ex, ey, ez  = 0,0,0
	end
	local ents = TheSim:FindEntities(bx, by, bz,range,nil,{"INLIMBO"})
	for i,v in ipairs(ents) do
		if v:HasTag("player") or v:HasTag("irreplaceable") then
			if v.Physics ~= nil then
				v.Physics:Teleport(ex, ey, ez)
			elseif v.Transform ~= nil then
				v.Transform:SetPosition(ex, ey, ez)
			end	
		elseif v.components.workable ~= nil then
			v.components.workable:Destroy(v)
		elseif v.components.perishable ~= nil then
			v.components.perishable:LongUpdate(10000)
		elseif v.components.finiteuses ~= nil then
			v.components.finiteuses:Use(10000)
		elseif v.components.fueled ~= nil then
			v.components.fueled:DoUpdate(10000)
		end
		if v and v:IsValid() and not v:HasTag("irreplaceable")then
			v:Remove()
		end
	end
	--删除的物品
	TheWorld:DoTaskInTime(0.5,function(world)
		local ents2 = TheSim:FindEntities(bx, by, bz,range)
		for i,v in ipairs(ents2) do
			if v and v.components.inventoryitem ~= nil  then
				if v.Physics ~= nil then
					v.Physics:Teleport(ex, ey, ez)
				elseif v.Transform ~= nil then
					v.Transform:SetPosition(ex, ey, ez)
				end
			else
				v:Remove()
			end
		end
	end)
end
--检查是否生成了地下室--并连接中心，入口，出口，并将三个实体都附在上面
local function CheckReferences(inst)
    -- print("连接出口入口")
	if inst.garden ~= nil then return end
	local garden = { core = inst }
	local x, y, z = inst.Transform:GetWorldPosition()
	local exit = TheSim:FindEntities(x, 0, z, (inst.level)*4, { "garden_part", "garden_exit" })[1]
	if exit ~= nil then
		garden.exit = exit
		if exit.components.teleporter ~= nil then
			garden.entrance = exit.components.teleporter.targetTeleporter
		end
		exit.Transform:SetPosition(x, y, z)
	end
	for name, entity in pairs(garden) do
		BM.Replace(entity, "Remove", DespawnGarden)
		entity.garden = garden
	end
end
--删除所有墙
local function DespawnInteriorWalls(inst)
	-- print("删除所有墙")
	if inst.children ~= nil then
		for ent in pairs(inst.children) do
			if ent:IsValid() then
				ent:Remove()
			end
		end
		inst.children = nil
	end
end
--生成墙
local function SpawnInteriorWalls(inst)
	-- print("生成所有墙",inst.level_bm:value())
	DespawnInteriorWalls(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	x, z = math.floor(x)+0.5, math.floor(z)+0.5 --matching with normal walls
	local str=tostring((inst.level)*4+2).."x"..tostring((inst.level)*4+2)
	for _,v in pairs(Rectangle(str, true)) do
		local part = SpawnPrefab(inst.wall)
		-- print("墙围",inst.wall)
		if not part then return end
		inst:AddChild(part)
		part.entity:SetParent(nil)
		part.Transform:SetPosition(x + v.x, 0, z + v.z)
	end
end
--覆盖玩家cc表
-- local function OverrideColourCube(enable)
-- 	ThePlayer:SetEventMute("ccphasefn", false)
-- 	ThePlayer:RemoveEventCallback("ccoverrides", OverrideColourCube)
-- 	if enable then
-- 		ThePlayer:PushEvent("ccphasefn", GARDEN_WORLD_STATE.COLOURCUBE_PHASEFN)
-- 		ThePlayer:SetEventMute("ccphasefn", true)--设置监听静默
-- 		ThePlayer:ListenForEvent("ccoverrides", OverrideColourCube)
-- 	else
-- 		ThePlayer:PushEvent("ccphasefn")
-- 	end
-- end
-- local terrors = { "attack", "attack_grunt", "die", "hit_response", "idle", "taunt", "appear", "dissappear" }

-- local function PlayTerrorSound(proxy)
-- 	local inst = CreateEntity()

-- 	inst.entity:AddTransform()
-- 	inst.entity:AddSoundEmitter()
-- 	inst.entity:SetParent(proxy.entity)

-- 	local theta = math.random() * 2 * PI
-- 	inst.Transform:SetPosition(5 * math.cos(theta), 0, 5 * math.sin(theta))
-- 	inst.SoundEmitter:PlaySound(string.format("dontstarve/sanity/creature%s/%s", math.random(2), Waffles.GetRandom(terrors)), nil, math.random())

-- 	inst:Remove()
	
-- 	proxy.garden_task = proxy:DoTaskInTime(math.random(5, 40), PlayTerrorSound)
-- end
local music={"dontstarve/music/music_FE_WF","dontstarve/music/music_FE_yotg","dontstarve/music/music_FE_yotc","dontstarve/music/music_FE_summerevent","yotb_2021/music/FE"}
local function EnableGardenAmbient(enable)
	TheSim:SetReverbPreset((enable or TheWorld:HasTag("cave")) and "cave" or "default")

	-- ThePlayer:PushEvent("popdsp", BASEMENT_WORLD_STATE.DSP)
	-- if enable then
	-- 	ThePlayer:PushEvent("pushdsp", BASEMENT_WORLD_STATE.DSP)
	-- end
	
	if TheFocalPoint and TheFocalPoint:IsValid() then
		if TheFocalPoint.garden_task ~= nil then
			TheFocalPoint.garden_task:Cancel()
			TheFocalPoint.garden_task = nil
		end
		
		if enable then
			if TUNING.MUSIC_BM~=-1 then
				if TUNING.MUSIC_BM==0 then
					TheFocalPoint.SoundEmitter:PlaySound(music[math.random(#music)], "garden_music")
				else
					TheFocalPoint.SoundEmitter:PlaySound(music[TUNING.MUSIC_BM], "garden_music")
				end
			end
			-- TheFocalPoint.garden_task = TheFocalPoint:DoTaskInTime(math.random(10, 40), PlayTerrorSound)
		else
			TheFocalPoint.SoundEmitter:KillSound("garden_music")
		end
	end
end
--地下室环境改变--光照，声音
local function EnableGardenEnvironment(caller, enable)
	if GARDEN_WORLD_STATE.ENABLED == enable then
		return
	end
	
	EnableGardenAmbient(enable)
	GARDEN_WORLD_STATE.ENABLED = enable
	if enable then
		TheWorld:PushEvent("overrideambientlighting",Point(200 / 255, 200 / 255, 200 / 255))
	else
		TheWorld:PushEvent("overrideambientlighting",nil)
	end

	-- OverrideColourCube(enable)
	local clouds =ThePlayer.HUD.clouds
	if clouds ~= nil then
		-- BM.Replace(clouds, "cloudcolour", enable and { 0, 0, 0 } or nil)
		BM.Replace(clouds, "cloudcolour", enable and { 1, 1, 1 } or nil)
	end
	local oceancolor =TheWorld.components.oceancolor
	if oceancolor ~= nil then
		TheWorld:StopWallUpdatingComponent(oceancolor)
		oceancolor:Initialize(not enable and TheWorld.has_ocean)
	end
	TheWorld:SetEventMute("screenflash", enable)--屏幕闪烁事件静默
end
--客户端地下室实体苏醒
local function OnEntityWakeClient(inst)
	if not(ThePlayer and ThePlayer:IsValid()) then return end--客户端玩家是否合法
	ThePlayer:SetEventMute("startfarmingmusicevent",true)
	ThePlayer:SetEventMute("playfarmingmusic",true)
	ThePlayer:SetEventMute("play_theme_music",true)
	ThePlayer:DoTaskInTime(0.1, EnableGardenEnvironment, true) --加载时轻微延迟
end
--客户端实体睡眠
local function OnEntitySleepClient(inst)
	if not(ThePlayer and ThePlayer:IsValid()) then return end--客户端玩家是否合法
	ThePlayer:SetEventMute("playfarmingmusic",false)--play_theme_music
	ThePlayer:SetEventMute("startfarmingmusicevent",false)
	ThePlayer:SetEventMute("play_theme_music",false)
	ThePlayer:DoTaskInTime(0.1, EnableGardenEnvironment, false)
end
--更新地下室降温效果--和洞穴保持一致
local function UpdateGardenInsulation(inst, season)
	-- if TheWorld:HasTag("cave") then
	inst.insulation = TUNING.GARDEN.INSULATION * (GARDEN_WORLD_STATE.CAVE_TEMPERATURE_MULT[season] or 1)
	if inst.allplayers ~= nil then
		for ent in pairs(inst.allplayers) do
			if ent.components.temperature ~= nil then
				ent.components.temperature:SetModifier("garden", inst.insulation)
			end
		end
	end
end
--将玩家传送回来hhhh
local function ValidatePosition(ent)
	if not ent:IsInGarden() and ent:GetTimeAlive() >= 2 then
		local x, y, z = ent.Transform:GetWorldPosition()
		x, z = math.floor(x), math.floor(z)
		local closestdist = math.huge
		local ox, oz
		for i,v in ipairs(Rectangle("16x16", true, true)) do
			local x, y, z = x + v.x, 0, z + v.z
			if TheWorld.Map:IsGardenAtPoint(x, y, z) then
				local dist = ent:GetDistanceSqToPoint(x, y, z)
				if dist < closestdist then
					closestdist = dist
					ox, oz = x, z
				end
			end
		end
		if ox then
			ent.Transform:SetPosition(ox, 0, oz)
		end
		if not ent:HasTag("player")
		and ent.components.workable ~= nil
		and ent.components.workable:CanBeWorked()
		and ent.components.workable.action ~= ACTIONS.NET then
			ent.components.workable:Destroy(ent)
		end
	end
end
--------------------------------------------------------------------------
--[[ Performance Optimization ]]
--------------------------------------------------------------------------
--local SAVE_RECORDS = {}
--模拟玩家刷出事件
local function SimulateSpawnerEventsForPlayer(ent, event)
	local t = TheWorld.event_listening and TheWorld.event_listening.event
	if type(t) == "table" and type(t[TheWorld]) == "table" then
		for i,v in ipairs(t[TheWorld]) do
			local upvaluehelper = require "components/upvaluehelper"
			local activeplayers = upvaluehelper.Get(v, "_activeplayers")
			if activeplayers ~= nil then
				v(TheWorld, ent)
			end
		end
	end
end
local function SetBasementBuilder(inst, ent, enable)
	if enable then
		ent:AddTag("garden_member")
	else
		ent:RemoveTag("garden_member")
	end
end
local function OnBuilderPrototyperChanged(self, machine)
	local enable = self.freebuildmode or (machine == nil or machine:HasTag("garden_part"))
	local isbuilder = self.inst:HasTag("garden_member")
	if enable ~= isbuilder then
		SetBasementBuilder(self.inst.basement, self.inst, enable)
	end
end
---更新玩家在地下室的收益
local function AddGardenPlayerBenefits(inst, ent)
	ent.garden = inst--startfarmingmusicevent
	inst:SetEventMute("startfarmingmusicevent",true)
	inst:SetEventMute("playfarmingmusic",true)
	inst:SetEventMute("play_theme_music",true)
	-- if ent.components.temperature ~= nil then
	-- 	ent.components.temperature:SetModifier("garden",inst.insulation)
	-- end
	if ent.components.playercontroller ~= nil then
		ent.components.playercontroller:EnableMapControls(false)
	end
	if ent.components.beaverness ~= nil then
		BM.Replace(ent.components.beaverness, "SetPercent", function ()return end)
	end
	if ent.components.builder ~= nil then
		SetBasementBuilder(inst,ent,true)
		inst:PushEvent("unlockrecipe")
		inst:PushEvent("builditem")
		local bufferedbuilds = inst.player_classified and inst.player_classified.bufferedbuilds
		if bufferedbuilds ~= nil then
			for k,v in pairs(bufferedbuilds) do
				local val = v:value()
				v:set_local(val)
				v:set(val)
				break
			end
		end
		addsetter(ent.components.builder, "current_prototyper", OnBuilderPrototyperChanged)
	end
	SimulateSpawnerEventsForPlayer(ent, "ms_playerleft")
	OnEntityWakeClient(inst)
end
--设置光监视器添加阈值
local function SetLightWatcherAdditiveThresh(ent, thresh)
	thresh = thresh or nil
	ent.LightWatcher:SetLightThresh(thresh or 0.05)
	ent.LightWatcher:SetMinLightThresh(thresh or 0.02) --for sanity.
	ent.LightWatcher:SetDarkThresh(thresh or .0)
end
--[[
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
	ent.LightWatcher:SetLightThresh(0.05)
	-- ent.LightWatcher:SetMinLightThresh() --for sanity.
	ent.LightWatcher:SetDarkThresh(0)
]]
--删除玩家在地下室的收益
local function RemoveGardenPlayerBenefits(inst, ent)
	inst:SetEventMute("playfarmingmusic",false)--play_theme_music
	inst:SetEventMute("startfarmingmusicevent",false)
	inst:SetEventMute("play_theme_music",false)
	if not (ent and ent:IsValid()) then return end
	ent.garden = nil
	-- if ent.components.temperature ~= nil then
	-- 	ent.components.temperature:RemoveModifier("garden")
	-- end
	if ent.components.playercontroller then
		ent.components.playercontroller:EnableMapControls(true)
	end
	if ent.components.beaverness ~= nil then
		BM.Replace(ent.components.beaverness, "SetPercent")
		if TheWorld.state.moonphase == "full" then
			local fn =ent.worldstatewatching and ent.worldstatewatching.isfullmoon and ent.worldstatewatching.isfullmoon[1]
			if fn ~= nil then
				fn(ent, true)
			end
		end
	end
	if ent.components.builder ~= nil then
		SetBasementBuilder(inst, ent, false)
		inst:PushEvent("unlockrecipe")
		inst:PushEvent("builditem")
		local bufferedbuilds = inst.player_classified and inst.player_classified.bufferedbuilds
		if bufferedbuilds ~= nil then
			for k,v in pairs(bufferedbuilds) do
				local val = v:value()
				v:set_local(val)
				v:set(val)
				break
			end
		end
		removesetter(ent.components.builder, "current_prototyper")
	end
	if ent.LightWatcher ~= nil then
		SetLightWatcherAdditiveThresh(ent)
	end

	SimulateSpawnerEventsForPlayer(ent, "ms_playerjoined")
	OnEntitySleepClient(inst)
end
--追踪地下室的玩家，并改变其状态
local function TrackGardenPlayers(inst)
	if inst.allplayers == nil then
		inst.allplayers = {}
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	local players = table.invert(TheSim:FindEntities(x, y, z, inst.level*5, { "player" }))
	for ent in pairs(players) do
		if not inst.allplayers[ent] then
			AddGardenPlayerBenefits(inst, ent)
			inst.allplayers[ent] = true
		end
	end
	for ent in pairs(inst.allplayers) do
		if players[ent] then--如果在范围内就检查位置并拉回来
			ValidatePosition(ent)
		else--不在范围内就清除获益
			if not ent:IsInGarden() then
				RemoveGardenPlayerBenefits(inst, ent)
				inst:DoTaskInTime(1,function (inst,ent)
					RemoveGardenPlayerBenefits(inst, ent)
				end,ent)
			end
			inst.allplayers[ent] = nil
		end
	end
end

--更新光监听器
local function UpdateLightWatchers(inst)
	if inst.allplayers ~= nil then
		for ent in pairs(inst.allplayers) do
			if ent.LightWatcher ~= nil then
				SetLightWatcherAdditiveThresh(ent, 0)
			end
		end
	end
end
--在屏幕闪烁时
local function OnScreenFlash(inst)
	if inst.tracker ~= nil then
		if inst.tracker.lighting ~= nil then
			inst.tracker.lighting:Cancel()
		end
		inst.tracker.lighting = inst:DoPeriodicTask(2, UpdateLightWatchers, 0)
	end
end
--实体苏醒--主机端--增加墙，玩家追踪，光追踪
local function OnEntityWake(inst)
	inst.tracker =
	{
		lighting =	inst:DoPeriodicTask(2, UpdateLightWatchers, 1),--光监听器
		players =	inst:DoPeriodicTask(0.1, TrackGardenPlayers),--玩家追踪
	}
	
	inst.OnScreenFlash = function() OnScreenFlash(inst) end
	inst:ListenForEvent("screenflash", inst.OnScreenFlash, TheWorld)--屏蔽世界的屏幕闪烁
	inst:WatchWorldState("season", UpdateGardenInsulation)
	UpdateGardenInsulation(inst, TheWorld.state.season)
	SpawnInteriorWalls(inst)--增加墙
end
--实体睡眠--主机--去掉收益，停止玩家追踪
local function OnEntitySleep(inst)
	if inst.tracker ~= nil then
		for name, task in pairs(inst.tracker) do
			task:Cancel()
		end
		inst.tracker = nil
	end
	if inst.allplayers ~= nil then
		for ent in pairs(inst.allplayers) do
			if not ent:IsInGarden() then
				RemoveGardenPlayerBenefits(inst, ent)
			end
		end
		inst.allplayers = nil
	end
	if inst.OnScreenFlash ~= nil then
		inst:RemoveEventCallback("screenflash", inst.OnScreenFlash, TheWorld)
		inst.OnScreenFlash = nil
	end
	
	inst:StopAllWatchingWorldStates()
	-- DespawnInteriorWalls(inst)--删除所有墙
end
--保存函数
local function OnSave(inst, data)
    data.owner = inst.owner
	data.build=inst.build
	data.scale=inst.scale
	data.level=inst.level--大小等级
	data.floor=inst.floor--地板图案
	data.wall=inst.wall--地板的墙
	if inst.garden ~= nil then
		data.garden = {}
		local references = {}
		for name, entity in pairs(inst.garden) do
			data.garden[name] = entity.GUID
			table.insert(references, entity.GUID)
		end
		return references
	end
end
local function playanim(inst)
	if inst.level<14 then--512
		inst.AnimState:SetBank((inst.build.."1") or "wddd1")
		inst.AnimState:SetBuild((inst.build.."1") or "wddd1")
		inst.AnimState:PlayAnimation(inst.floor or "idle1")
	elseif inst.level<22 then--2048
		inst.AnimState:SetBank((inst.build.."2") or "wddd1")
		inst.AnimState:SetBuild((inst.build.."2") or "wddd1")
		inst.AnimState:PlayAnimation(inst.floor or "idle1")
	end
	-- inst.AnimState:SetBank(inst.build or "wddd1")
	-- inst.AnimState:SetBuild(inst.build or "wddd1")
	-- inst.AnimState:PlayAnimation(inst.floor or "idle1")
	inst.AnimState:SetScale(inst.scale or "8.2",inst.scale or "8.2")--设置大小
end
local function DeconstructWall(ent)
	local item_prefab = ent.prefab.."_item"
	if Prefabs[item_prefab] ~= nil then
		if ent.components.lootdropper == nil then
			ent:AddComponent("lootdropper")
		end
		local max = ent.components.health ~= nil and ent.components.health:GetPercent() or 1
		local step = ent.components.repairable ~= nil and 0.25 or 1
		for i = 0, max, step do
			ent.components.lootdropper:SpawnLootPrefab(item_prefab)
		end
		ent:Remove()
	end
end

local function TransformBasement(inst, offset)
	local x, y, z = inst.Transform:GetWorldPosition()
	
	local exit = inst.garden and inst.garden.exit
	if exit and exit:IsValid() then
		exit.Transform:SetPosition(x, 0, z)
	end
	
	for _,v in pairs(TheSim:FindEntities(x, y, z, 90)) do
		if not v.entity:GetParent() then
			v.Transform:SetPosition((Point(v.Transform:GetWorldPosition()) + offset):Get())
			
			if v:HasTag("wall") then
				local x, y, z = v.Transform:GetWorldPosition()
				if Point(x, 0, z) ~= Point(math.floor(x) + 0.5, 0, math.floor(z) + 0.5) then
					DeconstructWall(v)
				end
			end
		end
	end
end
local function FindValidInteriorPosition()
	local tries = 0
	local map_width, map_height = TheWorld.Map:GetSize()
	local min_x, min_z = map_width * 3 + 70, map_height * 3 + 70
	local max_x, max_z = min_x + 130, min_z + 130
    -- print("最大最小位置",min_x,min_z,max_x,max_z)
	while tries <= 50 do
		tries = tries + 1
		local pt1 = math.random(min_x, max_x) * (math.random() < 0.5 and 1 or -1) + 0.5
		local pt2 = math.random(max_z) * (math.random() < 0.5 and 1 or -1) + 0.5
		local x, z = pt1, pt2
		if math.random() < 0.5 then
			x, z = pt2, pt1
		end
		if #TheSim:FindEntities(x, 0, z, 168, { "garden_tile" }) == 0 then
			return TheWorld.Map:GetTileCenterPoint(x, 0, z)
		end
	end
end
--加载函数
local function OnLoad(inst, data, newents)
	if data ~= nil then
        inst.owner = data.owner
		inst.build=data.build
		inst.scale=data.scale
		inst.level=data.level
		inst.level_bm:set(data.level)
		inst.floor=data.floor
		inst.wall=data.wall
		playanim(inst)
		SpawnInteriorWalls(inst)--设置墙
		AddSyntTiles(inst)
		AddSyntTiles(inst)
		if data.garden ~= nil then
			local garden = {}
			for name, GUID in pairs(data.garden) do
				garden[name] = newents[GUID]
			end
			for name, entity in pairs(garden) do
				BM.Replace(entity, "Remove", DespawnGarden)
				entity.garden = garden
			end
		end
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	local current_pos = Point(x, y, z)
	local tile_pos = Point(math.floor(x/4)*4+2, y, math.floor(z/4)*4+2)
	local map_width, map_height = TheWorld.Map:GetSize()
	local min_x, min_z = map_width * 2, map_height * 2
	if current_pos ~= tile_pos or(math.abs(x)<min_x and math.abs(z)<min_z) then
		print("有转移位置emmmmm")
		if math.abs(x)<min_x and math.abs(z)<min_z then
			x, y, z=TheWorld.components.getposition:GetPosition_old()()
			tile_pos=Point(x,y,z)
			print("是位置不对")
		end
		inst:DoTaskInTime(1, TransformBasement, tile_pos - current_pos)
	end
end
--更新墙和地板的函数
local function onupgrade(inst,data)
	if string.find(data.source, "wall") then--墙
		local walls="garden_"..data.source
		if walls~=inst.wall then
			inst.wall=walls
			SpawnInteriorWalls(inst)
		end
	elseif data.source=="addlevel" then--增加等级
		if inst.level>=21 then
			for k,_ in pairs(inst.allplayers) do
				if k.components and k.components.talker then
					k.components.talker:Say("面积已经达到上限")
					return
				end
			end
		end
		inst.level=inst.level+2
		local scale=nil
		if inst.level<10 then--512
			inst.floor="idle1"
			scale=8.2/7*inst.level
		elseif inst.level<14 then--1024
			inst.floor="idle2"
			scale=8.2/7*inst.level/2
		elseif inst.level<18 then--1536
			inst.AnimState:SetBank((inst.build.."2") or "wddd1")
			inst.AnimState:SetBuild((inst.build.."2") or "wddd1")
			inst.floor="idle3"
			scale=8.2/7*inst.level/3
		elseif inst.level<22 then--2048
			inst.floor="idle4"
			scale=8.2/7*inst.level/4
		end
		inst.scale=scale
		-- print("地板为",inst.floor)

		inst.AnimState:PlayAnimation(inst.floor)
		inst.AnimState:SetScale(scale,scale)--设置大小
		inst.level_bm:set(inst.level)
		SpawnInteriorWalls(inst)
		AddSyntTiles(inst)
		AddSyntTiles(inst)
	else
		inst.build=data.source:match("%a+")
		playanim(inst)
	end
end
--基本函数
local function base()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
		
	inst.build="wddd"
	inst.floor="idle1"
	inst.AnimState:SetBank((inst.build.."1") or "wddd1")
	inst.AnimState:SetBuild((inst.build.."1") or "wddd1")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)--用于隐藏洞口最好的选择
	inst.AnimState:SetSortOrder(0)
	-- inst.AnimState:SetLayer( LAYER_BELOW_GROUND )
    -- inst.AnimState:SetSortOrder( 0 )
	inst.AnimState:SetScale(inst.scale or 8.2,inst.scale or 8.2)
	inst.AnimState:PlayAnimation("idle1")
	inst.AnimState:OverrideShade(1)
	-- local AnimState = getmetatable(inst.AnimState).__index
	-- local old_OverrideShade =AnimState.OverrideShade
	-- AnimState.OverrideShade = function(self,...)
	-- 	old_OverrideShade(self,1)
	-- end

	inst.level_bm=net_smallbyte(inst.GUID,"level_bm","changelevel")
	inst:ListenForEvent("changelevel",function (inst)
		-- print("等级",inst.level_bm:value())
		inst:DoTaskInTime(0.1, AddSyntTiles)
		inst:DoTaskInTime(0.1, AddMySyntTiles)
	end)
	inst:AddTag("NOBLOCK")
	inst:AddTag("NOCLICK")
	inst:AddTag("garden_tile")
	inst:AddTag("garden_part")
	inst:AddTag("antlion_sinkhole_blocker")
	inst:AddTag("nonpackable")
	inst:AddTag("lightningrod")--避雷针
	-- inst:DoTaskInTime(0.1, AddSyntTiles)
	-- inst:DoTaskInTime(0.1, AddMySyntTiles)
	if TUNING.CLOUD_BM then
		inst:AddComponent("cloudspawner")
		inst:ListenForEvent("changelevel",function (inst)
			inst.components.cloudspawner:ChangeArea()
		end)
	end
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		inst.OnEntityWake = OnEntityWakeClient
		inst:ListenForEvent("onremove", OnEntitySleepClient)--删除时
		return inst
	end
	inst.level=7
	inst.level_bm:set(inst.level)
	inst.wall="garden_wall1"
	inst.scale=8.2


	inst:DoTaskInTime(0, CheckReferences)--检查入口，出口，地下室，并联系在一起

	-- inst:AddComponent("wateryprotection")--水源保护
	-- inst.components.wateryprotection.extinguishheatpercent = -1--扑灭热量百分比
	-- inst.components.wateryprotection.temperaturereduction = 5--温度下降
	-- inst.components.wateryprotection.witherprotectiontime = 60--枯萎的保护时间
	-- inst.components.wateryprotection.addcoldness = 2--添加冷淡
	-- inst.components.wateryprotection:AddIgnoreTag("player")

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

	if TUNING.LIGHT_BM then
		inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	end
	inst:ListenForEvent("onupgrade", onupgrade)--更新地板和墙

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
					
	return inst
end
return Prefab("garden_floor", base, assets)

--[[
	local terrors = { "attack", "attack_grunt", "die", "hit_response", "idle", "taunt", "appear", "dissappear" }
--播放恐怖声音
local function PlayTerrorSound(proxy)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.entity:SetParent(proxy.entity)

	local theta = math.random() * 2 * PI
	inst.Transform:SetPosition(5 * math.cos(theta), 0, 5 * math.sin(theta))
	inst.SoundEmitter:PlaySound(string.format("dontstarve/sanity/creature%s/%s", math.random(2), terrors[math.random(#terrors)], nil, math.random()))

	inst:Remove()
	-- proxy.garden_terror_task = proxy:DoTaskInTime(math.random(5, 40), PlayTerrorSound)
end
--更改声音大小
local function EnableGardenAmbient(enable)
	TheSim:SetReverbPreset((enable or TheWorld:HasTag("cave")) and "cave" or "default")

	ThePlayer:PushEvent("popdsp", GARDEN_WORLD_STATE.DSP)
	if TheFocalPoint and TheFocalPoint:IsValid() then
		if TheFocalPoint.garden_terror_task ~= nil then
			TheFocalPoint.garden_terror_task:Cancel()
			TheFocalPoint.garden_terror_task = nil
		end
		
		if enable then
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/cave/caveAMB", "gardenAMB")
			TheFocalPoint.garden_terror_task = TheFocalPoint:DoTaskInTime(math.random(10, 40), PlayTerrorSound)
		else
			TheFocalPoint.SoundEmitter:KillSound("gardenAMB")
		end
	end
end
]]