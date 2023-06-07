GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
-----------------------------------------------------------------糖果屋
STRINGS.RECIPE_DESC["GARDEN_ENTRANCE"]="建造一个属于你的世界"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARDEN_ENTRANCE="前往何处"
STRINGS.NAMES["GARDEN_ENTRANCE"]="糖果屋"
STRINGS.NAMES["GARDEN_EXIT"]="出口"

STRINGS.RECIPE_DESC["GARDEN_ENTRANCE1"]="建造一个属于你的世界"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARDEN_ENTRANCE1="前往何处"
STRINGS.NAMES["GARDEN_ENTRANCE1"]="糖果屋"
STRINGS.NAMES["GARDEN_EXIT1"]="出口"

STRINGS.RECIPE_DESC["CANDY_BALL"]="永久保存你的食物"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_BALL="甜蜜的容器"
STRINGS.NAMES["CANDY_BALL"]="水晶盒"

STRINGS.RECIPE_DESC["CANDY_TREE"]="带来幸运的树！\n能防止周围物品自燃。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_TREE="带来幸运的树！"
STRINGS.NAMES["CANDY_TREE"]="青红树"
STRINGS.NAMES["CANDY_TREE1"]="青红树"

STRINGS.RECIPE_DESC["CANDY_COTTON"]="抚慰心灵的果实。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_COTTON="抚慰心灵的果实。"
STRINGS.NAMES["CANDY_COTTON"]="棉花果"


STRINGS.RECIPE_DESC["CANDY_ENTRANCE"]="封住洞口，远离蝙蝠！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_ENTRANCE="封住洞口，远离蝙蝠！"
STRINGS.NAMES["CANDY_ENTRANCE"]="石堆"

STRINGS.RECIPE_DESC["CANDY_LOG"]="非常结实的木头。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_LOG="非常结实的木头。"
STRINGS.NAMES["CANDY_LOG"]="青红木"

STRINGS.RECIPE_DESC["CRYSTAL_BALL"]="与小世界绑定在一起。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CRYSTAL_BALL="与小世界绑定在一起。"
STRINGS.NAMES["CRYSTAL_BALL"]="水晶球"

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

local turf=require"def/floor_def"
for prefab, v in pairs(turf) do
    STRINGS.RECIPE_DESC[prefab:upper().."_TURF"]="更换地板"
    STRINGS.NAMES[prefab:upper().."_TURF"]="地板"
    STRINGS.RECIPE_DESC[prefab:upper().."_BACK"]="更换背景"
    STRINGS.NAMES[prefab:upper().."_BACK"]="背景"
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
--玄学爆破
prefablist={
    "test_build1","tallbirdnest","test_build2","test_build3","test_build4","test_build5","test_build6","test_build7","test_build8",
}
for k,v in pairs(prefablist) do
    STRINGS.NAMES[v:upper()]="未知"
end