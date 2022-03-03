local S, L, O, U, D, E = unpack(select(2, ...));
local Data = S:NewModule('Core_Data');

local TEEMING_AFFIX_ID = 5;

D.Player = {
    Name            = UnitName('player'),
    Realm           = GetRealmName(),
    RealmNormalized = GetNormalizedRealmName() or GetRealmName():gsub('[%s%-]', ''),

    Class           = UnitClassBase('player'),
    ClassId         = select(2, UnitClassBase('player')),
    ClassColor      = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[UnitClassBase('player')] or CreateColor(1, 1, 1),

    GuildName = '';
};

D.Player.NameWithRealm = D.Player.Name .. '-' .. D.Player.RealmNormalized;

D.MaxLevel = GetMaxLevelForLatestExpansion();

D.Player.State = {
    inCombat            = false,
    inInstance          = false,
    inMythic            = false,
    inMythicPlus        = false,
    inMythicPlusTeeming = false,
    inArena             = false,
    inPvPInstance       = false,
    inBossFight         = false,
    inRaid              = false,
};

D.MythicPlusPercentage = {
    [171343] = { count = 5,  normal = 384, teeming = 1000 },
    [168992] = { count = 4,  normal = 384, teeming = 1000 },
    [169905] = { count = 6,  normal = 384, teeming = 1000 },
    [168986] = { count = 3,  normal = 384, teeming = 1000 },
    [168942] = { count = 6,  normal = 384, teeming = 1000 },
    [168934] = { count = 8,  normal = 384, teeming = 1000 },
    [167962] = { count = 8,  normal = 384, teeming = 1000 },
    [170147] = { count = 0,  normal = 384, teeming = 1000 },
    [167964] = { count = 8,  normal = 384, teeming = 1000 },
    [167967] = { count = 6,  normal = 384, teeming = 1000 },
    [164555] = { count = 0,  normal = 384, teeming = 1000 },
    [170490] = { count = 5,  normal = 384, teeming = 1000 },
    [164862] = { count = 3,  normal = 384, teeming = 1000 },
    [164861] = { count = 2,  normal = 384, teeming = 1000 },
    [171184] = { count = 12, normal = 384, teeming = 1000 },
    [179892] = { count = 0,  normal = 384, teeming = 1000 },
    [179891] = { count = 0,  normal = 384, teeming = 1000 },
    [171333] = { count = 2,  normal = 384, teeming = 1000 },
    [164857] = { count = 2,  normal = 384, teeming = 1000 },
    [171341] = { count = 1,  normal = 384, teeming = 1000 },
    [164450] = { count = 0,  normal = 384, teeming = 1000 },
    [179890] = { count = 0,  normal = 384, teeming = 1000 },
    [167963] = { count = 5,  normal = 384, teeming = 1000 },
    [167965] = { count = 5,  normal = 384, teeming = 1000 },
    [164556] = { count = 0,  normal = 384, teeming = 1000 },
    [170572] = { count = 6,  normal = 384, teeming = 1000 },
    [170480] = { count = 5,  normal = 384, teeming = 1000 },
    [171342] = { count = 2,  normal = 384, teeming = 1000 },
    [171181] = { count = 4,  normal = 384, teeming = 1000 },
    [166608] = { count = 0,  normal = 384, teeming = 1000 },
    [185685] = { count = 0,  normal = 384, teeming = 1000 },
    [185680] = { count = 0,  normal = 384, teeming = 1000 },
    [179446] = { count = 0,  normal = 384, teeming = 1000 },
    [168949] = { count = 4,  normal = 384, teeming = 1000 },
    [164558] = { count = 0,  normal = 384, teeming = 1000 },
    [164873] = { count = 4,  normal = 384, teeming = 1000 },
    [185683] = { count = 0,  normal = 384, teeming = 1000 },
    [165515] = { count = 4,  normal = 273, teeming = 1000 },
    [164562] = { count = 4,  normal = 273, teeming = 1000 },
    [165414] = { count = 4,  normal = 273, teeming = 1000 },
    [164557] = { count = 10, normal = 273, teeming = 1000 },
    [167892] = { count = 0,  normal = 273, teeming = 1000 },
    [167876] = { count = 20, normal = 273, teeming = 1000 },
    [165408] = { count = 0,  normal = 273, teeming = 1000 },
    [164218] = { count = 0,  normal = 273, teeming = 1000 },
    [174175] = { count = 4,  normal = 273, teeming = 1000 },
    [167612] = { count = 6,  normal = 273, teeming = 1000 },
    [167610] = { count = 1,  normal = 273, teeming = 1000 },
    [164563] = { count = 4,  normal = 273, teeming = 1000 },
    [165415] = { count = 2,  normal = 273, teeming = 1000 },
    [167611] = { count = 4,  normal = 273, teeming = 1000 },
    [167607] = { count = 7,  normal = 273, teeming = 1000 },
    [165529] = { count = 4,  normal = 273, teeming = 1000 },
    [164185] = { count = 0,  normal = 273, teeming = 1000 },
    [165410] = { count = 0,  normal = 273, teeming = 1000 },
    [165111] = { count = 2,  normal = 260, teeming = 1000 },
    [164929] = { count = 7,  normal = 260, teeming = 1000 },
    [164921] = { count = 4,  normal = 260, teeming = 1000 },
    [163058] = { count = 4,  normal = 260, teeming = 1000 },
    [167111] = { count = 5,  normal = 260, teeming = 1000 },
    [167113] = { count = 4,  normal = 260, teeming = 1000 },
    [166301] = { count = 4,  normal = 260, teeming = 1000 },
    [172312] = { count = 4,  normal = 260, teeming = 1000 },
    [164926] = { count = 6,  normal = 260, teeming = 1000 },
    [166304] = { count = 4,  normal = 260, teeming = 1000 },
    [167116] = { count = 4,  normal = 260, teeming = 1000 },
    [164517] = { count = 0,  normal = 260, teeming = 1000 },
    [166276] = { count = 4,  normal = 260, teeming = 1000 },
    [173720] = { count = 16, normal = 260, teeming = 1000 },
    [164920] = { count = 4,  normal = 260, teeming = 1000 },
    [164567] = { count = 0,  normal = 260, teeming = 1000 },
    [166299] = { count = 4,  normal = 260, teeming = 1000 },
    [173655] = { count = 16, normal = 260, teeming = 1000 },
    [167117] = { count = 1,  normal = 260, teeming = 1000 },
    [166275] = { count = 4,  normal = 260, teeming = 1000 },
    [164804] = { count = 0,  normal = 260, teeming = 1000 },
    [173714] = { count = 16, normal = 260, teeming = 1000 },
    [164501] = { count = 0,  normal = 260, teeming = 1000 },
    [164967] = { count = 0,  normal = 600, teeming = 1000 },
    [168365] = { count = 0,  normal = 600, teeming = 1000 },
    [169696] = { count = 8,  normal = 600, teeming = 1000 },
    [168969] = { count = 1,  normal = 600, teeming = 1000 },
    [168155] = { count = 0,  normal = 600, teeming = 1000 },
    [168153] = { count = 12, normal = 600, teeming = 1000 },
    [163882] = { count = 14, normal = 600, teeming = 1000 },
    [168572] = { count = 8,  normal = 600, teeming = 1000 },
    [168580] = { count = 8,  normal = 600, teeming = 1000 },
    [163915] = { count = 10, normal = 600, teeming = 1000 },
    [171474] = { count = 0,  normal = 600, teeming = 1000 },
    [164255] = { count = 0,  normal = 600, teeming = 1000 },
    [163894] = { count = 12, normal = 600, teeming = 1000 },
    [164707] = { count = 6,  normal = 600, teeming = 1000 },
    [163862] = { count = 8,  normal = 600, teeming = 1000 },
    [164266] = { count = 0,  normal = 600, teeming = 1000 },
    [163857] = { count = 4,  normal = 600, teeming = 1000 },
    [169159] = { count = 0,  normal = 600, teeming = 1000 },
    [168627] = { count = 8,  normal = 600, teeming = 1000 },
    [168022] = { count = 10, normal = 600, teeming = 1000 },
    [167493] = { count = 8,  normal = 600, teeming = 1000 },
    [169861] = { count = 25, normal = 600, teeming = 1000 },
    [168578] = { count = 8,  normal = 600, teeming = 1000 },
    [168361] = { count = 8,  normal = 600, teeming = 1000 },
    [168574] = { count = 8,  normal = 600, teeming = 1000 },
    [168396] = { count = 12, normal = 600, teeming = 1000 },
    [163892] = { count = 6,  normal = 600, teeming = 1000 },
    [164705] = { count = 6,  normal = 600, teeming = 1000 },
    [168886] = { count = 25, normal = 600, teeming = 1000 },
    [168747] = { count = 0,  normal = 600, teeming = 1000 },
    [168907] = { count = 10, normal = 600, teeming = 1000 },
    [164737] = { count = 12, normal = 600, teeming = 1000 },
    [164267] = { count = 0,  normal = 600, teeming = 1000 },
    [168968] = { count = 0,  normal = 600, teeming = 1000 },
    [168878] = { count = 8,  normal = 600, teeming = 1000 },
    [163891] = { count = 6,  normal = 600, teeming = 1000 },
    [162046] = { count = 1,  normal = 364, teeming = 1000 },
    [166396] = { count = 4,  normal = 364, teeming = 1000 },
    [165076] = { count = 4,  normal = 364, teeming = 1000 },
    [171448] = { count = 4,  normal = 364, teeming = 1000 },
    [162038] = { count = 7,  normal = 364, teeming = 1000 },
    [162047] = { count = 7,  normal = 364, teeming = 1000 },
    [162100] = { count = 0,  normal = 364, teeming = 1000 },
    [162056] = { count = 1,  normal = 364, teeming = 1000 },
    [162057] = { count = 7,  normal = 364, teeming = 1000 },
    [168591] = { count = 4,  normal = 364, teeming = 1000 },
    [171384] = { count = 4,  normal = 364, teeming = 1000 },
    [162049] = { count = 4,  normal = 364, teeming = 1000 },
    [171455] = { count = 1,  normal = 364, teeming = 1000 },
    [171799] = { count = 7,  normal = 364, teeming = 1000 },
    [162051] = { count = 2,  normal = 364, teeming = 1000 },
    [162099] = { count = 0,  normal = 364, teeming = 1000 },
    [162039] = { count = 4,  normal = 364, teeming = 1000 },
    [167956] = { count = 1,  normal = 364, teeming = 1000 },
    [162040] = { count = 7,  normal = 364, teeming = 1000 },
    [171376] = { count = 10, normal = 364, teeming = 1000 },
    [168058] = { count = 1,  normal = 364, teeming = 1000 },
    [162103] = { count = 0,  normal = 364, teeming = 1000 },
    [167955] = { count = 1,  normal = 364, teeming = 1000 },
    [162041] = { count = 2,  normal = 364, teeming = 1000 },
    [172265] = { count = 4,  normal = 364, teeming = 1000 },
    [162102] = { count = 0,  normal = 364, teeming = 1000 },
    [168594] = { count = 7,  normal = 364, teeming = 1000 },
    [171805] = { count = 4,  normal = 364, teeming = 1000 },
    [163459] = { count = 4,  normal = 285, teeming = 1000 },
    [163457] = { count = 4,  normal = 285, teeming = 1000 },
    [163458] = { count = 4,  normal = 285, teeming = 1000 },
    [163501] = { count = 4,  normal = 285, teeming = 1000 },
    [168718] = { count = 4,  normal = 285, teeming = 1000 },
    [168717] = { count = 4,  normal = 285, teeming = 1000 },
    [168420] = { count = 4,  normal = 285, teeming = 1000 },
    [166411] = { count = 1,  normal = 285, teeming = 1000 },
    [163077] = { count = 0,  normal = 285, teeming = 1000 },
    [163520] = { count = 6,  normal = 285, teeming = 1000 },
    [168843] = { count = 12, normal = 285, teeming = 1000 },
    [168844] = { count = 12, normal = 285, teeming = 1000 },
    [163506] = { count = 4,  normal = 285, teeming = 1000 },
    [168845] = { count = 12, normal = 285, teeming = 1000 },
    [168318] = { count = 8,  normal = 285, teeming = 1000 },
    [162059] = { count = 0,  normal = 285, teeming = 1000 },
    [163524] = { count = 5,  normal = 285, teeming = 1000 },
    [162060] = { count = 0,  normal = 285, teeming = 1000 },
    [168418] = { count = 4,  normal = 285, teeming = 1000 },
    [163503] = { count = 2,  normal = 285, teeming = 1000 },
    [162058] = { count = 0,  normal = 285, teeming = 1000 },
    [162061] = { count = 0,  normal = 285, teeming = 1000 },
    [168681] = { count = 6,  normal = 285, teeming = 1000 },
    [163622] = { count = 0,  normal = 283, teeming = 1000 },
    [165138] = { count = 1,  normal = 283, teeming = 1000 },
    [166302] = { count = 4,  normal = 283, teeming = 1000 },
    [163121] = { count = 5,  normal = 283, teeming = 1000 },
    [165137] = { count = 6,  normal = 283, teeming = 1000 },
    [165872] = { count = 4,  normal = 283, teeming = 1000 },
    [162691] = { count = 0,  normal = 283, teeming = 1000 },
    [163128] = { count = 4,  normal = 283, teeming = 1000 },
    [163618] = { count = 8,  normal = 283, teeming = 1000 },
    [163122] = { count = 0,  normal = 283, teeming = 1000 },
    [165222] = { count = 4,  normal = 283, teeming = 1000 },
    [165197] = { count = 12, normal = 283, teeming = 1000 },
    [173016] = { count = 4,  normal = 283, teeming = 1000 },
    [167731] = { count = 4,  normal = 283, teeming = 1000 },
    [163623] = { count = 0,  normal = 283, teeming = 1000 },
    [162693] = { count = 0,  normal = 283, teeming = 1000 },
    [166079] = { count = 0,  normal = 283, teeming = 1000 },
    [172981] = { count = 5,  normal = 283, teeming = 1000 },
    [173044] = { count = 4,  normal = 283, teeming = 1000 },
    [163620] = { count = 6,  normal = 283, teeming = 1000 },
    [163619] = { count = 4,  normal = 283, teeming = 1000 },
    [163126] = { count = 0,  normal = 283, teeming = 1000 },
    [165919] = { count = 6,  normal = 283, teeming = 1000 },
    [165824] = { count = 15, normal = 283, teeming = 1000 },
    [171500] = { count = 1,  normal = 283, teeming = 1000 },
    [166264] = { count = 0,  normal = 283, teeming = 1000 },
    [163621] = { count = 6,  normal = 283, teeming = 1000 },
    [164578] = { count = 0,  normal = 283, teeming = 1000 },
    [162689] = { count = 0,  normal = 283, teeming = 1000 },
    [162729] = { count = 4,  normal = 283, teeming = 1000 },
    [163157] = { count = 0,  normal = 283, teeming = 1000 },
    [165911] = { count = 4,  normal = 283, teeming = 1000 },
    [162317] = { count = 0,  normal = 271, teeming = 1000 },
    [170838] = { count = 4,  normal = 271, teeming = 1000 },
    [170850] = { count = 7,  normal = 271, teeming = 1000 },
    [164451] = { count = 0,  normal = 271, teeming = 1000 },
    [164463] = { count = 0,  normal = 271, teeming = 1000 },
    [164461] = { count = 0,  normal = 271, teeming = 1000 },
    [164464] = { count = 0,  normal = 271, teeming = 1000 },
    [164510] = { count = 4,  normal = 271, teeming = 1000 },
    [167538] = { count = 20, normal = 271, teeming = 1000 },
    [164506] = { count = 5,  normal = 271, teeming = 1000 },
    [162329] = { count = 0,  normal = 271, teeming = 1000 },
    [167998] = { count = 8,  normal = 271, teeming = 1000 },
    [169893] = { count = 6,  normal = 271, teeming = 1000 },
    [170690] = { count = 4,  normal = 271, teeming = 1000 },
    [165946] = { count = 0,  normal = 271, teeming = 1000 },
    [170882] = { count = 4,  normal = 271, teeming = 1000 },
    [162309] = { count = 0,  normal = 271, teeming = 1000 },
    [169927] = { count = 5,  normal = 271, teeming = 1000 },
    [162744] = { count = 20, normal = 271, teeming = 1000 },
    [167994] = { count = 4,  normal = 271, teeming = 1000 },
    [167536] = { count = 20, normal = 271, teeming = 1000 },
    [167533] = { count = 20, normal = 271, teeming = 1000 },
    [169875] = { count = 2,  normal = 271, teeming = 1000 },
    [160495] = { count = 4,  normal = 271, teeming = 1000 },
    [174210] = { count = 4,  normal = 271, teeming = 1000 },
    [163086] = { count = 8,  normal = 271, teeming = 1000 },
    [167532] = { count = 20, normal = 271, teeming = 1000 },
    [174197] = { count = 4,  normal = 271, teeming = 1000 },
    [162763] = { count = 8,  normal = 271, teeming = 1000 },
    [163089] = { count = 1,  normal = 271, teeming = 1000 },
    [167534] = { count = 20, normal = 271, teeming = 1000 },
    [176705] = { count = 0,  normal = 330, teeming = 1000 },
    [178392] = { count = 10, normal = 330, teeming = 1000 },
    [177817] = { count = 4,  normal = 330, teeming = 1000 },
    [177816] = { count = 4,  normal = 330, teeming = 1000 },
    [177808] = { count = 8,  normal = 330, teeming = 1000 },
    [179334] = { count = 16, normal = 330, teeming = 1000 },
    [175616] = { count = 0,  normal = 330, teeming = 1000 },
    [179837] = { count = 20, normal = 330, teeming = 1000 },
    [180495] = { count = 10, normal = 330, teeming = 1000 },
    [179840] = { count = 4,  normal = 330, teeming = 1000 },
    [179842] = { count = 8,  normal = 330, teeming = 1000 },
    [180348] = { count = 8,  normal = 330, teeming = 1000 },
    [179269] = { count = 0,  normal = 330, teeming = 1000 },
    [176563] = { count = 0,  normal = 330, teeming = 1000 },
    [176396] = { count = 2,  normal = 330, teeming = 1000 },
    [175806] = { count = 0,  normal = 330, teeming = 1000 },
    [180335] = { count = 4,  normal = 330, teeming = 1000 },
    [176565] = { count = 0,  normal = 330, teeming = 1000 },
    [176556] = { count = 0,  normal = 330, teeming = 1000 },
    [176394] = { count = 4,  normal = 330, teeming = 1000 },
    [180091] = { count = 12, normal = 330, teeming = 1000 },
    [180567] = { count = 4,  normal = 330, teeming = 1000 },
    [179841] = { count = 4,  normal = 330, teeming = 1000 },
    [179821] = { count = 20, normal = 330, teeming = 1000 },
    [180336] = { count = 4,  normal = 330, teeming = 1000 },
    [180159] = { count = 0,  normal = 330, teeming = 1000 },
    [176555] = { count = 0,  normal = 330, teeming = 1000 },
    [176395] = { count = 4,  normal = 330, teeming = 1000 },
    [177807] = { count = 4,  normal = 330, teeming = 1000 },
    [179893] = { count = 4,  normal = 330, teeming = 1000 },
    [176562] = { count = 0,  normal = 330, teeming = 1000 },
    [175646] = { count = 0,  normal = 330, teeming = 1000 },
    [178163] = { count = 1,  normal = 332, teeming = 1000 },
    [178139] = { count = 6,  normal = 332, teeming = 1000 },
    [178165] = { count = 15, normal = 332, teeming = 1000 },
    [175663] = { count = 0,  normal = 332, teeming = 1000 },
    [180431] = { count = 5,  normal = 332, teeming = 1000 },
    [177269] = { count = 0,  normal = 332, teeming = 1000 },
    [180015] = { count = 5,  normal = 332, teeming = 1000 },
    [178133] = { count = 3,  normal = 332, teeming = 1000 },
    [179388] = { count = 5,  normal = 332, teeming = 1000 },
    [179399] = { count = 0,  normal = 332, teeming = 1000 },
    [178142] = { count = 3,  normal = 332, teeming = 1000 },
    [178141] = { count = 3,  normal = 332, teeming = 1000 },
    [179386] = { count = 5,  normal = 332, teeming = 1000 },
    [175546] = { count = 0,  normal = 332, teeming = 1000 },
    [178171] = { count = 10, normal = 332, teeming = 1000 },
    [180429] = { count = 10, normal = 332, teeming = 1000 },
    [180432] = { count = 5,  normal = 332, teeming = 1000 },
};

