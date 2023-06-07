local turf=require"def/floor_def"
local assets = {
    Asset("ANIM", "anim/floor_candy.zip"),
    Asset("ANIM", "anim/floor_candy1.zip"),
}
local GARDEN_WORLD_STATE = {ENABLED = false}
local music = {
    "dontstarve/music/music_FE_WF", "dontstarve/music/music_FE_yotg",
    "dontstarve/music/music_FE_yotc", "dontstarve/music/music_FE_summerevent",
    "yotb_2021/music/FE"
}
local function EnableGardenAmbient(enable)
    TheSim:SetReverbPreset((enable or TheWorld:HasTag("cave")) and "cave" or"default")
    if TheFocalPoint and TheFocalPoint:IsValid() then
        if enable then
            if TUNING.MUSIC_BM ~= -1 then
                if TUNING.MUSIC_BM == 0 then
                    TheFocalPoint.SoundEmitter:PlaySound(music[math.random(#music)],"garden_music")
                else
                    TheFocalPoint.SoundEmitter:PlaySound(music[TUNING.MUSIC_BM],"garden_music")
                end
            end
        else
            TheFocalPoint.SoundEmitter:KillSound("garden_music")
        end
    end
end
-- 地下室环境改变--光照，声音
local function EnableGardenEnvironment(caller, enable)
    if GARDEN_WORLD_STATE.ENABLED == enable then return end
    EnableGardenAmbient(enable)
    GARDEN_WORLD_STATE.ENABLED = enable
    if enable then
        TheWorld:PushEvent("overrideambientlighting",Point(200 / 255, 200 / 255, 200 / 255))
    else
        TheWorld:PushEvent("overrideambientlighting", nil)
    end

    local clouds = ThePlayer.HUD.clouds
    if clouds ~= nil then
        BM.Replace(clouds, "cloudcolour", enable and {1, 1, 1} or nil)
    end
    local oceancolor = TheWorld.components.oceancolor
    if oceancolor ~= nil then
        TheWorld:StopWallUpdatingComponent(oceancolor)
        oceancolor:Initialize(not enable and TheWorld.has_ocean)
    end
    TheWorld:SetEventMute("screenflash", enable) -- 屏幕闪烁事件静默
end
-- 客户端地下室实体苏醒
local function OnEntityWakeClient(inst)
    if not (ThePlayer and ThePlayer:IsValid()) then return end -- 客户端玩家是否合法
    ThePlayer:SetEventMute("startfarmingmusicevent", true)
    ThePlayer:SetEventMute("playfarmingmusic", true)
    ThePlayer:SetEventMute("play_theme_music", true)
    ThePlayer:DoTaskInTime(0.1, EnableGardenEnvironment, true) -- 加载时轻微延迟
end
-- 客户端实体睡眠
local function OnEntitySleepClient(inst)
    if not (ThePlayer and ThePlayer:IsValid()) then return end -- 客户端玩家是否合法
    ThePlayer:SetEventMute("playfarmingmusic", false) -- play_theme_music
    ThePlayer:SetEventMute("startfarmingmusicevent", false)
    ThePlayer:SetEventMute("play_theme_music", false)
    ThePlayer:DoTaskInTime(0.1, EnableGardenEnvironment, false)
end

-- 将玩家传送回来
local function ValidatePosition(ent)
    if not ent:IsInGarden() and ent:GetTimeAlive() >= 2 then
        local x, y, z = ent.Transform:GetWorldPosition()
        x, z = math.floor(x), math.floor(z)
        local closestdist = math.huge
        local ox, oz
        for i, v in ipairs(BM.Rectangle("16x16", true, true)) do
            local x, y, z = x + v.x, 0, z + v.z
            if TheWorld.Map:IsGardenAtPoint(x, y, z) then
                local dist = ent:GetDistanceSqToPoint(x, y, z)
                if dist < closestdist then
                    closestdist = dist
                    ox, oz = x, z
                end
            end
        end
        if ox then ent.Transform:SetPosition(ox, 0, oz) end
        if not ent:HasTag("player") and ent.components.workable ~= nil and
            ent.components.workable:CanBeWorked() and
            ent.components.workable.action ~= ACTIONS.NET then
            ent.components.workable:Destroy(ent)
        end
    end
end
-- 模拟玩家刷出事件
local function SimulateSpawnerEventsForPlayer(ent, event)
    local t = TheWorld.event_listening and TheWorld.event_listening.event
    if type(t) == "table" and type(t[TheWorld]) == "table" then
        for i, v in ipairs(t[TheWorld]) do
            local upvaluehelper = require "components/upvaluehelper"
            local activeplayers = upvaluehelper.Get(v, "_activeplayers")
            if activeplayers ~= nil then v(TheWorld, ent) end
        end
    end
end

---更新玩家在地下室的收益
local function AddGardenPlayerBenefits(inst, ent)
    ent.garden = inst -- startfarmingmusicevent
    if TUNING.MUSIC_BM then
        inst:SetEventMute("startfarmingmusicevent", true)
        inst:SetEventMute("playfarmingmusic", true)
        inst:SetEventMute("play_theme_music", true)
    end

    if ent.components.playercontroller ~= nil then
        ent.components.playercontroller:EnableMapControls(false)
    end
    -- if ent.components.temperature ~= nil then
	-- 	ent.components.temperature:SetModifier("basement", inst.insulation)
	-- end

    SimulateSpawnerEventsForPlayer(ent, "ms_playerleft")
    OnEntityWakeClient(inst)
end
-- 设置光监视器添加阈值
local function SetLightWatcherAdditiveThresh(ent, thresh)
    thresh = thresh or nil
    ent.LightWatcher:SetLightThresh(thresh or 0.05)
    ent.LightWatcher:SetMinLightThresh(thresh or 0.02) -- for sanity.
    ent.LightWatcher:SetDarkThresh(thresh or .0)
end
-- 删除玩家在地下室的收益
local function RemoveGardenPlayerBenefits(inst, ent)
    if TUNING.MUSIC_BM then
        inst:SetEventMute("playfarmingmusic", false) -- play_theme_music
        inst:SetEventMute("startfarmingmusicevent", false)
        inst:SetEventMute("play_theme_music", false)
    end
    if not (ent and ent:IsValid()) then return end
    ent.garden = nil

    if ent.components.playercontroller then
        ent.components.playercontroller:EnableMapControls(true)
    end
    if ent.components.beaverness ~= nil then
        BM.Replace(ent.components.beaverness, "SetPercent")
        if TheWorld.state.moonphase == "full" then
            local fn = ent.worldstatewatching and
                           ent.worldstatewatching.isfullmoon and
                           ent.worldstatewatching.isfullmoon[1]
            if fn ~= nil then fn(ent, true) end
        end
    end

    if ent.LightWatcher ~= nil then SetLightWatcherAdditiveThresh(ent) end

    SimulateSpawnerEventsForPlayer(ent, "ms_playerjoined")
    OnEntitySleepClient(inst)
end
-- 追踪地下室的玩家，并改变其状态
local function TrackGardenPlayers(inst)
    if inst.allplayers == nil then inst.allplayers = {} end
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = table.invert(TheSim:FindEntities(x, y, z, inst.level * 5,{"player"}))
    for ent in pairs(players) do
        if not inst.allplayers[ent] and ent:IsValid() then
            AddGardenPlayerBenefits(inst, ent)
            inst.allplayers[ent] = true
        end
        if ent:IsValid()then
            if ent.components.temperature then
                ent.components.temperature:SetTemperature(25)
            end
        end
    end
    for ent in pairs(inst.allplayers) do
        if ent and players[ent] then -- 如果在范围内就检查位置并拉回来
            ValidatePosition(ent)
        else -- 不在范围内就清除获益
            if ent and ent:IsValid()then
                if not ent:IsInGarden() then
                    RemoveGardenPlayerBenefits(inst, ent)
                    inst:DoTaskInTime(1, function(inst, ent)
                        RemoveGardenPlayerBenefits(inst, ent)
                    end, ent)
                end
            end
            if ent then
                inst.allplayers[ent] = nil
            end

        end
    end
end

-- 更新光监听器
local function UpdateLightWatchers(inst)
    if inst.allplayers ~= nil then
        for ent in pairs(inst.allplayers) do
            if ent and ent:IsValid() and ent.LightWatcher ~= nil then
                SetLightWatcherAdditiveThresh(ent, 0)
            end
        end
    end
end
-- 在屏幕闪烁时
local function OnScreenFlash(inst)
    if inst.tracker ~= nil then
        if inst.tracker.lighting ~= nil then
            inst.tracker.lighting:Cancel()
        end
        inst.tracker.lighting = inst:DoPeriodicTask(2, UpdateLightWatchers, 0)
    end
end
-- 实体苏醒--主机端--增加墙，玩家追踪，光追踪
local function OnEntityWake(inst)
    inst.tracker = {
        lighting = inst:DoPeriodicTask(2, UpdateLightWatchers, 1), -- 光监听器
        players = inst:DoPeriodicTask(0.1, TrackGardenPlayers) -- 玩家追踪
    }
    inst.OnScreenFlash = function() OnScreenFlash(inst) end
    inst:ListenForEvent("screenflash", inst.OnScreenFlash, TheWorld) -- 屏蔽世界的屏幕闪烁
    inst.components.room_manager:SpawnInteriorWalls() -- 增加墙
end
-- 实体睡眠--主机--去掉收益，停止玩家追踪
local function OnEntitySleep(inst)
    if inst.tracker ~= nil then
        for name, task in pairs(inst.tracker) do task:Cancel() end
        inst.tracker = nil
    end
    if inst.allplayers ~= nil then
        for ent in pairs(inst.allplayers) do
            if ent and ent:IsValid() and not ent:IsInGarden() then
                RemoveGardenPlayerBenefits(inst, ent)
            end
        end
        inst.allplayers = nil
    end
    if inst.OnScreenFlash ~= nil then
        inst:RemoveEventCallback("screenflash", inst.OnScreenFlash, TheWorld)
        inst.OnScreenFlash = nil
    end

    inst:StopAllWatchingWorldStates()
    -- DespawnInteriorWalls(inst)--删除所有墙
end
-- 保存函数
local function OnSave(inst, data)
    data.owner = inst.owner
    data.level = inst.level -- 大小等级
    data.floor = inst.floor -- 地板图案
    data.back  = inst.back
    data.wall = inst.wall -- 地板的墙
    if inst.garden ~= nil then
        data.garden = {}
        local references = {}
        for name, entity in pairs(inst.garden) do
            data.garden[name] = entity.GUID
            table.insert(references, entity.GUID)
        end
        return data,references
    end
end
local function playanim(inst)
    local build_floor= turf[inst.floor] and turf[inst.floor].build
    local build_back=turf[inst.back] and turf[inst.back].build
    --back
    if build_back then
        inst.AnimState:OverrideSymbol("back", build_back, inst.back)
    end
    --floor
    if build_floor then
        inst.AnimState:OverrideSymbol("brich_road", build_floor, inst.floor)
    end
end
-- 加载函数
local function OnLoad(inst, data, newents)
    if data ~= nil then
        inst.owner = data.owner
        inst.level = data.level
        inst.level_bm:set(data.level)
        inst.floor = data.floor or "brich"
        inst.back  = data.back or "brich"
        inst.wall = data.wall

        playanim(inst)
        inst.components.room_manager:SpawnInteriorWalls() -- 增加墙
        inst.components.room_manager:AddSyntTiles() -- 增加地板

        if data.garden ~= nil then
            local garden = {}
            for name, GUID in pairs(data.garden) do
                garden[name] = newents[GUID]
            end
            for name, entity in pairs(garden) do
                BM.Replace(entity, "Remove",inst.components.room_manager.DespawnGarden)
                entity.garden = garden
            end
        end
    end
end

-- 基本函数
local function base()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.Light:SetRadius(2*40)
    inst.Light:SetIntensity(1)
    inst.Light:SetFalloff(1)
    inst.Light:SetColour(255 / 255, 255 / 255, 255 / 255)


    inst.AnimState:SetBank("floor_candy")
    inst.AnimState:SetBuild("floor_candy")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("brich_road", "floor_candy", "brich")
    if not TUNING.BACK_BM then
        inst.AnimState:HideSymbol("back")
    end

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND) -- 用于隐藏洞口最好的选择
    inst.AnimState:SetSortOrder(0)
    inst.AnimState:SetScale(5.3,5.3)
    
    inst.AnimState:OverrideShade(1)
    -- if TUNING.LIGHT_BM then
        -- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		--inst.AnimState:ClearBloomEffectHandle()
    -- end
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("garden_tile") -- 花园地板
    inst:AddTag("garden_part") -- 花园的一部分
    inst:AddTag("antlion_sinkhole_blocker") -- 避免蚁狮
    inst:AddTag("nonpackable")
    inst:AddTag("lightningrod") -- 避雷针


    inst:AddComponent("room_manager")
    inst.level_bm=net_smallbyte(inst.GUID,"level_bm","changelevel")                    --房间当前等级
    --房间等级改变
    inst:ListenForEvent("changelevel",function (inst)
        inst:DoTaskInTime(0.1, function ()
            inst.components.room_manager:AddSyntTiles()
        end)
    end)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst.OnEntityWake = OnEntityWakeClient
        inst:ListenForEvent("onremove", OnEntitySleepClient) -- 删除时
        return inst
    end
    inst.floor = "brich"
    inst.back  = "brich"
    inst.level=7                                                                        --房间当前等级
    inst.level_bm:set(inst.level)                                                       --通知客户端
    inst.wall="garden_wall1"
    inst:DoTaskInTime(0.1,function ()
        inst.components.room_manager:CheckReferences(inst)
    end)
	inst:AddComponent("lootdropper")
    
    inst.playanim = playanim
    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    return inst
end
return Prefab("garden_floor", base, assets)
