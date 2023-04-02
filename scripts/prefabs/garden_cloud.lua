local assets =
{
	Asset( "ANIM", "anim/cloud_puff_soft.zip" )
}

local function onSleep(inst)
	inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    if TheNet:GetIsClient() then
        inst.entity:AddClientSleepable()
    end
	inst.persists = false

    anim:SetBuild( "cloud_puff_soft" )
    anim:SetBank( "splash_clouds_drop" )
    anim:PlayAnimation( "idle_sink" )
    inst.AnimState:SetDeltaTimeMultiplier(0.3)--播放速率
    -- inst.AnimState:SetTime(math.random()*0.5 * inst.AnimState:GetCurrentAnimationLength())--从任意起点开始播放动画

	inst:AddTag( "FX" )
	inst:AddTag( "NOCLICK" )
	inst.OnEntitySleep = onSleep
	inst:ListenForEvent( "animover", function(inst) inst:Remove() end )
    return inst
end

return Prefab( "common/fx/cloudpuff", fn, assets )