D.ModelBlacklist = {
    [120651] = true,
    [179733] = true,
    [185683] = true,
    [185680] = true,
    [185685] = true,
};

D.NPCs = {
    -- Common
    [1] = {
        120651, 174773, 173729,
        179446, 179892, 179891, 179890,                 -- SL Season 2 Affix
        185683, 185680, 185685, 184911, 184910, 184908, -- SL Season 3 Affix
    },

    -- Mists of Tirna Scithe
    [2] = {
        164567, 164804, 164501, 164517, 165111, 164929, 164921, 163058, 167111, 167113, 166301, 172312, 164926,
        166304, 167116, 166276, 173720, 164920, 166299, 173655, 166275, 173714, 167117,
    },

    -- The Necrotic Wake
    [3] = {
        162691, 163157, 162689, 162693, 162729, 165138, 163121, 163128, 165197, 166079, 163619, 171500, 165137,
        163618, 173016, 164578, 172981, 163126, 166264, 166302, 165872, 163122, 167731, 173044, 165919, 163621,
        163622, 165222, 163623, 165911, 163620, 165824,
    },

    -- De Other Side
    [4] = {
        164558, 164556, 164555, 164450, 166608, 168949, 168992, 168986, 170147, 170490, 171333, 167963, 170480,
        168942, 167964, 164862, 164857, 167965, 171342, 169905, 168934, 167967, 164861, 171341, 171181, 171343,
        167962, 171184, 164873, 170572,
    },

    -- Halls of Atonement
    [5] = {
        165408, 164185, 165410, 164218, 165515, 164562, 165414, 164557, 167892, 167876, 174175, 167612, 167610,
        164563, 165415, 167611, 167607, 165529,
    },

    -- Plaguefall
    [6] = {
        164255, 164967, 164266, 164267, 168365, 169696, 168969, 168155, 168153, 163882, 168572, 168580, 163915,
        171474, 163894, 164707, 163862, 163857, 169159, 168627, 168022, 167493, 169861, 168578, 168361, 168574,
        168396, 163892, 164705, 168886, 168747, 168907, 168968, 168878, 168891, 163891, 164737,
    },

    -- Sanguine Depths
    [7] = {
        162100, 162103, 162102, 162099, 162041, 162046, 165076, 171384, 171799, 162039, 168058, 171448, 162056,
        162049, 162051, 167956, 166396, 162038, 162057, 171455, 162040, 167955, 162047, 168591, 171376, 172265,
    },

    -- Spires of Ascension
    [8] = {
        162059, 163077, 162058, 162060, 162061, 163459, 163457, 163458, 163501, 168718, 168717, 168420, 166411,
        163520, 168843, 168844, 163506, 168845, 168318, 163524, 168418, 163503, 168681,
    },

    -- Theater of Pain
    [9] = {
        164464, 164451, 164463, 164461, 162317, 162329, 162309, 165946, 174197, 170838, 164510, 167998, 170882,
        167994, 160495, 167534, 167538, 169893, 167532, 167536, 174210, 170850, 164506, 170690, 162763, 169927,
        167533, 163086, 163089, 162744, 169875,
    },

    -- Tazavesh, the Veiled Market
    [10] = {
        176556, 175663, 175646, 175806, 178433, 175546, 176564, 175616,
        176555, 180153, 177808, 178388, 176562, 180015, 178394, 179893, 177237, 179821, 179842, 177255, 177500,
        178435, 179386, 177807, 176396, 176565, 180114, 179388, 177816, 177817, 178392, 176384, 179840, 180117,
        178142, 178141, 178139, 178163, 178133, 176395, 176394, 175677, 179269, 178171, 179733, 179795, 177672,
        175799, 176551, 176705, 179841, 177999, 176563, 180335, 178392, 179837, 180091, 180495, 180567,
    },

    -- Castle Nathria
    [11] = {
        164406, 165066, 169457, 171557, 165067, 169458, 165805,  24664, 166644, 164261, 165521, 166971, 166969,
        166970, 164407, 168112, 168113, 167406, 168156, 174733, 166644, 173430, 175992, 173464, 169196, 169924,
        168973, 172803, 169157, 168962, 169601, 174335, 167999, 172858, 174134, 165762, 173484, 174126, 169925,
        174161, 174162, 170199, 173798, 174843, 176026, 173448, 173466, 171146, 174626, 165763, 170197, 173178,
        173053, 165483, 173604, 165474, 173445, 167566, 165481, 174208, 174194, 174012, 173953, 168337, 174090,
        173973, 174842, 174069, 173633, 174100, 165764, 165479, 165469, 167691, 173276, 173142, 173145, 173469,
        174093, 168700, 173802, 171145, 173298, 171801, 165472, 174071, 173146, 173444, 173190, 174070, 173189,
        173446, 174336, 165471, 165470, 173641, 173613, 173949, 173280, 173609, 174092, 173568, 172899,
    },

    -- Sanctum of Domination
    [12] = {
        180018, 179390, 175731,  15990, 178738, 176523, 175729, 176974, 175727, 152253, 179687,
        178523, 178731, 178629, 179124, 176531, 179894, 179942, 175730, 179010, 176703, 175861, 176535, 176537,
        176538, 176539, 175559, 178626, 177594, 178625, 178631, 178628, 178623, 179177, 178630, 176959, 178071,
        177117, 176929, 179847, 176956, 176957, 177094, 178736, 175726, 176605, 176880, 176581, 178904, 178041,
        178029, 175611, 177004, 176973, 177512, 178043, 178903,
    },

    -- Sepulcher of the First Ones
    [13] = {
        181954, 183501, 181224, 184915, 182169, 181398, 181549, 182777, 183937, 185421, 180773, 182074, 184737,
        184623, 184603, 181011, 183398, 184954, 184520, 184494, 184493, 183928, 183992, 184539, 185181, 183416,
        183438, 182778, 183406, 185884, 184126, 182053, 184735, 184880, 183413, 185346, 185347, 184733, 183412,
        185319, 185574, 184659, 184742, 181244, 183429, 183432, 183870, 183407, 183404, 185582, 183396, 185581,
        184530, 183669, 184589, 183497, 185537, 183496, 183533, 184962, 184961, 182071, 184738, 180906, 184601,
        183499, 183498, 184791, 181334, 184613, 183664, 184597, 185607, 185363, 183439, 182045, 183409, 181856,
        181850, 182311, 183745, 181548, 181551, 181546, 183463, 184734, 169501, 181395, 183688, 184651, 183666,
        184605, 185032, 183500, 184599, 183495, 185610, 183973, 182102, 183347, 185402, 183665, 185145, 184522,
        181859, 185008, 182822, 184140, 183707,
    },
};

