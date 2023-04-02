local function OnSnowCoveredChagned(inst, covered)
    if TheWorld.state.isday then
        print("正在兑换")
        inst.AnimState:OverrideSymbol("back", "floor_candy", "grass")
		inst.AnimState:OverrideSymbol("brich_road", "floor_candy", "brich_road")
	elseif TheWorld.state.isnight then
        print("晚上")
        inst.AnimState:OverrideSymbol("back", "floor_candy", "brich_road")
		-- inst.AnimState:OverrideSymbol("back", "floor_candy", "brich_grass")
    else
        inst.AnimState:OverrideSymbol("back", "floor_candy", "brich")
        inst.AnimState:OverrideSymbol("brich_road", "floor_candy1", "grass_road")
	end
end
--[[
    floor_candy:
        brich_road
        brich_grass
        ancient_moon
        board
        brich
        cowhiar
        grass
        --------------back--brich
    floor_candy1:
        shell
        road_grass
        road
        moon
        marble
        grassland
        grass_road
        board_road

]]
local function wall_common()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    inst.Transform:SetEightFaced()
    
    inst:AddTag("blocker")
    inst:AddTag("NOBLOCK")
    inst:AddTag("birdblocker")
    
    inst.AnimState:SetBank("floor_candy")
    inst.AnimState:SetBuild("floor_candy")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND) -- 用于隐藏洞口最好的选择
    inst.AnimState:SetSortOrder(0)
    inst.AnimState:SetScale(5.41,5.41)
    -- inst.AnimState:OverrideSymbol("brich_road", "floor_candy2", "brich_grass")
    
    inst.AnimState:OverrideShade(1)
        
    inst:AddTag("NOCLICK")
    inst:AddTag("basement_part")
    inst:AddTag("antlion_sinkhole_blocker")
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:WatchWorldState("isday", OnSnowCoveredChagned)
    OnSnowCoveredChagned(inst)
    return inst
end
return Prefab("itemttt",wall_common)