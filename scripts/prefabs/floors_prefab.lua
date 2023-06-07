local turf=require"def/floor_def"
local function make_upgrade(name)
	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst:AddTag("CLASSIFIED")
		--[[Non-networked entity]]
		inst.persists = false
		inst:DoTaskInTime(0, inst.Remove)
		if not TheWorld.ismastersim then
			return inst
		end
	
		inst.OnBuiltFn = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
			local garden = TheSim:FindEntities(x, 0, z, 20, { "garden_part", "garden_tile" })[1]
			if garden ~= nil then
				garden:PushEvent("onupgrade", {source = inst.prefab})
			end
			inst:Remove()
		end
		return inst
	end
	return Prefab(name, fn)
end

local items={"wall1","wall2","wall3","wall4","wall5","wall6","addlevel"}
local upgrades = {}
for _, name in pairs(items) do
	table.insert(upgrades, make_upgrade(name))
end
--地皮
for k,v in pairs(turf) do
	table.insert(upgrades, make_upgrade(k.."_turf"))--地皮
	table.insert(upgrades, make_upgrade(k.."_back"))--背景
end
return unpack(upgrades)