D.KickByClassId = {
    -- [classId] = { [specIndex], ... }
    [1]  = { [1] = 6552,   [2] = 6552,   [3] = 6552 },              -- Warrior
    [2]  = { [1] = nil,    [2] = 96231,  [3] = 96231 },             -- Paladin
    [3]  = { [1] = 147362, [2] = 147362, [3] = 187707 },            -- Hunter
    [4]  = { [1] = 1766,   [2] = 1766,   [3] = 1766 },              -- Rogue
    [5]  = { [1] = nil,    [2] = nil,    [3] = 15487 },             -- Priest
    [6]  = { [1] = 47528,  [2] = 47528,  [3] = 47528 },             -- Death Knight
    [7]  = { [1] = 57994,  [2] = 57994,  [3] = 57994 },             -- Shaman
    [8]  = { [1] = 2139,   [2] = 2139,   [3] = 2139 },              -- Mage
    [10] = { [1] = 116705, [2] = nil,    [3] = 116705 },            -- Monk
    [11] = { [1] = 78675,  [2] = 106839, [3] = 106839, [4] = nil }, -- Druid
    [12] = { [1] = 183752, [2] = 183752 },                          -- Demon Hunter
};

local function UpdateSpecialization()
    D.Player.SpecIndex = GetSpecialization() or 0;
    D.Player.SpecId    = GetSpecializationInfo(D.Player.SpecIndex) or 0;
    D.Player.SpecRole  = GetSpecializationRole(D.Player.SpecIndex) or 'NONE';
