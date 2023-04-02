local candy_tree_assets = {
    Asset("ANIM", "anim/candy_tree.zip"),--树的动画
    Asset("ATLAS", "images/inventoryimages/candy_tree.xml"),--糖果球
}

local total_day_time=TUNING.TOTAL_DAY_TIME
local day_time=TUNING.DAY_TIME_DEFAULT

SetSharedLootTable("candy_tree",
{
    {"candy_log", 1.0},
    {"candy_log", 1.0},
    {"petals", 1.0},
})
SetSharedLootTable("candy_tree1",
{
    {"candy_log", 1.0},
    {"candy_log", 1.0},
    {"candy_log", 1.0},
    {"candy_cotton", 1.0},
})
SetSharedLootTable("candy_tree2",
{
    {"candy_log", 1.0},
    {"candy_log", 1.0},
    {"candy_log", 1.0},
    {"candy_cotton", 1.0},
    {"candy_cotton", 1.0},
})
SetSharedLootTable("candy_tree4",
{
    {"candy_log", 1.0},
    {"candy_log", 1.0},
    {"candy_log", 1.0},
    {"candy_cotton", 1.0},
    {"candy_cotton", 1.0},
    {"candy_cotton", 1.0},
    {"candy_cotton", 1.0},
})
--检查树的描述，烧毁或者砍倒了
local function inspect_fu_tree(inst)
    return(inst:HasTag("stump") and "CHOPPED")
        or nil
end
--砍树时设置的一些动画声音
local function on_chop_tree(inst, chopper)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end
    inst.AnimState:PlayAnimation("chop")
    inst.AnimState:PushAnimation("idle",true)

    local x, y, z = inst.Transform:GetWorldPosition()
    -- local tree_fx = SpawnPrefab("tree_petal_fx_chop")
    local tree_fx = SpawnPrefab("red_leaves_chop")
    y = y + 1.0 + math.random() * 0.25
    tree_fx.Transform:SetPosition(x+math.random() * 0.25, y, z)
    tree_fx.Transform:SetScale(1.25, 1.25, 1.25)
end
--挖树桩时的东西
local function dig_up_stump(inst, digger)
	inst.components.lootdropper:SpawnLootPrefab("candy_log")
    -- inst.components.lootdropper:SpawnLootPrefab("candy_log")
    inst:Remove()
end
--设置燃烧效果
local function make_stump_burnable(inst)
    MakeLargeBurnable(inst)
    inst.components.burnable:SetFXLevel(5)
end
--产生树桩的函数
local function make_stump(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("hauntable")
    inst:RemoveComponent("growable")
    inst:RemoveComponent("pickable")
    inst:RemoveTag("shelter")

    make_stump_burnable(inst)
    MakeMediumPropagator(inst)
    MakeHauntableIgnite(inst)

    RemovePhysicsColliders(inst)

    inst:AddTag("stump")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)
end
---砍倒树时的动画，声音效果
local function on_chop_tree_down(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    local pt = inst:GetPosition()
    inst.AnimState:PlayAnimation("fall")
    inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())

    inst:DoTaskInTime(0.4, function (inst)
        ShakeAllCameras( CAMERASHAKE.FULL, .25, .03, .5 or .25, inst, 6 )
    end)

    make_stump(inst)
    inst.AnimState:PushAnimation("root")
end
local function update_level(inst)
    if inst.level<1 then
        for i=1,4 do
            inst.AnimState:HideSymbol("fruit"..tostring(i))
        end
        if inst.components.pickable then
            inst.components.pickable.canbepicked = false
        end
        return
    end
    --隐藏
    for i=inst.level,4 do
        inst.AnimState:HideSymbol("fruit"..tostring(i))
    end
    --显示
    for i=1,inst.level do
        inst.AnimState:ShowSymbol("fruit"..tostring(i))
    end
    if inst.components.pickable then
        inst.components.pickable.canbepicked = true
        inst.components.pickable:SetUp("candy_cotton",nil, inst.level)
    end
end
--保存一些状态
local function on_save(inst, data)
    if inst:HasTag("stump") then

        data.stump = true
    end
end
---加载时进行的一些操作
local function on_load(inst, data)
    if data == nil then
        return
    end
    if data.stump then
        make_stump(inst)
        inst.level=0
        inst.AnimState:PlayAnimation("root")
    end
end

---在加载范围内
local function on_wake(inst)
    if inst.components.inspectable == nil then
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_fu_tree
    end
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

