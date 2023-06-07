
local function OnCollideStairs(inst, collider)
	if collider and collider:IsValid() then
		local colliderpos = collider:GetPosition()
		if colliderpos == inst:GetPosition() then
			local x, y, z = colliderpos:Get()
			local angle = math.random() * 2 * PI
			local radius = inst:GetPhysicsRadius(0) + math.random() * 0.33
			collider.Physics:Teleport(x + math.cos(angle) * radius, 0, z - math.sin(angle) * radius)
		end
	end
end

local function ReceiveItem(teleporter, item)
	if item.Transform ~= nil then
		local x, y, z = teleporter.inst.Transform:GetWorldPosition()
		local angle = math.random() * 2 * PI
		
		if item.Physics ~= nil then
			item.Physics:Stop()
			if teleporter.inst:IsAsleep() then
				local radius = teleporter.inst:GetPhysicsRadius(0) + math.random()
				item.Physics:Teleport(x + math.cos(angle) * radius, 0, z - math.sin(angle) * radius)
			else
				TemporarilyRemovePhysics(item, 1)
				local speed = 2 + math.random() + teleporter.inst:GetPhysicsRadius(0)
				item.Physics:Teleport(x, 5, z)
				item.Physics:SetVel(speed * math.cos(angle), -1.5, speed * math.sin(angle))
			end
		else
			local radius = 2 + math.random()
			item.Transform:SetPosition(x + math.cos(angle) * radius, 0,	z - math.sin(angle) * radius)
		end
	end
end
local function ExitOnActivateByOther(inst, other, doer)
	doer.sg.statemem.teleportarrivestate = "idle"
end
local function OnActivate(inst, doer)
	if doer:HasTag("player") then
		if doer.components.talker ~= nil then
			doer.components.talker:ShutUp()
		end
        --不能看地图
        if doer.components.playercontroller ~= nil then
			doer.components.playercontroller:EnableMapControls(true)
		end
	else
		-- inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")
	end
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
	inst.AnimState:PlayAnimation("idle")
	-- inst.AnimState:SetScale(1.5,1.5)--设置大小
end
local function onsave(inst,data)
    data.build = inst.build
    data.bank = inst.bank
end
local function onload(inst,data)
	sethousetype(inst, data ~= nil and data.bank, data ~= nil and data.build)
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
local function exit()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:AddLight()
	
	inst.Transform:SetTwoFaced()
	inst.Transform:SetRotation(-45)
	MakeObstaclePhysics(inst, 0.5)
	
	-- inst.AnimState:SetBank("gingerbread_house1")
	-- inst.AnimState:SetBuild("gingerbread_house1")
	-- inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("garden_exit")
	inst:AddTag("garden_part")
	inst:AddTag("nonpackable")
	inst:AddTag("antlion_sinkhole_blocker")
	-- inst:SetDeployExtraSpacing(2.5)
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	inst.Physics:SetCollisionCallback(OnCollideStairs)
	
	inst:AddComponent("inspectable")
	inst:AddComponent("teleporter")
	inst.components.teleporter.onActivate = OnActivate
	inst.components.teleporter.onActivateByOther = ExitOnActivateByOther
	inst.components.teleporter.offset = 0
	inst.components.teleporter.travelcameratime = 3 * FRAMES
	inst.components.teleporter.travelarrivetime = 29 * FRAMES
	inst.components.teleporter.ReceiveItem = ReceiveItem

	if TUNING.LARGE_BM then
		inst:AddComponent("playerprox")
		inst.components.playerprox:SetDist(8,13)
		inst.components.playerprox:SetOnPlayerNear(onnear)									
		inst.components.playerprox:SetOnPlayerFar(onfar)
	end

	inst:AddComponent("prototyper")
	inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.GARDEN_TECH

	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.Light:Enable(true)
	inst.OnSave = onsave
	inst.OnLoad = onload

	return inst
end

return 	Prefab("garden_exit", exit)