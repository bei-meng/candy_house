require("constants")

local function Rectangle(grid, centered, getall, step)
	local _x, _z = grid:match("(%d+)x(%d+)")
    local offset = _x / 2
    local ans={}
	for k=0,_x,2 do
        table.insert(ans,{x=k-offset,z=offset})
        table.insert(ans,{x=k-offset,z=-offset})
        table.insert(ans,{x=offset,z=k-offset})
        table.insert(ans,{x=-offset,z=k-offset})
    end
	return ans
end
local CloudPuffManager = Class(function(self, inst)
	self.inst = inst
	self.cloudpuff_spawn_rate = 0
    self.area={
        a1={},
        a2={},
        a3={},
        a4={},
        a5={},
        a6={},
        a7={},
        a8={}
    }
    self:ChangeArea()
	self.inst:StartUpdatingComponent(self)
end)
function CloudPuffManager:spawncloud()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    for i=1,4 do
        self.inst:DoTaskInTime(0.1*i,function (inst)
            local lev="a"..i;
            if self.area[lev]==nil then
                return;
            end
            for _,k in pairs(self.area[lev])do
                local cloudpuff = SpawnPrefab( "cloudpuff" )
                cloudpuff.Transform:SetPosition( x+math.random()*2+k.x, y, z+math.random()*2+k.z )
            end
        end)
    end
end
function CloudPuffManager:ChangeArea()
    local level=self.inst.level_bm:value()
    local str
    for i=1,5 do
        str=tostring((level)*4+2*i-2).."x"..tostring((level)*4+2*i-2)
        self.area["a"..i]=Rectangle(str, true)
    end
end

function CloudPuffManager:OnUpdate(dt)
	local map = TheWorld.Map
	if map == nil then
		return
	end
	self.cloudpuff_spawn_rate = self.cloudpuff_spawn_rate + dt
	while self.cloudpuff_spawn_rate >0 do
        if next(self.area.a1) then
            local x, y, z = self.inst.Transform:GetWorldPosition()
            for i=1,5 do
                local xoffset=-0.125---.5--k.x<0 and -0.5 or 0.5
                local zoffset=-0.125---.5--k.z<0 and -0.5 or 0.5
                x=x+xoffset
                z=z+zoffset
                self.inst:DoTaskInTime(0.1*i,function (inst)
                    local lev="a"..i;
                    if self.area[lev]==nil then
                        return;
                    end
                    for _,k in pairs(self.area[lev])do
                        local cloudpuff = SpawnPrefab( "cloudpuff" )
                        local offset_x=0--(k.x<0 and -0.5 or 0.5)*(i-1)
                        local offset_z=0--(k.z<0 and -0.5 or 0.5)*(i-1)
                        cloudpuff.Transform:SetPosition( x+math.random()+k.x+offset_x, y, z+math.random()+k.z+offset_z )
                    end
                end)
            end
            self.cloudpuff_spawn_rate = self.cloudpuff_spawn_rate - 4
        else
            self:ChangeArea()
        end
	end
end

return CloudPuffManager
