local assets = {
    Asset("ATLAS", "images/inventoryimages/candy_closed.xml"),--糖果球
}
local function BuildFn(inst,builder)
    local x,y,z=inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z,4.1,{"cave_entrance_open"})
    if #ents>0 then
        local cave_entrance_opened=ents[1]
        local openinst = SpawnPrefab("cave_entrance", cave_entrance_opened.linked_skinname, cave_entrance_opened.skin_id )
        openinst.Transform:SetPosition(cave_entrance_opened.Transform:GetWorldPosition())
        openinst.components.worldmigrator.id = cave_entrance_opened.components.worldmigrator.id
        openinst.components.worldmigrator.auto = cave_entrance_opened.components.worldmigrator.auto
        openinst.components.worldmigrator.linkedWorld = cave_entrance_opened.components.worldmigrator.linkedWorld
        openinst.components.worldmigrator.receivedPortal = cave_entrance_opened.components.worldmigrator.receivedPortal
        cave_entrance_opened:Remove()
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.OnBuiltFn = BuildFn
    return inst
end

local function placer_fn()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("cave_entrance")
    inst.AnimState:SetBuild("cave_entrance")
    inst.AnimState:PlayAnimation("idle_closed")
    inst.AnimState:SetLightOverride(1)

    inst:AddComponent("placer")
    local old_update=inst.components.placer.OnUpdate
    inst.components.placer.OnUpdate=function (self,dt)
        old_update(self,dt)
        local pt = self.selected_pos or TheInput:GetWorldPosition()
        local x,y,z=TheWorld.Map:GetTileCenterPoint(pt:Get())
        local ents = TheSim:FindEntities(x,y,z,4,{"cave_entrance_open"})
        if #ents>0 then
            self.inst.Transform:SetPosition(ents[1].Transform:GetWorldPosition())
        end
    end
    -- inst.components.placer.snap_to_tile = true
    return inst
end

return Prefab("candy_entrance", fn,assets),
		Prefab("candy_entrance_placer", placer_fn)
