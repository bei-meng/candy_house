GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--GLOBAL 相关照抄
-----------------------------------------------------------------糖果屋
STRINGS.RECIPE_DESC["GARDEN_ENTRANCE"]="Build your own candy house"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARDEN_ENTRANCE="Go to where"
STRINGS.NAMES["GARDEN_ENTRANCE"]="candy house"
STRINGS.NAMES["GARDEN_EXIT"]="candy house"

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