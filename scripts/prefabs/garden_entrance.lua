local function OnActivate(inst, doer)
	if doer:HasTag("player") then
		if doer.components.talker ~= nil then
			doer.components.talker:ShutUp()
		end
        --不能看地图
        if doer.components.playercontroller ~= nil then
			doer.components.playercontroller:EnableMapControls(false)
		end
		doer:AddTag("garden_member")
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
	else
		-- inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")
	end
end
local function OnActivateByOther(inst, source, doer)
	if doer ~= nil and doer.Physics ~= nil then
		doer.Physics:CollidesWith(COLLISION.WORLD)
	end
end
--接收物品时
local function OnAccept(inst, giver, item)
	inst.components.inventory:DropItem(item)
	inst.components.teleporter:Activate(item)
end
--播放传送的声音
local function PlayTravelSound(inst, doer)
	inst.SoundEmitter:PlaySound("dontstarve/cave/rope_down")
end
local function FindValidInteriorPosition()
	-- for x=-1440,1440,180 do
	-- 	for z=-1440,1440,2880 do
	-- 		if #TheSim:FindEntities(x, 0, z, 20, { "garden_tile" }) == 0 then
	-- 			return TheWorld.Map:GetTileCenterPoint(x, 0, z)
	-- 		elseif #TheSim:FindEntities(z, 0, x, 20, { "garden_tile" }) == 0 then
	-- 			return TheWorld.Map:GetTileCenterPoint(z, 0, x)
	-- 		end
	-- 	end
	-- end
	-- for x=-1440,1440,180 do
	-- 	for z=-1440,1440,2880 do
	-- 		if #TheSim:FindEntities(z, 0, x, 20, { "garden_tile" }) == 0 then
	-- 			return TheWorld.Map:GetTileCenterPoint(z, 0, x)
	-- 		end
	-- 	end
	-- end
	-- local tries = 0
	-- local min_x, min_z =1440,1440
	-- local max_x, max_z = min_x + 130, min_z + 130
    -- -- print("最大最小位置",min_x,min_z,max_x,max_z)
	-- while tries <= 50 do
	-- 	tries = tries + 1
	-- 	local pt1 = math.random(min_x, max_x) * (math.random() < 0.5 and 1 or -1) + 0.5
	-- 	local pt2 = math.random(max_z) * (math.random() < 0.5 and 1 or -1) + 0.5
	-- 	local x, z = pt1, pt2
	-- 	if math.random() < 0.5 then
	-- 		x, z = pt2, pt1
	-- 	end
	-- 	if #TheSim:FindEntities(x, 0, z, 168, { "garden_tile" }) == 0 then
	-- 		return TheWorld.Map:GetTileCenterPoint(x, 0, z)
	-- 	end
	-- end
end
--[[
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
]]

local function BuildGarden(inst,builder)
	-- if inst.ok then return end
	-- inst.ok=true
	local garden = {}
    -- garden.owner=builder.userid
	garden.entrance = inst
	local x, y, z = TheWorld.components.getposition:GetPosition()
	-- print("当前位置",x,y,z)
	-- print("位置为",x,y,z)
	if x == nil then
		TheNet:Announce("当前世界糖果屋数量过多，未能找到有效位置")
		return
	end
	TheWorld.components.getposition:CreateHome()
	garden.exit = SpawnPrefab("garden_exit")
	garden.exit.Transform:SetPosition(x, y, z)
	garden.exit.AnimState:SetBuild(inst.build)
	garden.exit.AnimState:SetBank(inst.bank)
	garden.exit.AnimState:PlayAnimation("idle")
	garden.exit.build=inst.build
	garden.exit.bank=inst.bank
    
	garden.entrance.components.teleporter.targetTeleporter = garden.exit
	garden.exit.components.teleporter.targetTeleporter = garden.entrance

	garden.core = SpawnPrefab("garden_floor")
	garden.core.Transform:SetPosition(x, y, z)
