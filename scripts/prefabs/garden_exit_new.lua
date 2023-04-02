local assets = {
    Asset("ANIM", "anim/candy_house.zip"),
}

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
	end
end

local function exit()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	inst.AnimState:SetBank("exit")
	inst.AnimState:SetBuild("candy_house")
	inst.AnimState:PlayAnimation("idle")

	inst.Transform:SetRotation(-45)
	MakeObstaclePhysics(inst, 0.5)
	
	inst:AddTag("garden_exit")
	inst:AddTag("garden_part")
	inst:AddTag("nonpackable")
	inst:AddTag("antlion_sinkhole_blocker")
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

	inst:AddComponent("prototyper")
	inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.GARDEN_TECH

	return inst
end

return 	Prefab("garden_exit1", exit,assets)