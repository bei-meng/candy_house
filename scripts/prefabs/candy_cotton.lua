local assets =
{
    Asset("ANIM", "anim/candy_cotton.zip"),
    Asset("ATLAS", "images/inventoryimages/candy_cotton.xml"),--糖果球
}
local function oneaten_raw(inst, eater)
    eater:AddDebuff("sanregenbuff", "sanregenbuff")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("candy_cotton")
    inst.AnimState:SetBuild("candy_cotton")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.2, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "candy_cotton"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/candy_cotton.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 10
    inst.components.edible.hungervalue = 5
    inst.components.edible.sanityvalue = 10
    inst.components.edible:SetOnEatenFn(oneaten_raw)

    inst:AddComponent("inspectable")
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("tradable")

    MakeHauntableLaunchAndIgnite(inst)
    return inst
end
return Prefab("candy_cotton", fn, assets)
