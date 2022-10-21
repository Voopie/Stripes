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
    [167964] = { count = 8,  normal = 384, teeming = 1000 },
    [167967] = { count = 6,  normal = 384, teeming = 1000 },
    [170490] = { count = 5,  normal = 384, teeming = 1000 },
    [164862] = { count = 3,  normal = 384, teeming = 1000 },
    [164861] = { count = 2,  normal = 384, teeming = 1000 },
    [171184] = { count = 12, normal = 384, teeming = 1000 },
    [171333] = { count = 2,  normal = 384, teeming = 1000 },
    [164857] = { count = 2,  normal = 384, teeming = 1000 },
    [171341] = { count = 1,  normal = 384, teeming = 1000 },
    [167963] = { count = 5,  normal = 384, teeming = 1000 },
    [167965] = { count = 5,  normal = 384, teeming = 1000 },
    [170572] = { count = 6,  normal = 384, teeming = 1000 },
    [170480] = { count = 5,  normal = 384, teeming = 1000 },
    [171342] = { count = 2,  normal = 384, teeming = 1000 },
    [171181] = { count = 4,  normal = 384, teeming = 1000 },
    [168949] = { count = 4,  normal = 384, teeming = 1000 },
    [164873] = { count = 4,  normal = 384, teeming = 1000 },
    [165515] = { count = 4,  normal = 273, teeming = 1000 },
    [164562] = { count = 4,  normal = 273, teeming = 1000 },
    [165414] = { count = 4,  normal = 273, teeming = 1000 },
    [164557] = { count = 10, normal = 273, teeming = 1000 },
    [167876] = { count = 20, normal = 273, teeming = 1000 },
    [174175] = { count = 4,  normal = 273, teeming = 1000 },
    [167612] = { count = 6,  normal = 273, teeming = 1000 },
    [167610] = { count = 1,  normal = 273, teeming = 1000 },
    [164563] = { count = 4,  normal = 273, teeming = 1000 },
    [165415] = { count = 2,  normal = 273, teeming = 1000 },
    [167611] = { count = 4,  normal = 273, teeming = 1000 },
    [167607] = { count = 7,  normal = 273, teeming = 1000 },
    [165529] = { count = 4,  normal = 273, teeming = 1000 },
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
    [166276] = { count = 4,  normal = 260, teeming = 1000 },
    [173720] = { count = 16, normal = 260, teeming = 1000 },
    [164920] = { count = 4,  normal = 260, teeming = 1000 },
    [166299] = { count = 4,  normal = 260, teeming = 1000 },
    [173655] = { count = 16, normal = 260, teeming = 1000 },
    [167117] = { count = 1,  normal = 260, teeming = 1000 },
    [166275] = { count = 4,  normal = 260, teeming = 1000 },
    [173714] = { count = 16, normal = 260, teeming = 1000 },
    [169696] = { count = 8,  normal = 600, teeming = 1000 },
    [168969] = { count = 1,  normal = 600, teeming = 1000 },
    [168153] = { count = 12, normal = 600, teeming = 1000 },
    [163882] = { count = 14, normal = 600, teeming = 1000 },
    [168572] = { count = 8,  normal = 600, teeming = 1000 },
    [168580] = { count = 8,  normal = 600, teeming = 1000 },
    [163915] = { count = 10, normal = 600, teeming = 1000 },
    [163894] = { count = 12, normal = 600, teeming = 1000 },
    [164707] = { count = 6,  normal = 600, teeming = 1000 },
    [163862] = { count = 8,  normal = 600, teeming = 1000 },
    [163857] = { count = 4,  normal = 600, teeming = 1000 },
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
    [168907] = { count = 10, normal = 600, teeming = 1000 },
    [164737] = { count = 12, normal = 600, teeming = 1000 },
    [168878] = { count = 8,  normal = 600, teeming = 1000 },
    [163891] = { count = 6,  normal = 600, teeming = 1000 },
    [162046] = { count = 1,  normal = 364, teeming = 1000 },
    [166396] = { count = 4,  normal = 364, teeming = 1000 },
    [165076] = { count = 4,  normal = 364, teeming = 1000 },
    [171448] = { count = 4,  normal = 364, teeming = 1000 },
    [162038] = { count = 7,  normal = 364, teeming = 1000 },
    [162047] = { count = 7,  normal = 364, teeming = 1000 },
    [162056] = { count = 1,  normal = 364, teeming = 1000 },
    [162057] = { count = 7,  normal = 364, teeming = 1000 },
    [168591] = { count = 4,  normal = 364, teeming = 1000 },
    [171384] = { count = 4,  normal = 364, teeming = 1000 },
    [162049] = { count = 4,  normal = 364, teeming = 1000 },
    [171455] = { count = 1,  normal = 364, teeming = 1000 },
    [171799] = { count = 7,  normal = 364, teeming = 1000 },
    [162051] = { count = 2,  normal = 364, teeming = 1000 },
    [162039] = { count = 4,  normal = 364, teeming = 1000 },
    [167956] = { count = 1,  normal = 364, teeming = 1000 },
    [162040] = { count = 7,  normal = 364, teeming = 1000 },
    [171376] = { count = 10, normal = 364, teeming = 1000 },
    [168058] = { count = 1,  normal = 364, teeming = 1000 },
    [167955] = { count = 1,  normal = 364, teeming = 1000 },
    [162041] = { count = 2,  normal = 364, teeming = 1000 },
    [172265] = { count = 4,  normal = 364, teeming = 1000 },
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
    [163520] = { count = 6,  normal = 285, teeming = 1000 },
    [168843] = { count = 12, normal = 285, teeming = 1000 },
    [168844] = { count = 12, normal = 285, teeming = 1000 },
    [163506] = { count = 4,  normal = 285, teeming = 1000 },
    [168845] = { count = 12, normal = 285, teeming = 1000 },
    [168318] = { count = 8,  normal = 285, teeming = 1000 },
    [163524] = { count = 5,  normal = 285, teeming = 1000 },
    [168418] = { count = 4,  normal = 285, teeming = 1000 },
    [163503] = { count = 2,  normal = 285, teeming = 1000 },
    [168681] = { count = 6,  normal = 285, teeming = 1000 },
    [165138] = { count = 1,  normal = 283, teeming = 1000 },
    [166302] = { count = 4,  normal = 283, teeming = 1000 },
    [163121] = { count = 5,  normal = 283, teeming = 1000 },
    [165137] = { count = 6,  normal = 283, teeming = 1000 },
    [165872] = { count = 4,  normal = 283, teeming = 1000 },
    [163128] = { count = 4,  normal = 283, teeming = 1000 },
    [163618] = { count = 8,  normal = 283, teeming = 1000 },
    [165222] = { count = 4,  normal = 283, teeming = 1000 },
    [165197] = { count = 12, normal = 283, teeming = 1000 },
    [173016] = { count = 4,  normal = 283, teeming = 1000 },
    [167731] = { count = 4,  normal = 283, teeming = 1000 },
    [172981] = { count = 5,  normal = 283, teeming = 1000 },
    [173044] = { count = 4,  normal = 283, teeming = 1000 },
    [163620] = { count = 6,  normal = 283, teeming = 1000 },
    [163619] = { count = 4,  normal = 283, teeming = 1000 },
    [165919] = { count = 6,  normal = 283, teeming = 1000 },
    [165824] = { count = 15, normal = 283, teeming = 1000 },
    [171500] = { count = 1,  normal = 283, teeming = 1000 },
    [163621] = { count = 6,  normal = 283, teeming = 1000 },
    [162729] = { count = 4,  normal = 283, teeming = 1000 },
    [165911] = { count = 4,  normal = 283, teeming = 1000 },
    [170838] = { count = 4,  normal = 271, teeming = 1000 },
    [170850] = { count = 7,  normal = 271, teeming = 1000 },
    [164510] = { count = 4,  normal = 271, teeming = 1000 },
    [167538] = { count = 20, normal = 271, teeming = 1000 },
    [164506] = { count = 5,  normal = 271, teeming = 1000 },
    [167998] = { count = 8,  normal = 271, teeming = 1000 },
    [169893] = { count = 6,  normal = 271, teeming = 1000 },
    [170690] = { count = 4,  normal = 271, teeming = 1000 },
    [170882] = { count = 4,  normal = 271, teeming = 1000 },
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
    [178392] = { count = 18, normal = 290, teeming = 1000 },
    [177817] = { count = 4,  normal = 290, teeming = 1000 },
    [177816] = { count = 4,  normal = 290, teeming = 1000 },
    [177808] = { count = 8,  normal = 290, teeming = 1000 },
    [179334] = { count = 20, normal = 290, teeming = 1000 },
    [179837] = { count = 20, normal = 290, teeming = 1000 },
    [180495] = { count = 10, normal = 290, teeming = 1000 },
    [179840] = { count = 4,  normal = 290, teeming = 1000 },
    [179842] = { count = 8,  normal = 290, teeming = 1000 },
    [180348] = { count = 8,  normal = 290, teeming = 1000 },
    [176396] = { count = 3,  normal = 290, teeming = 1000 },
    [180335] = { count = 5,  normal = 290, teeming = 1000 },
    [176394] = { count = 5,  normal = 290, teeming = 1000 },
    [180091] = { count = 12, normal = 290, teeming = 1000 },
    [180567] = { count = 4,  normal = 290, teeming = 1000 },
    [179841] = { count = 4,  normal = 290, teeming = 1000 },
    [179821] = { count = 25, normal = 290, teeming = 1000 },
    [180336] = { count = 5,  normal = 290, teeming = 1000 },
    [176395] = { count = 5,  normal = 290, teeming = 1000 },
    [177807] = { count = 4,  normal = 290, teeming = 1000 },
    [179893] = { count = 4,  normal = 290, teeming = 1000 },
    [178163] = { count = 1,  normal = 346, teeming = 1000 },
    [178139] = { count = 6,  normal = 346, teeming = 1000 },
    [178165] = { count = 15, normal = 346, teeming = 1000 },
    [180431] = { count = 5,  normal = 346, teeming = 1000 },
    [180015] = { count = 5,  normal = 346, teeming = 1000 },
    [178133] = { count = 3,  normal = 346, teeming = 1000 },
    [179388] = { count = 5,  normal = 346, teeming = 1000 },
    [178142] = { count = 3,  normal = 346, teeming = 1000 },
    [178141] = { count = 3,  normal = 346, teeming = 1000 },
    [179386] = { count = 5,  normal = 346, teeming = 1000 },
    [178171] = { count = 10, normal = 346, teeming = 1000 },
    [180429] = { count = 10, normal = 346, teeming = 1000 },
    [180432] = { count = 5,  normal = 346, teeming = 1000 },
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
        190128, 189878                                  -- SL Season 4 Affix
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

    -- After DF release
    -- -- Common
    -- [1] = {
    --     120651, -- Explosives Affix
    --     174773, -- Spiteful Shade Affix
    -- };

    -- -- Uldaman
    -- [2] = {
    --    6906, 184018, 184125, 184422, 6907, 6908, 184124, 184581, 184019, 184301, 191220, 184130, 184131, 184132, 186420, 184300, 184582, 195511, 195508, 184020, 184335, 184331, 191311, 193530, 193554, 184580, 191913, 186696, 184319, 195344, 184107, 195343, 184134, 184303, 186664, 184022, 186658, 186107, 184023
    --},

    -- -- Ruby Life Pools
    -- [3] = {
    --    193435, 188252, 194630, 190034, 189886, 190054, 190408, 187897, 190485, 197985, 197697, 188067, 187969, 197535, 187894, 189893, 189232, 190484, 197915, 194687, 190400, 188244, 188011, 197509, 190207, 190206, 195119, 194654, 194667, 190059, 190397, 188087, 188086, 190205, 194622, 197982, 198047, 197698
    --},

    -- -- Algeth'ar Academy
    -- [4] = {
    --    191736, 190609, 196482, 194181, 197406, 196202, 196200, 196203, 196198, 192333, 196548, 196694, 196671, 191631, 196974, 196978, 196977, 196045, 196798, 191932, 197882, 196979, 192680, 195587, 196642, 197398, 197915, 195416, 196981, 196577, 197904, 196576, 197905, 192329, 196044, 197219, 197802
    --},

    -- -- Halls of Infusion
    -- [5] = {
    --    189722, 189727, 189729, 189719, 190407, 190406, 190342, 190366, 195399, 190362, 190368, 190403, 190401, 190405, 196712, 190371, 190373, 190345, 190377, 196043, 190348, 199037, 190340, 190359, 190370, 190404, 190923
    --},

    -- -- The Azure Vault
    -- [6] = {
    --    186739, 186644, 197025, 186738, 186740, 186741, 191164, 196115, 189555, 196102, 187160, 196116, 187139, 196117, 195138, 192955, 190187, 187240, 187246, 187155, 191739, 187159, 187999, 188100, 187482, 188046, 197081, 187242, 186737, 187154, 190510, 191313, 196559
    --},

    -- -- Brackenhide Hollow
    -- [7] = {
    --    186121, 186116, 186122, 186120, 196288, 185534, 185529, 195135, 194373, 186220, 194467, 186766, 185508, 186206, 186191, 189531, 194675, 189299, 192481, 197139, 187315, 186226, 185656, 194469, 186246, 186124, 186284, 197857, 189363, 196260, 187192, 186208, 194745, 196268, 186242, 187033, 185528, 186125, 185691, 187224, 194241, 194487, 197389, 191243, 186229, 187231, 187238, 194273
    --},

    -- -- The Nokhud Offensive
    -- [8] = {
    --    186151, 186616, 195723, 186615, 193457, 193462, 195875, 196645, 195876, 194367, 195933, 191207, 186338, 192794, 192796, 192800, 192789, 196263, 191847, 195821, 193373, 190294, 192791, 193565, 193544, 193555, 193553, 193467, 195579, 194896, 194898, 194894, 195696, 195877, 195855, 192848, 196306, 195928, 195927, 195930, 195929, 195265, 194317, 194315, 194316, 194897, 186339, 195878, 195842, 195851, 195847, 194895, 192803
    --},

    -- -- Neltharius
    -- [9] = {
    --    189340, 189478, 181861, 189901, 189669, 194816, 189466, 189470, 189361, 192134, 194389, 192781, 189235, 189471, 189467, 189265, 189227, 189464, 189472, 193944, 192786, 192787, 192788, 189266, 193293, 192464, 189247
    --},

    -- -- Temple of the Jade Serpent
    -- [10] = {
    --    56732, 56843, 56439, 56448, 56658, 62358, 62360, 56511, 59873, 57080, 56792, 72726, 58856, 59555, 59547, 58319, 59598, 64399, 57109, 65362, 56872, 59726, 60578, 62171, 59051, 56915, 59552, 59545, 59544, 59553, 59546, 65317, 56762, 58826
    --},

    -- -- Shadowmoon Burial Grounds
    -- [11] = {
    --    75452, 76407, 75829, 75509, 76057, 88769, 77006, 75451, 75966, 75979, 76190, 76104, 75459, 75899, 75715, 76518, 75713, 76446, 77700, 75506, 76444, 75652
    --},

    -- -- Halls of Valor
    -- [12] = {
    --    99868, 95675, 94960, 95833, 95676, 96611, 99802, 96647, 99922, 96608, 119990, 104822, 96609, 100877, 101326, 97081, 95843, 97083, 97084, 103049, 95672, 97202, 102557, 95807, 97219, 102558, 96677, 97068, 97788, 99891, 102019, 96574, 99828, 101637, 97087, 99804, 96640, 95834, 97197, 96664, 95832, 101639, 94968, 95842, 96934, 106320
    --},

    -- -- Court of Stars
    -- [13] = {
    --    101831, 104215, 104217, 104218, 104245, 108406, 105704, 108796, 132602, 108701, 108419, 108422, 104274, 132601, 104295, 105705, 107486, 106296, 111937, 113617, 104247, 104246, 111563, 107073, 104251, 110443, 111572, 107756, 107472, 110958, 104278, 104270, 107470, 110946, 110960, 104275, 112668, 104273, 132599, 104277, 105296, 106468, 105699, 105719, 105703, 132600, 132603, 132604, 104300, 110908, 110907, 107324, 104694, 104696, 104695, 105410, 107435, 112697, 112699, 110560, 108740, 104918, 105715, 107471, 110959, 106112
    --},

    -- -- Vault of the Incarnates
    -- [14] = {
    --    190245, 189813, 184972, 187771, 181378, 190496, 190688, 189233, 187593, 197145, 187768, 190586, 187767, 199233, 187638, 198311, 199333, 190686, 198308, 197595, 194991, 187772, 194990, 198326, 193760, 190588, 194647, 197671, 194999
    --},
};

