local actions = {
    {
        id = "CALLPAPER",---召唤随从的动作
        str = STRINGS.ACTIONS.CALLPAPER,
        actiondata = {
            strfn = function(act)
                return (act.target == nil or act.target == act.doer)
                    and TheInput:ControllerAttached()
                    and "SELF"
                    or nil
                end
        },
        fn = function(act)
            if act.doer ~= nil and act.invobject ~= nil then
                if act.doer.components.callpaper then
                    if act.doer.components.callpaper:IsFull() then
                        act.doer:DoTaskInTime(0,function (inst)
                            inst.components.talker:Say("随从已达到最大值")
                        end)
                    else
                        local pt = act.doer:GetPosition()
                        act.doer.components.callpaper:SpawnPaperAt(pt.x+1,pt.y,pt.z+1)
                        if act.invobject.components.finiteuses then
                            act.invobject.components.finiteuses:Use(1)
                        end
                    end
                end
                return true
			end
        end,
        state = "doshortaction"
    },
    {--产生那个能召唤随从的纸人
        id = "COMPOUNDPAPER",
        str = STRINGS.ACTIONS.COMPOUNDPAPER,
        actiondata = {
            strfn = function(act)
                return (act.target == nil or act.target == act.doer)
                    and TheInput:ControllerAttached()
                    and "SELF"
                    or nil
                end
        },
        fn = function(act)
            if act.doer ~= nil and act.invobject ~= nil then
				local item1 = (act.target.components.stackable and act.target.components.stackable:Get()) or act.target
				local item2 = (act.invobject.components.stackable and act.invobject.components.stackable:Get()) or act.invobject
				item1:Remove()
				item2:Remove()
                act.doer.components.inventory:GiveItem(SpawnPrefab("suicong_wupin"))
                return true
			end
        end,
        state = "dolongaction"
    },
    {--打开花轿
        id = "KAIHUAJIAO",
        str = STRINGS.ACTIONS.KAIHUAJIAO,
        -- actiondata = {
        --     strfn = function(act)
        --         return (act.target == nil or act.target == act.doer)
        --             and TheInput:ControllerAttached()
        --             and "SELF"
        --             or nil
        --         end
        -- },
        fn = function(act)
			if act.doer ~= nil and act.invobject ~= nil and act.target.numtogive==1 then
				local pt = act.target:GetPosition()
				act.target.components.lootdropper:DropLoot(pt)
                if math.random()<0.02 then
                    SpawnAt("fu_fireworks",act.target)
                end
				act.target:Remove()
				act.invobject:Remove()
                if act.doer.components.talker then
                    act.doer.components.talker:Say("里面是什么？")
                end
				return true
			else
                if act.doer.components.talker then
                    act.doer.components.talker:Say("也许我需要在耐心等待一下")
                end
                return false
			end
        end,
        state = "give"
    },
    {--打开花轿
    id = "DOCUSTOMANIM",
    str = STRINGS.ACTIONS.DOCUSTOMANIM,
    -- actiondata = {
    --     strfn = function(act)
    --         return (act.target == nil or act.target == act.doer)
    --             and TheInput:ControllerAttached()
    --             and "SELF"
    --             or nil
    --         end
    -- },
    fn = function(act)
        if act.doer ~= nil and act.invobject ~= nil and act.invobject.prefab == "juanzhou" then
            local treasure_map = act.doer.components.inventory:RemoveItem(act.invobject)
            local talker = act.doer.components.talker 
            local result=false--生成结果
            if treasure_map then
                if treasure_map.sc then
                    result=treasure_map.sc(treasure_map, act.doer)
                end
                --生成成功，移除卷轴
                if result then
                    treasure_map:Remove()
                else--否则返还卷轴，并感叹上面的字看不清
                    if talker and not act.doer:HasTag("mime") then
                        talker:Say("我被蒙蔽了双眼")
                    end
                    act.doer.components.inventory:GiveItem(treasure_map)
                end
                return true
            end
            return false
        end
    end,
    state = "doshortaction"
    },
}
local component_actions = {
    {
        type = "INVENTORY",----对应纸人召唤随从的动作
        component = "callpaper",
        tests = {
            {
                action = "CALLPAPER",
                testfn = function(inst, doer, target, actions, right)
                    return doer:HasTag("player") and inst.prefab =="suicong_wupin"
                end
            }
        }
    },
    {
        type = "USEITEM",----生成纸人的动作
        component = "z_fu_nil1",
        tests = {
            {
                action = "COMPOUNDPAPER",
                testfn = function(inst, doer, target, actions, right)
                    return doer:HasTag("player") and inst.prefab == "renshenguo"  and target.prefab == "fu_yuanbao"
                end
            }
        }
    },
    {
        type = "USEITEM",--打开花轿
        component = "inventoryitem",
        tests = {
            {
                action = "KAIHUAJIAO",
                testfn = function(inst, doer, target, actions, right)
                    return doer:HasTag("player") and inst.prefab == "fu_shou"  and target:HasTag("huajiao")
                end
            }
        }
    },
    {
        type = "INVENTORY",--打开卷轴
        component = "inventoryitem",
        tests = {
            {
                action = "DOCUSTOMANIM",
                testfn = function(inst, doer, actions, right)
                    	return doer:HasTag("player") and inst.prefab == "juanzhou"
                end
            }
        }
    },
}

-- AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
-- 	if doer:HasTag("player") and inst.prefab == "juanzhou" then
-- 		table.insert(actions, ACTIONS.DOCUSTOMANIM)
-- 	end
-- end)
	



return {actions = actions, component_actions = component_actions}
--进入广寒宫和方寸山的动作
--[[MYTH_RED_GIVE
local MYTH_ENTER_HOUSE = Action({ priority=1, mount_valid = true,ghost_valid=true, encumbered_valid=true})
MYTH_ENTER_HOUSE.id = "MYTH_ENTER_HOUSE"
MYTH_ENTER_HOUSE.strfn = function(act)
    if act.doer ~= nil and act.doer:HasTag("playerghost") then
		return  "HAUNT"
	end
	return act.target ~= nil and string.upper(act.target.prefab) or nil
end
local IsFlying = function(inst) return inst and inst.components.mk_flyer and inst.components.mk_flyer:IsFlying()end
MYTH_ENTER_HOUSE.fn = function(act)
    if act.doer ~= nil and
        act.doer.sg ~= nil and
        act.doer.sg.currentstate.name == "mythhousein_pre" then
        if act.target ~= nil and
            act.target.components.myth_teleporter ~= nil and
            act.target.components.myth_teleporter:IsActive(act.doer) then
			if IsFlying(act.doer) then 
				act.doer.sg:GoToState("idle")
				return false,"FLY"
			end
            act.doer.sg:GoToState("mythhousejump", { myth_teleporter = act.target })
            return true
        end
        act.doer.sg:GoToState("idle")
		if act.doer.components.myth_favorability and act.doer.components.myth_favorability:IsBanned() then
			return false,"BANNED"
		else
			return false,"NOTIME"
		end
    end
end
AddAction(MYTH_ENTER_HOUSE)

AddComponentAction("SCENE", "myth_teleporter" , function(inst, doer, actions, right)
    if inst:HasTag("myth_teleporter") then
		table.insert(actions, ACTIONS.MYTH_ENTER_HOUSE)
    end
end)

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.MYTH_ENTER_HOUSE, "mythhousein_pre"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.MYTH_ENTER_HOUSE, "mythhousein_pre"))

AddStategraphActionHandler("wilsonghost",ActionHandler(ACTIONS.MYTH_ENTER_HOUSE, "mythhousein_pre"))
AddStategraphActionHandler("wilsonghost_client",ActionHandler(ACTIONS.MYTH_ENTER_HOUSE, "mythhousein_pre"))

local L = MK_MOD_LANGUAGE_SETTING
if L == "CHINESE" then
	STRINGS.ACTIONS.MYTH_ENTER_HOUSE = {
		HAUNT = "作祟",
		FANGCUNHILL = "进入",
		MYTH_GHG = "进入",
		MYTH_DOOR_EXIT = "离开",
		MYTH_DOOR_EXIT_1 = "离开",
		MYTH_DOOR_EXIT_2 = "离开",
		MYTH_DOOR_ENTER = "进入",
	}
else
	STRINGS.ACTIONS.MYTH_ENTER_HOUSE = {
		HAUNT = "haunt",
		FANGCUNHILL = "Enter",
		MYTH_GHG = "Enter",
		MYTH_DOOR_EXIT = "Exit",
		MYTH_DOOR_EXIT_1 = "Exit",
		MYTH_DOOR_EXIT_2 = "Exit",
		MYTH_DOOR_ENTER = "Enter",
	}
end
]]--