end

local function UpdatePlayer()
    D.Player.Name, D.Player.RealmNormalized = UnitFullName('player');
    D.Player.NameWithRealm                  = D.Player.Name .. '-' .. D.Player.RealmNormalized;
    D.Player.Realm                          = GetRealmName();

    UpdateSpecialization();
end

function Data:PLAYER_LOGIN()
    UpdatePlayer();

    D.MaxLevel = GetMaxLevelForLatestExpansion();
end

local raidDifficultyIDs = {
    [1]  = true, -- PrimaryRaidNormal
    [3]  = true, -- Raid10Normal
    [4]  = true, -- Raid25Normal
    [5]  = true, -- Raid10Heroic
    [6]  = true, -- Raid25Heroic
    [7]  = true, -- RaidLFR
    [9]  = true, -- Raid40
    [15] = true, -- PrimaryRaidHeroic
    [16] = true, -- PrimaryRaidMythic
    [17] = true, -- PrimaryRaidLFR
    [33] = true, -- RaidTimewalker
};

function Data:PLAYER_ENTERING_WORLD()
    UpdatePlayer();

    D.MaxLevel = GetMaxLevelForLatestExpansion();

    if U.IsInInstance() then
        D.Player.State.inInstance = true;

        local instanceType, difficulty = select(2, GetInstanceInfo());

        if difficulty == DifficultyUtil.ID.DungeonMythic then
            D.Player.State.inChallenge = true;
            D.Player.State.inMythic    = true;
        end

        if difficulty == DifficultyUtil.ID.DungeonChallenge then
            D.Player.State.inChallenge         = true;
            D.Player.State.inMythicPlus        = true;
            D.Player.State.inMythicPlusTeeming = U.IsAffixCurrent(TEEMING_AFFIX_ID);
        end

        if raidDifficultyIDs[difficulty] then
            D.Player.State.inRaid = true;
        end

        D.Player.State.inPvPInstance = (instanceType == 'pvp' or instanceType == 'arena') and true or false;
    else
        D.Player.State.inInstance          = false;
        D.Player.State.inChallenge         = false;
        D.Player.State.inMythic            = false;
        D.Player.State.inMythicPlus        = false;
        D.Player.State.inMythicPlusTeeming = false;
        D.Player.State.inPvPInstance       = false;
        D.Player.State.inRaid              = false;
    end

    D.Player.State.inArena = U.IsInArena();