local stage={
    {
        name = "samll",
        time = function(inst)
            return math.random(TUNING.TOTAL_DAY_TIME,TUNING.TOTAL_DAY_TIME*2)
        end,
        fn = function (inst)
            if inst.level==4 then
                inst.components.lootdropper:SpawnLootPrefab("candy_log")
                inst.components.lootdropper:SpawnLootPrefab("candy_cotton")
                -- inst.components.lootdropper:SpawnLootPrefab("spoiled_food")
            end
            inst.level=0
            update_level(inst)
            inst.components.lootdropper:SetChanceLootTable("candy_tree")
        end,
        -- growfn = grow_short,
    },
    {
        name = "normal",
        time = function(inst)
            return math.random(TUNING.TOTAL_DAY_TIME,TUNING.TOTAL_DAY_TIME*2)
        end,
        fn = function (inst)
            inst.level=1
            update_level(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
            inst.components.lootdropper:SetChanceLootTable("candy_tree1")
        end,
        growfn = function (inst)
            if math.random()<0.25 then
                inst.components.lootdropper:SpawnLootPrefab("candy_log")
            end
        end,
    },
    {
        name = "medium",
        time = function(inst)
            return math.random(TUNING.TOTAL_DAY_TIME*2,TUNING.TOTAL_DAY_TIME*3)
        end,
        fn = function (inst)
            inst.level=2
            update_level(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
            inst.components.lootdropper:SetChanceLootTable("candy_tree2")
        end,
        growfn = function (inst)
            if math.random()<0.5 then
                inst.components.lootdropper:SpawnLootPrefab("candy_log")
            end
        end,
    },
    {
        name = "tall",
        time = function(inst)
            return math.random(TUNING.TOTAL_DAY_TIME*2,TUNING.TOTAL_DAY_TIME*3)
        end,
        fn = function (inst)
            inst.level=4
            update_level(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
            inst.components.lootdropper:SetChanceLootTable("candy_tree4")
        end,
        -- growfn = function (inst)
        --     inst.components.lootdropper:SpawnLootPrefab("candy_log")
        --     inst.components.lootdropper:SpawnLootPrefab("candy_cotton")
        -- end,
    },
    -- {
    --     name = "tall",
    --     time = function(inst)
    --         return math.random(TUNING.TOTAL_DAY_TIME*2,TUNING.TOTAL_DAY_TIME*3)
    --     end,
    --     fn = function (inst)
    --         inst.level=4
    --         update_level(inst)
    --         inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    --         inst.components.lootdropper:SetChanceLootTable("candy_tree4")
    --     end,
    --     -- growfn = grow_tall,
    -- },
}
local function OnCheck(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, nil, { "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }, { "smolder" })
    for i, v in pairs(ents) do
        if v.components.burnable ~= nil then
			if v.components.burnable:IsSmoldering() then
				v.components.burnable:SmotherSmolder()
			end
        end	
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	inst.entity:AddLight()

    inst.Light:SetFalloff(0.8)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(4)
    inst.Light:Enable(false)
    inst.Light:SetColour(250/255, 195/255, 50/255)
    --(180/255, 195/255, 50/255)--(255/255, 48/255, 48/255)
    -- inst.Light:SetColour(255/255, 99/255, 71/255)

    
    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("candy_tree.tex")
    inst.MiniMapEntity:SetPriority(-1)

    inst:AddTag("plant")
    inst:AddTag("tree")
    inst:AddTag("shelter")

    inst.AnimState:SetBank("candy_tree")
    inst.AnimState:SetBuild("candy_tree")
    inst.AnimState:PlayAnimation("idle", true)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.level=0
    update_level(inst)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_fu_tree

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetOnWorkCallback(on_chop_tree)
    inst.components.workable:SetOnFinishCallback(on_chop_tree_down)
    inst.components.workable:SetWorkLeft(30)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("candy_tree")

    inst:AddComponent("pickable")
    inst.components.pickable:SetOnPickedFn(function (inst,picker, loot)
        -- inst.level=0
        inst.components.growable:SetStage(1)
        inst.components.growable:StartGrowing()
    end)

    inst:AddComponent("growable")
    inst.components.growable.stages = stage
    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()
    inst.components.growable.loopstages = true

    inst:WatchWorldState("isday", updatestate)
	updatestate(inst)
    inst.check = inst:DoPeriodicTask(1, OnCheck,1)
    MakeHauntableWork(inst)

    inst.OnSave = on_save
    inst.OnLoad = on_load

    MakeSnowCovered(inst)

    inst.OnEntityWake = on_wake
    return inst
end
return Prefab("candy_tree", fn, candy_tree_assets),
MakePlacer("candy_tree_placer","candy_tree","candy_tree","idle",nil,nil,nil,1)