end
local animdata =
{
    { build = "gingerbread_house1", bank = "gingerbread_house1" },--door_closing
    { build = "gingerbread_house3", bank = "gingerbread_house2" },--door_closing
    { build = "gingerbread_house2", bank = "gingerbread_house2" },
    { build = "gingerbread_house4", bank = "gingerbread_house1" },
}
local function sethousetype(inst, bank, build)
	if build == nil or bank == nil then
		local index = math.random(#animdata)
		inst.build = animdata[index].build
		inst.bank  = animdata[index].bank
	else
        inst.build = build
        inst.bank = bank
	end

    inst.AnimState:SetBuild(inst.build)
    inst.AnimState:SetBank(inst.bank)
	-- inst.AnimState:SetScale(1.5,1.5)--设置大小
end
local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
    end
end
local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end
local function onsave(inst,data)
    data.build = inst.build
    data.bank = inst.bank
end
local function onload(inst,data)
	sethousetype(inst, data ~= nil and data.bank, data ~= nil and data.build)
end
local function updatestate(inst)
	if not TheWorld.state.isday then
		inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		inst.Light:Enable(true)
	else
		inst.Light:Enable(false)
		inst.AnimState:ClearBloomEffectHandle()
	end
end
local function stop(inst)
	if inst.itemscale then
		inst.itemscale:SetList(nil)
		inst.itemscale=nil
	end
end
local function AnimateScale(inst,start_scale,end_scale)
	if inst.itemscale~=nil then
		return
	end
	start_scale=start_scale or 1
    inst.itemscale=inst:StartThread(function()
		local total_time=1.5
        -- local time_left = total_time or 1
        local start_time = GetTime()
        -- local end_time = start_time + total_time
        local AnimState = inst.AnimState
        while true do
            local t = GetTime()
            local percent = (t - start_time) / total_time
            if percent > 1 then
				stop(inst)
                AnimState:SetScale(end_scale, end_scale, end_scale)
                return
            end
            local scale = (1 - percent) * start_scale + percent * end_scale
            AnimState:SetScale(scale, scale, scale)
			inst.scale=scale
            Yield()
        end
    end)
end
local function onnear(inst)
	stop(inst)
	AnimateScale(inst,inst.scale,2)
end
local function onfar(inst)
	-- local scale=inst.Transform and inst.Transform:GetScale()
	stop(inst)
	AnimateScale(inst,inst.scale,1)
end
local function entrance()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:AddLight()
	
	-- inst.Transform:SetTwoFaced()
	MakeObstaclePhysics(inst, 0.5)
	inst.AnimState:SetBank("gingerbread_house1")
	inst.AnimState:SetBuild("gingerbread_house1")
	inst.AnimState:PlayAnimation("idle")
	-- inst.AnimState:SetLayer(LAYER_BACKGROUND)
	-- inst.AnimState:SetSortOrder(3)
	inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)
    inst.Light:SetColour(180/255, 195/255, 50/255)

	inst:AddTag("structure")
	inst:AddTag("garden_part")
	inst:AddTag("garden_in")
	inst:AddTag("shelter")
	inst:AddTag("nonpackable")
	inst:AddTag("antlion_sinkhole_blocker")
	-- inst:SetDeployExtraSpacing(2.5)
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	sethousetype(inst)
	inst:AddComponent("inspectable")
	-- inst.components.inspectable.getstatus = GetStatus
	inst:AddComponent("teleporter")
	inst.components.teleporter.onActivate = OnActivate
	inst.components.teleporter.onActivateByOther = OnActivateByOther
	inst.components.teleporter.offset = 0
	inst.components.teleporter.travelcameratime = 3 * FRAMES
	inst.components.teleporter.travelarrivetime = 12 * FRAMES
	
	inst:AddComponent("inventory")
	inst:AddComponent("trader")
	inst.components.trader.acceptnontradable = true
	inst.components.trader.onaccept = OnAccept
	inst.components.trader.deleteitemonaccept = false

	inst:AddComponent("lootdropper")
	if TUNING.HAMER_BM then
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(4)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit)
	end
	if TUNING.LARGE_BM then
		inst:AddComponent("playerprox")
		inst.components.playerprox:SetDist(8,13)
		inst.components.playerprox:SetOnPlayerNear(onnear)									
		inst.components.playerprox:SetOnPlayerFar(onfar)
	end
	-- inst:AddComponent("bloomer")
	-- if owner.components.bloomer ~= nil then
    --     owner.components.bloomer:PushBloom(inst, "shaders/anim.ksh", 1)
    -- else
    --     owner.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    -- end
	
	-- inst:ListenForEvent("starttravelsound", PlayTravelSound)
    inst:WatchWorldState("isday", updatestate)
	updatestate(inst)
    inst.OnBuiltFn = BuildGarden
	inst.OnSave = onsave
	inst.OnLoad = onload
	return inst
end

return 	Prefab("garden_entrance", entrance),
MakePlacer("garden_entrance_placer","gingerbread_house2","gingerbread_house2","idle")