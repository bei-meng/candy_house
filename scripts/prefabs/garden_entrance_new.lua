local function OnActivate(inst, doer)
	if doer:HasTag("player") then
		if doer.components.talker ~= nil then
			doer.components.talker:ShutUp()
		end
        if doer.components.playercontroller ~= nil then
			doer.components.playercontroller:EnableMapControls(false)
		end
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
local function BuildGarden(inst,builder)
	local garden = {}
	garden.entrance = inst
	local x, y, z = TheWorld.components.getposition:GetPosition()
	if x == nil then
		TheNet:Announce("当前世界糖果屋数量过多，未能找到有效位置")
		return
	end
	TheWorld.components.getposition:CreateHome()
	garden.exit = SpawnPrefab("garden_exit1")
	garden.exit.Transform:SetPosition(x, y, z)
	-- garden.exit.AnimState:SetBuild(inst.build)
	-- garden.exit.AnimState:SetBank(inst.bank)
	-- garden.exit.AnimState:PlayAnimation("idle")
	-- garden.exit.build=inst.build
	-- garden.exit.bank=inst.bank
    
	garden.entrance.components.teleporter.targetTeleporter = garden.exit
	garden.exit.components.teleporter.targetTeleporter = garden.entrance

	garden.core = SpawnPrefab("garden_floor")
	garden.core.Transform:SetPosition(x, y, z)
	garden.core.components.room_manager:Spawn(x, y, z)
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

local function updatestate(inst)
	if not TheWorld.state.isday then
		inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		inst.Light:Enable(true)
	else
		inst.Light:Enable(false)
		inst.AnimState:ClearBloomEffectHandle()
	end
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
	inst.AnimState:SetBank("entrance")
	inst.AnimState:SetBuild("candy_house")
	inst.AnimState:PlayAnimation("idle")
	-- inst.AnimState:SetLayer(LAYER_BACKGROUND)
	-- inst.AnimState:SetSortOrder(3)
	inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)
    inst.Light:SetColour(180/255, 195/255, 50/255)
	-- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")


	inst:AddTag("structure")
	inst:AddTag("garden_part")
	inst:AddTag("garden_in")
	-- inst:AddTag("shelter")
	inst:AddTag("nonpackable")
	inst:AddTag("antlion_sinkhole_blocker")

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

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

    inst:WatchWorldState("isday", updatestate)
	updatestate(inst)
    inst.OnBuiltFn = BuildGarden
	return inst
end

return 	Prefab("garden_entrance1", entrance),
MakePlacer("garden_entrance1_placer","entrance","candy_house","idle")