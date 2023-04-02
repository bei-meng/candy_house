--[[
    版本号组成： [主版本号].[子版本号].[尾版本号]-<特殊后缀>
大规模改动的版本，主版本号+1，其余版本号清零，如1.3.2 -->2.0.0
每个小范围内改动（添加新物品/新生物或新功能）的版本，子版本号+1，尾版本号清零，如2.1.0-->2.2.0
每个用于修复bug的版本，尾版本号+1。 如2.1.1修复bug 2.1.1 --> 2.1.2。
特殊的发布版本，加特殊后缀。hotfix - 紧急修复bug版本，beta - 内测版 ， dev - 开发版
]]
name="糖果屋/Candy House"--mod的名字
author="北甍"--mod作者
version="1.1.3"--版本号
description=[[
    建造属于你的糖果屋吧！糖果屋可以升级扩大面积。
    里面是永久的白天，不管外面是黑夜还是黄昏。
    糖果屋里面的猪人，蝴蝶，蜜蜂，鸟笼里的鸟不会睡觉和回家
    草，树枝，浆果，桦木树，蜂巢，会一直保持秋天的状态，
    冬天时草树枝，浆果依旧生长，桦木树依旧茂盛，蜜蜂依旧工作。

    糖果屋地面可以直接使用园艺锄挖地来种东西

    你可以制作寄居蟹奶奶的晾肉架和蜂巢，以及蘑菇，胡萝卜，池塘，空心树枝等等
    以及各种生物巢穴和生物，来装饰你的家，甚至制作一个动物园。

    同时，你可以改变糖果屋的地板和围墙装饰。
    在模组页面可以设置糖果屋内部是否增加光辉渲染(童话氛围),
    默认开启，如果你觉得太模糊，可以选择关掉

    降雨和落鸟可以选择开启和关闭
    可以选择糖果屋里面大作物的优待（减少最后的压力值或者直接必定大作物）
    推荐减少压力值6或者8，刚好加上抚摸植物的快乐值和季节加成能变成大作物

    糖果屋里面可以体验到各个年份的背景音乐，
    默认冬季盛宴(最好听的hhh，狗头保命.jpg)
    云雾环绕效果，仅仅在客户端生成云，对服务器无影响
]]
--mod的介绍

forumthread=""--steam模组下载的地址
api_version=10 --这里让其他玩家知道你的mod是否过时了，更新它以匹配游戏中的当前版本。

dst_compatible=true --用于判断是否和饥荒联机版兼容

dont_starve_compatible=false
reign_of_giants_compatible=false --10,11判定是否和饥荒单机兼容
shipwrecked_compatible=false--海滩不可兼容

all_clients_require_mod=true --打开这个mod开服后进入服务器的人必须有本mod(大部分服务器mod都为true)
client_only_mod=false--客机mod

icon_atlas="modicon.xml" --剪裁mod图标图片的文件
icon="modicon.tex" --mod的图标

server_filter_tags={
}--确定你的mod标签，人物，物品，pet宠物

--配置选项
local function AddTitle(title)
	return {
		name = "null",
		label = title,
		options = {
				{ description = "", data = 0 }
		},
		default = 0,
	}
end
configuration_options={
    {
        name="language",--选项标识
        label="语言/language",
        options={
            {description="简体中文",data=true},
            {description="English",data=false},
        },
        default=true
    },
    AddTitle("糖果屋基础设置/Candy house basic Settings"),
    {
        name="large",
        label="大小改变",
        hover="玩家靠近时是否改变大小/Whether to change size as the player approaches",
        options={
            {description="是/yes",data=true},
            {description="否/no",data=false},
        },
        default=true,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
    {
        name="light",
        label="童话氛围/The fairy tale atmosphere",
        hover="糖果屋内部是否增加渲染光辉/Whether the interior of candy house is added to render brilliance",
        options={
            {description="是/yes",data=true},
            {description="否/no",data=false},
        },
        default=true,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
    -- {
    --     name="builder",
    --     label="建筑装饰/decorative architecture",
    --     hover="糖果屋装饰建筑仅在糖果屋内可制作/Candy house decoration buildings can only be made in candy House",
    --     options={
    --         {description="是/yes",data=true},
    --         {description="否/no",data=false},
    --     },
    --     default=true,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    -- },
    {
        name="water",
        label="降雨/the rain",
        hover="关闭和开启糖果屋内部的降雨效果/Turn on and off the rain effect inside the candy house",
        options={
            {description="关闭/off",data=true},
            {description="开启/on",data=false},
        },
        default=true,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
    {
        name="bird",
        label="落鸟/the bird",
        -- hover="关闭和开启糖果屋内部的降雨效果/Turn on and off the rain effect inside the candy house",
        options={
            {description="关闭/off",data=true},
            {description="开启/on",data=false},
        },
        default=true,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
    {
        name="farm",
        label="减少植物压力值/Reduce plant stress levels",
        -- hover="关闭和开启糖果屋内部的降雨效果/Turn on and off the rain effect inside the candy house",
        options={
            {description="100",data=100,hover="必定大作物/Large crops"},
            {description="12",data=12,hover="减少植物最后的压力值12/Reduces the final plant stress by 12"},
            {description="10",data=12},
            {description="8",data=12},
            {description="6",data=12},
        },
        default=100,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
    {--local music={"dontstarve/music/music_FE_WF","dontstarve/music/music_FE_yotg",
    --"dontstarve/music/music_FE_yotc","dontstarve/music/music_FE_summerevent","yotb_2021/music/FE"}
        name="music",
        label="糖果屋内部音乐/House Music",
        hover="更改你的糖果屋音乐/Change your candy house music",
        options={
            {description="无音乐/no music",data=-1},
            {description="冬季盛宴/winter's feast carol",data=1},
            {
                description="随机/random",data=0,
                hover="每次进入都是随机选取一个音乐"
            },
            {description="火鸡-狗-猪/gobbler-varg-pig",data=2},
            {description="鼠年/year of the carrat",data=3},
            {description="鸦年华/crow carnival",data=4},
            {description="牛年/year of the beefalo",data=5},
        },
        default=-1,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
    {--local music={"dontstarve/music/music_FE_WF","dontstarve/music/music_FE_yotg",
    --"dontstarve/music/music_FE_yotc","dontstarve/music/music_FE_summerevent","yotb_2021/music/FE"}
        name="cloud",
        label="云雾环绕/House Cloud",
        hover="云雾环绕/House Cloud",
        options={
            {description="关闭/off",data=false},
            {description="开启/on",data=true},
        },
        default=true,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
    {--local music={"dontstarve/music/music_FE_WF","dontstarve/music/music_FE_yotg",
    --"dontstarve/music/music_FE_yotc","dontstarve/music/music_FE_summerevent","yotb_2021/music/FE"}
        name="hamer",
        label="拆卸/disassembly",
        hover="能否用锤子拆/Can you disassemble it with a hammer",
        options={
            {description="否/NO",data=false},
            {description="是/on",data=true},
        },
        default=false,--选项默认值，在选项面板点击reset，会把该选项的值设置为默认值
    },
}