end

function Data:CHALLENGE_MODE_START()
    D.Player.State.inChallenge         = true;
    D.Player.State.inMythic            = true;
    D.Player.State.inMythicPlus        = true;
    D.Player.State.inMythicPlusTeeming = U.IsAffixCurrent(TEEMING_AFFIX_ID);
end

function Data:CHALLENGE_MODE_COMPLETED()
    D.Player.State.inChallenge         = true;
    D.Player.State.inMythic            = true;
    D.Player.State.inMythicPlus        = false;
    D.Player.State.inMythicPlusTeeming = false;
end

function Data:CHALLENGE_MODE_RESET()
    D.Player.State.inMythicPlus        = false;
    D.Player.State.inMythicPlusTeeming = false;
end

function Data:PLAYER_REGEN_ENABLED()
    D.Player.State.inCombat = false;
end

function Data:PLAYER_REGEN_DISABLED()
    D.Player.State.inCombat = true;
end

function Data:ENCOUNTER_START()
    D.Player.State.inBossFight = true;
end

function Data:ENCOUNTER_END()
    D.Player.State.inBossFight = false;
end

function Data:GUILD_ROSTER_UPDATE()
    D.Player.GuildName = U.PlayerInGuild();
end

function Data:PLAYER_GUILD_UPDATE()
    D.Player.GuildName = U.PlayerInGuild();
end

function Data:MAX_EXPANSION_LEVEL_UPDATED()
    D.MaxLevel = GetMaxLevelForLatestExpansion();
end

function Data:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= 'player' then
        return;
    end

    UpdateSpecialization();
end

function Data:StartUp()
    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_ENTERING_WORLD');
    self:RegisterEvent('CHALLENGE_MODE_START');
    self:RegisterEvent('CHALLENGE_MODE_COMPLETED');
    self:RegisterEvent('CHALLENGE_MODE_RESET');
    self:RegisterEvent('ENCOUNTER_START');
    self:RegisterEvent('ENCOUNTER_END');
    self:RegisterEvent('PLAYER_REGEN_ENABLED');
    self:RegisterEvent('PLAYER_REGEN_DISABLED');
    self:RegisterEvent('GUILD_ROSTER_UPDATE');
    self:RegisterEvent('PLAYER_GUILD_UPDATE');
    self:RegisterEvent('MAX_EXPANSION_LEVEL_UPDATED');
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
end