GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
-----------------------------------------------------------------糖果屋
STRINGS.RECIPE_DESC["GARDEN_ENTRANCE"]="建造一个属于你的糖果屋"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARDEN_ENTRANCE="前往何处"
STRINGS.NAMES["GARDEN_ENTRANCE"]="糖果屋"
STRINGS.NAMES["GARDEN_EXIT"]="糖果屋"

STRINGS.RECIPE_DESC["ADDLEVEL"]="提升你的糖果屋面积"
STRINGS.NAMES["ADDLEVEL"]="升级"

local prefablist={
    rooo_turf="卵石地板",
    wddd_turf="木地板",
    caaa_turf="地毯地板",
    gsss_turf="草地板",
    brrr_turf="桦树地板"
}
for prefab, name in pairs(prefablist) do
    STRINGS.RECIPE_DESC[prefab:upper()]="糖果屋地面"
    STRINGS.NAMES[prefab:upper()]=name
end
prefablist={
    wall1="石墙",
    wall2="石墙",
    wall3="铥矿墙",
    wall4="铥矿墙",
    wall5="月岩墙",
    wall6="木墙",
}
for prefab, name in pairs(prefablist) do
    STRINGS.RECIPE_DESC[prefab:upper()]="围墙"
    STRINGS.NAMES[prefab:upper()]=name
end

--------------------------------------------------
prefablist={
    "catcoonden","tallbirdnest","slurtlehole","wasphive","beehive","monkeybarrel",
    "pond","cave_banana_tree","meatrack_hermit","beebox_hermit","babybeefalo","lightninggoat",
    "butterfly","marbletree","red_mushroom","green_mushroom","blue_mushroom","carrot_planted",
    "dug_berrybush2","succulent_plant"
}
--CATCOONDEN
for k,v in pairs(prefablist) do
    -- print("名字",STRINGS.CHARACTERS.GENERIC.DESCRIBE[v:upper()].GENERIC)
    if type(STRINGS.CHARACTERS.GENERIC.DESCRIBE[v:upper()])=="table" then
        STRINGS.RECIPE_DESC[v:upper()]=STRINGS.CHARACTERS.GENERIC.DESCRIBE[v:upper()].GENERIC
    else
        STRINGS.RECIPE_DESC[v:upper()]=STRINGS.CHARACTERS.GENERIC.DESCRIBE[v:upper()]
    end

end
------------------------------------------------------------------配方栏