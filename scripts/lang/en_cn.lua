GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
-----------------------------------------------------------------糖果屋
STRINGS.RECIPE_DESC["GARDEN_ENTRANCE"]="Build your own house"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARDEN_ENTRANCE="Go to where"
STRINGS.NAMES["GARDEN_ENTRANCE"]="candy house"
STRINGS.NAMES["GARDEN_EXIT"]="candy house"

STRINGS.RECIPE_DESC["GARDEN_ENTRANCE1"]="Build your own house"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARDEN_ENTRANCE1="Go to where"
STRINGS.NAMES["GARDEN_ENTRANCE1"]="candy house"
STRINGS.NAMES["GARDEN_EXIT1"]="candy house"

STRINGS.RECIPE_DESC["CANDY_BALL"]="Keep your food forever"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_BALL="The sweet container"
STRINGS.NAMES["CANDY_BALL"]="crystal box"

STRINGS.RECIPE_DESC["CANDY_TREE"]="Bring lucky tree! \n can prevent spontaneous combustion of surrounding objects."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_TREE="Bring lucky tree!"
STRINGS.NAMES["CANDY_TREE"]="Green mangrove"
STRINGS.NAMES["CANDY_TREE1"]="Green mangrove"

STRINGS.RECIPE_DESC["CANDY_COTTON"]="The fruit that soothes the soul."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_COTTON="The fruit that soothes the soul."
STRINGS.NAMES["CANDY_COTTON"]="Cotton nut"

STRINGS.RECIPE_DESC["CANDY_ENTRANCE"]="Seal the hole and keep away from the bats!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_ENTRANCE="Seal the hole and keep away from the bats!"
STRINGS.NAMES["CANDY_ENTRANCE"]="Rock pile"

STRINGS.RECIPE_DESC["CANDY_LOG"]="Very strong wood."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDY_LOG="Very strong wood."
STRINGS.NAMES["CANDY_LOG"]="Green rosewood"

STRINGS.RECIPE_DESC["CRYSTAL_BALL"]="Bound to the small world."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CRYSTAL_BALL="Bound to the small world."
STRINGS.NAMES["CRYSTAL_BALL"]="Crystal ball"


STRINGS.RECIPE_DESC["ADDLEVEL"]="Increase the size of your candy room"
STRINGS.NAMES["ADDLEVEL"]="upgrade"

local prefablist={
    rooo_turf="The pebble floor",
    wddd_turf="wood floor",
    caaa_turf="Carpet floor",
    gsss_turf="The grass plate",
    brrr_turf="Birch floor"
}
for prefab, name in pairs(prefablist) do
    STRINGS.RECIPE_DESC[prefab:upper()]="Candy floor"
    STRINGS.NAMES[prefab:upper()]=name
end

local turf=require"def/floor_def"
for prefab, v in pairs(turf) do
    STRINGS.RECIPE_DESC[prefab:upper().."_TURF"]="Replace the floor"
    STRINGS.NAMES[prefab:upper().."_TURF"]="floor"
    STRINGS.RECIPE_DESC[prefab:upper().."_BACK"]="Change background"
    STRINGS.NAMES[prefab:upper().."_BACK"]="background"
end

prefablist={
    wall1="stonewalling",
    wall2="stonewalling",
    wall3="Thulium ore wall",
    wall4="Thulium ore wall",
    wall5="Lunar wall",
    wall6="Wooden walls",
}
for prefab, name in pairs(prefablist) do
    STRINGS.RECIPE_DESC[prefab:upper()]="wall"
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
    STRINGS.NAMES[v:upper()]="unknown"
end