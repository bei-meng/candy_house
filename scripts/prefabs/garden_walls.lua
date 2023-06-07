require "prefabutil"
local WALL_ANIM_VARIANTS = { "fullA", "fullB", "fullC" }
--更新路径
local function UpdatePathFinding(inst, enable)
	if inst:IsValid() and enable then
		if inst._pfpos == nil then
			inst._pfpos = inst:GetPosition()
			TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
		end
	elseif inst._pfpos ~= nil then
		TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
		inst._pfpos = nil
	end
end
--不同的位置对应不同动画
local function ResolveAndPlayWallAnim(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	x = math.floor(x)
    z = math.floor(z)      
	local q1 = #WALL_ANIM_VARIANTS + 1
    local q2 = #WALL_ANIM_VARIANTS + 4
    local i = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #WALL_ANIM_VARIANTS + 1
	inst.AnimState:PlayAnimation(WALL_ANIM_VARIANTS[i])
end
local function Maker_wall(name,bank,build)
    local function wall_common()
        local inst = CreateEntity()
        
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        
        inst.Transform:SetEightFaced()
        
        inst:AddTag("blocker")
        inst:AddTag("NOBLOCK")
        inst:AddTag("birdblocker")

        
        local phys = inst.entity:AddPhysics()
        phys:SetMass(0)
        phys:SetCollisionGroup(COLLISION.WORLD)
        phys:ClearCollisionMask()
        phys:CollidesWith(COLLISION.ITEMS)
        phys:CollidesWith(COLLISION.CHARACTERS)
        phys:CollidesWith(COLLISION.GIANTS)
        phys:CollidesWith(COLLISION.FLYERS)
        phys:SetCapsule(0.5, 50)
        inst.Physics:SetDontRemoveOnSleep(true)
        
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:OverrideShade(1)
            
        inst:AddTag("NOCLICK")
        inst:AddTag("basement_part")
        inst:AddTag("antlion_sinkhole_blocker")
        
        inst:DoTaskInTime(0, UpdatePathFinding, true)
        inst:ListenForEvent("onremove", UpdatePathFinding)
        
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst:DoTaskInTime(0, ResolveAndPlayWallAnim)
        -- if TUNING.LIGHT_BM then
        --     inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        -- end
        inst.persists = false
        return inst
    end
    return Prefab(name,wall_common)
end
return Maker_wall("garden_wall1","wall","wall_stone"),--普通石墙
       Maker_wall("garden_wall2","wall","wall_stone_2"),--尖尖石墙
       Maker_wall("garden_wall3","wall","wall_ruins"),--远古石墙
       Maker_wall("garden_wall4","wall","wall_ruins_2"),--远古石墙2
       Maker_wall("garden_wall5","wall","wall_moonrock"),--月石墙
       Maker_wall("garden_wall6","wall","wall_wood")--木墙