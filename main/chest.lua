----棺材的
local params={}
params.candy_chest =
{
    widget =
    {
        slotpos = {},
        animbank = "candy_chest",
        animbuild = "candy_chest",
        pos = Vector3(220, 120, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2, -2, -1 do
    for x = -2, 2 do
        table.insert(params.candy_chest.widget.slotpos, Vector3(80 * x - 10, 80 * y-22, 0))
    end
end

local containers = require "containers"
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local oldwidgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data,...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
		oldwidgetsetup(container, prefab, data,...)
    end
end