local states = {
    State {
        name = "poisoning_paralysis",
        tags = {"busy", "pausepredict"},
        onenter = function(inst)
            -- print("poisoning_paralysis_state-onenter")
            -- ForceStopHeavyLifting(inst)
            if inst.components.inventory:IsHeavyLifting() then
                inst.components.inventory:DropItem(
                    inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
                    true,
                    true
                )
            end
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            -- 这里动画替换为麻痹动画，并播放音效
            inst.AnimState:PlayAnimation("hit_darkness")
    
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
    
            inst.sg:SetTimeout(24 * FRAMES)                                             --强制硬直8秒
        end,
        ontimeout = function(inst) inst.sg:GoToState("idle", true) end,
        -- events =
        -- {
        --     EventHandler("animover", function(inst)
        --         inst.sg:GoToState("idle")
        --     end),
        -- },
    },
    State{
        name = "击退",
        tags = { "busy" },
        onenter = function(inst,data)
            inst.sg:SetTimeout(20 * FRAMES)
            local x, y, z = data.attacker.Transform:GetWorldPosition()
            local distsq = inst:GetDistanceSqToPoint(x, y, z)
            local rangesq = 2.89
            local rot = inst.Transform:GetRotation()
            local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or data.attacker.Transform:GetRotation() + 180
            local drot = math.abs(rot - rot1)
            while drot > 180 do
                drot = math.abs(drot - 360)
            end
            local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
            inst.sg.statemem.speed = (data.strengthmult or 1) * 12 * k *5
            if drot > 90 then
                inst.sg.statemem.reverse = true
                inst.Transform:SetRotation(rot1 + 180)
                inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
            else
                inst.Transform:SetRotation(rot1)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
        end,
        
        timeline = {
            TimeEvent(4 * FRAMES,function(inst)
                inst.sg:GoToState("idle", true)
            end)
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                        inst.sg:GoToState("idle", true)
                end
            end)
        },
    }
}

local TIMEOUT = 2

local states_client = {

}

return {
    states = states,
    states_client = states_client,
}
