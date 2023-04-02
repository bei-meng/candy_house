--[[
    floor_candy:
        brich_road
        brich_grass
        ancient_moon
        board
        brich
        cowhiar
        grass
        --------------back--brich
    floor_candy1:
        shell
        road_grass
        road
        moon
        marble
        grassland
        grass_road
        board_road

]]
return{
    brich={
        build="floor_candy",
        materials={
            turf_deciduous=20   --桦树地皮
        }
    },
    brich_grass={
        build="floor_candy",
        materials={
            turf_grass=10,      --草地皮
            turf_deciduous=10   --桦树地皮
        }
    },
    grass={
        build="floor_candy",
        materials={
            turf_grass=20,      --草地皮
        }
    },
    brich_road={
        build="floor_candy",
        materials={
            turf_road=10,       --卵石路
            turf_deciduous=10   --桦树地皮
        }
    },
    shell={
        build="floor_candy1",
        materials={
            turf_shellbeach=20,      --贝壳地皮
        }
    },
    grass_road={
        build="floor_candy1",
        materials={
            turf_grass=10,      --草地皮
            turf_road=10,       --卵石路
        }
    },
    road_grass={
        build="floor_candy1",
        materials={
            turf_grass=10,      --草地皮
            turf_road=10,       --卵石路
        }
    },
    board_road={
        build="floor_candy1",
        materials={
            turf_road=10,      --卵石路
            turf_woodfloor=10   --木地板
        }
    },
    ancient_moon={
        build="floor_candy",
        materials={
            turf_archive=20,      --远古石刻
        }
    },
    board={
        build="floor_candy",
        materials={
            turf_woodfloor=20,      --木地板
        }
    },
    cowhiar={
        build="floor_candy",
        materials={
            turf_carpetfloor=20,      --地毯地板
        }
    },
    road={
        build="floor_candy1",
        materials={
            turf_road=20,       --卵石路
        }
    },
    moon={
        build="floor_candy1",
        materials={
            turf_meteor=20,      --环形山地皮20
        }
    },
    marble={
        build="floor_candy1",
        materials={
            turf_checkerfloor=20,      --棋盘地板
        }
    },
    grassland={
        build="floor_candy1",
        materials={
            turf_savanna=20,      --热带草原地皮
        }
    },
}