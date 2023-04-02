local assets =
{
    Asset("ANIM", "anim/candy_ball.zip"),
}
local function updatestate(inst)
	if not TheWorld.state.isday then
		inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		inst.Light:Enable(true)
	else
		inst.Light:Enable(false)
		inst.AnimState:ClearBloomEffectHandle()
	end
end

local function onopen(inst)
    -- inst.AnimState:PlayAnimation("open")
	-- inst.AnimState:PushAnimation("open_still")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    -- inst.AnimState:PlayAnimation("close")
	-- inst.AnimState:PushAnimation("close_still")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    -- inst.AnimState:PlayAnimation("hit")
    -- inst.AnimState:PushAnimation("idle", false)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
end

--物品保鲜效率
local function itemPreserverRate(inst, item)
	return (item ~= nil and not (item:HasTag("fish") or item.components.health~=nil)) and 0 or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddLight()

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)
    inst.Light:SetColour(180/255, 195/255, 50/255)
    -- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("candy_ball")
    inst.AnimState:SetBuild("candy_ball")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(0.75,0.75)

    inst:AddTag("candy_ball")

    -- MakeInventoryFloatable(inst, "med", 0.1, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst)
            inst.replica.container:WidgetSetup("candy_chest")
        end
        return inst
    end
    -- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	-- inst:AddComponent("edible")
    -- inst.components.edible.foodtype = FOODTYPE.GOODIES
    -- inst.components.edible.healthvalue = 100
    -- inst.components.edible.hungervalue = 100
    -- inst.components.edible.sanityvalue = 100
    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("candy_chest")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	if TUNING.SMART_SIGN_DRAW_ENABLE then
		SMART_SIGN_DRAW(inst)
	end

    inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(itemPreserverRate)--保鲜

    inst:WatchWorldState("isday", updatestate)
	updatestate(inst)

    MakeHauntableWork(inst)
    return inst
end

return Prefab("candy_ball", fn, assets),
MakePlacer("candy_ball_placer","candy_ball","candy_ball","idle",nil,nil,nil,0.75)
-- MakePlacer(name, bank, build, anim, onground, snap, metersnap, scale, fixedcameraoffset, facing, postinit_fn)。
