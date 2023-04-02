local assets =
{
    Asset("ANIM", "anim/candy_ball.zip"),
    Asset("ATLAS", "images/inventoryimages/crystal_ball.xml"),--糖果球
}

local function OnDoneTeleporting(inst, obj)
    if obj ~= nil and obj:HasTag("player") then
        obj:DoTaskInTime(1, obj.PushEvent, "wormholespit") -- for wisecracker
    end
end

--传送时
local function OnActivate(inst, doer)
    if doer:HasTag("player") then
        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end
        if doer.components.sanity ~= nil then
            doer.components.sanity:DoDelta(-25)
        end
    end
end
local function OnActivateByOther(inst, source, doer)
	if doer ~= nil and doer.Physics ~= nil then
		doer.Physics:CollidesWith(COLLISION.WORLD)
	end
end

local function onsave(inst,data)
	data.migration_data = inst.migration_data
end

local function onload(inst,data)
	if data and data.migration_data ~= nil then
		inst.migration_data = data.migration_data
        local x,y,z=inst.migration_data.x,inst.migration_data.y,inst.migration_data.z
        if TheShard:GetShardId()~=inst.migration_data.worldid then--不同世界
            inst.components.teleporter:MigrationTarget(inst.migration_data.worldid,x,y,z)
        else--同一世界
            local target=TheSim:FindEntities(x,y,z,4, {"garden_in","garden_part"})
            if #target>0 then
                inst.components.teleporter:Target(target[1])
            end
        end
	end
end

local function Build(inst,builder)
    local exit =FindEntity(builder, 10, nil, { "garden_part", "garden_exit" })
	if exit ~= nil and exit.components.teleporter and exit.components.teleporter:GetTarget() then
        --同世界传送
        inst.components.teleporter:Target(exit.components.teleporter:GetTarget())
        --跨世界传送
        local x,y,z=exit.components.teleporter:GetTarget().Transform:GetWorldPosition()
        inst.migration_data={worldid = TheShard:GetShardId(), x = x, y = y, z = z}
	end
end
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("candy_ball")
    inst.AnimState:SetBuild("candy_ball")
    inst.AnimState:PlayAnimation("crystal_ball")
    inst.AnimState:SetScale(0.75,0.75)

    MakeInventoryFloatable(inst, "med", 0.2, 0.8)

    inst:AddTag("crystal_ball")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "crystal_ball"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/crystal_ball.xml"

    inst:AddComponent("inspectable")

	-- inst:AddComponent("container")
    -- inst.components.container:WidgetSetup("portable_house_in")

    inst:AddComponent("teleporter")--传送
    inst.components.teleporter.onActivate = OnActivate
    inst.components.teleporter.onActivateByOther = OnActivateByOther
    inst.components.teleporter.offset = 0
	inst.components.teleporter.travelcameratime = 3 * FRAMES
	inst.components.teleporter.travelarrivetime = 12 * FRAMES
	
	inst:ListenForEvent("doneteleporting", OnDoneTeleporting)

	inst.OnSave = onsave
	inst.OnLoad = onload
    -- inst.OnBuiltFn = Build
    inst.OnBuilt=Build

    inst:AddComponent("hauntable")
    --(TUNING.HAUNT_INSTANT_REZ)
    inst.components.hauntable:SetOnHauntFn(function (inst,doer)
        if inst ~= nil and inst.components.teleporter ~= nil and inst.components.teleporter:IsActive() then
            inst.components.teleporter:RegisterTeleportee(doer)
            if inst.components.teleporter:Activate(doer) then
                inst:Remove()
                return true
            end
        end
    end)
    return inst
end
return Prefab("crystal_ball", fn, assets)
