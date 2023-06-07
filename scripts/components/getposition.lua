local Getposition = Class(function(self, inst)
    self.inst = inst;
    self.maxnum=56
    self.num=0
    self.pos_x=-1400
    self.num_old=0
    self.pos_x_old=-1400
    self.delta=200--180
    --房子太大了
end)

function Getposition:GetPosition()
    if self:IsMax() then
        return
    end
    -- print("正值空间没有到最大值")
    local num=self.num%4
    local x=self.pos_x
    if num==0 then
        return math.floor((x)/4)*4+2, 0, math.floor((-1400)/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(x, 0, -1400)
    elseif num==1 then
        return math.floor(1400/4)*4+2, 0, math.floor(x/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(1400, 0, x)
    elseif num==2 then
        return math.floor(-x/4)*4+2, 0, math.floor(1400/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(-x, 0, 1400)
    elseif num==3 then
        return math.floor(-1400/4)*4+2, 0, math.floor(-x/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(-1400, 0, -x)
    end
end

function Getposition:GetPosition_old()
    if self.num_old>=self.maxnum then
        return
    end
    -- print("备用空间没有到最大值")
    local num=self.num_old%4
    self.num_old=self.num_old+1
    local x=self.pos_x_old
    if self.num_old%4==0 then
        self.pos_x_old=self.pos_x_old+self.delta
    end
    if num==0 then
        return math.floor((x)/4)*4+2, 0, math.floor((-1400)/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(x, 0, -1400)
    elseif num==1 then
        return math.floor(1400/4)*4+2, 0, math.floor(x/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(1400, 0, x)
    elseif num==2 then
        return math.floor(-x/4)*4+2, 0, math.floor(1400/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(-x, 0, 1400)
    elseif num==3 then
        return math.floor(-1400/4)*4+2, 0, math.floor(-x/4)*4+2
        -- return TheWorld.Map:GetTileCenterPoint(-1400, 0, -x)
    end
end

function Getposition:IsMax()
    return self.num>=self.maxnum
end

function Getposition:CreateHome()
    self.num=self.num+1
    if self.num%4==0 then
        self.pos_x=self.pos_x+self.delta
    end
end
function Getposition:OnLoad(data)
    if data then
        self.pos_x=data.pos_x
        self.num=data.num
        self.num_old=data.num_old
        self.pos_x_old=data.pos_x_old
    end
end

function Getposition:OnSave()
    return {
        pos_x=self.pos_x,
        num=self.num,
        num_old=self.num_old,
        pos_x_old=self.pos_x_old
    }
end
return Getposition