D.KickByClassId = {
    -- [classId] = { [specIndex] = spellId, ... }
    [1]  = { [1] = 6552,   [2] = 6552,   [3] = 6552,   [5] = 6552 },   -- Warrior
    [2]  = { [1] = nil,    [2] = 96231,  [3] = 96231 },                -- Paladin
    [3]  = { [1] = 147362, [2] = 147362, [3] = 187707 },               -- Hunter
    [4]  = { [1] = 1766,   [2] = 1766,   [3] = 1766,   [5] = 1766 },   -- Rogue
    [5]  = { [1] = nil,    [2] = nil,    [3] = 15487 },                -- Priest
    [6]  = { [1] = 47528,  [2] = 47528,  [3] = 47528,  [5] = 47528 },  -- Death Knight
    [7]  = { [1] = 57994,  [2] = 57994,  [3] = 57994 },                -- Shaman
    [8]  = { [1] = 2139,   [2] = 2139,   [3] = 2139 },                 -- Mage
    [10] = { [1] = 116705, [2] = nil,    [3] = 116705, [5] = 116705 }, -- Monk
    [11] = { [1] = 78675,  [2] = 106839, [3] = 106839, [4] = nil },    -- Druid
    [12] = { [1] = 183752, [2] = 183752, [5] = 183752 },               -- Demon Hunter
    [13] = { [1] = 351338, [2] = 351338, [5] = 351338 },               -- Evoker
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
            D.Player.State.inMythic            = true;
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