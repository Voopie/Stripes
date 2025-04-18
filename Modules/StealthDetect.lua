local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('StealthDetect');

-- Stripes API
local U_UnitHasAura = U.UnitHasAura;
local U_GlowStart, U_GlowStopAll = U.GlowStart, U.GlowStopAll;

-- Libraries
local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start = LCG.PixelGlow_Start;
local LCG_SUFFIX = 'S_STEALTHDETECT';

-- Local Config
local ENABLED, ALWAYS, NOT_IN_COMBAT, GLOW_ENABLED, GLOW_TYPE, GLOW_COLOR;

local playerState = D.Player.State;

local STEALTH_TEXTURE = 1391768;

local isStealthed;

local auras = {
    [8279]  = true, -- Stealth Detection
    [12418] = true, -- Stealth Detection
    [23217] = true, -- Stealth Detection
    [37691] = true, -- Stealth Detection
    [38551] = true, -- Stealth Detection
    [40273] = true, -- Stealth Detection

    [28496] = true, -- Greater Stealth Detection

    [1223119] = true, -- Invisibility and Stealth Detection
    [412892]  = true, -- Invisibility and Stealth Detection
    [41634]   = true, -- Invisibility and Stealth Detection
    [312398]  = true, -- Invisibility and Stealth Detection
    [18950]   = true, -- Invisibility and Stealth Detection
    [371325]  = true, -- Invisibility and Stealth Detection
    [67236]   = true, -- Invisibility and Stealth Detection
    [93105]   = true, -- Invisibility and Stealth Detection
    [148500]  = true, -- Invisibility and Stealth Detection
    [155183]  = true, -- Invisibility and Stealth Detection
    [363794]  = true, -- Invisibility and Stealth Detection
    [372149]  = true, -- Invisibility and Stealth Detection
    [70465]   = true, -- Invisibility and Stealth Detection

    [413451] = true, -- Stealth and Invisibility Detection [DNT]
    [141956] = true, -- Stealth and Invisibility Detection [DNT]
    [141048] = true, -- Stealth and Invisibility Detection [DNT]
    [141753] = true, -- Stealth and Invisibility Detection [DNT]

    [201626] = true, -- Sight Beyond Sight
    [238468] = true, -- Sight Beyond Sight
    [311928] = true, -- Sight Beyond Sight
    [319629] = true, -- Sight Beyond Sight

    [203761] = true, -- Detector
    [230368] = true, -- Detector
    [248705] = true, -- Detector
    [276675] = true, -- Detector
    [298085] = true, -- Detector
    [307007] = true, -- Detector
    [333670] = true, -- Detector
    [339781] = true, -- Detector
    [351410] = true, -- Detector

    [ 34709] = true, -- Shadow Sight
    [225649] = true, -- Shadow Sight
    [323342] = true, -- Shadow Sight

    [127907] = true, -- Phosphorescence
    [127913] = true, -- Phosphorescence

    [242962] = true, -- One With the Void
    [242963] = true, -- One With the Void

    [169902] = true, -- All-Seeing Eye
    [201746] = true, -- Weapon Scope
    [202568] = true, -- Piercing Vision
    [203149] = true, -- Animal Instincts
    [213486] = true, -- Demonic Vision
    [214793] = true, -- Vigilant
    [232143] = true, -- Demonic Senses

    [330577] = true, -- Trained Eyes

    [333302] = true, -- Keen Senses
    [434734] = true, -- Keen Senses
    [411710] = true, -- Primal Senses

    [ 79140] = true, -- Vendetta (Rogue)
    [188501] = true, -- Spectral Sight (Demon Hunter)
};

local units = {
    -- Cataclysm
    -- Dungeons
    [40936]  = true, -- Faceless Watcher (Throne of the Tides)
    [39392]  = true, -- Faceless Corruptor (Grim Batol)
    [40166]  = true, -- Molten Giant (Grim Batol)
    [224609] = true, -- Twilight Destroyer (Grim Batol)
    [224221] = true, -- Twilight Overseer (Grim Batol)
    [224249] = true, -- Twilight Lavabender (Grim Batol)

    -- Legion
    -- Dungeons
    [91796]  = true, -- Skrog Wavecrasher (Eye of Azshara)
    [95939]  = true, -- Skrog Tidestomper (Eye of Azshara)
    [104270] = true, -- Guardian Construct (Court of Stars)
    [104277] = true, -- Legion Hound (Court of Stars)
    [104278] = true, -- Felbound Enforcer (Court of Stars)
    [105699] = true, -- Mana Saber (Court of Stars)

    -- BfA
    -- Dungeons
    [136139] = true, -- Mechanized Peacekeeper (The MOTHERLODE!!)
    [133430] = true, -- Venture Co. Mastermind (The MOTHERLODE!!)
    [133463] = true, -- Venture Co. War Machine (The MOTHERLODE!!)
    [150254] = true, -- Scraphound (Operation Mechagon: JY)
    [150292] = true, -- Mechagon Cavalry (Operation Mechagon: JY)
    [144293] = true, -- Waste Processing Unit (Operation Mechagon: UP)
    [144298] = true, -- Defense Bot Mk III (Operation Mechagon: UP)

    -- Shadowlands
    -- Dungeons
    [164563] = true, -- Vicious Gargon (Halls of Atonement)
    [163524] = true, -- Kyrian Dark-Praetor (Spires of Ascension)
    [164929] = true, -- Tirnenn Villager (Mists of Tirna Scithe)
    [163086] = true, -- Rancid Gasbag (Theater of Pain)
    [170850] = true, -- Raging Bloodhorn (Theater of Pain)
    [163882] = true, -- Decaying Flesh Giant (Plaguefall)
    [179837] = true, -- Tracker Zo'korss (Tazavesh: Streets)

    -- Open World
    [165349] = true, -- Animated Corpsehound (Maldraxxus)
    [169760] = true, -- Archivam Assassin

    -- Maw
    [173188] = true, -- Mawsworn Outrider
    [167331] = true, -- Nascent Shade
    [175857] = true, -- Crystalline Paingolem
    [173138] = true, -- Mawsworn Outrider
    [175700] = true, -- Mawsworn Eviscerator
    [176002] = true, -- Stygian Goliath
    [177132] = true, -- Helsworn Soulseeker

    -- Torghast
    [152708] = true, -- Mawsworn Seeker
    [155238] = true, -- Guardian of the Leaf
    [151127] = true, -- Lord of Torment
    [151128] = true, -- Lord of Locks
    [157322] = true, -- Lord of Locks
    [155828] = true, -- Runecarved Colossus
    [155908] = true, -- Deathspeaker
    [152905] = true, -- Tower Sentinel
    [171422] = true, -- Arch-Suppressor Laguas
    [156241] = true, -- Monstrous Guardian
    [151817] = true, -- Deadsoul Devil
    [151816] = true, -- Deadsoul Scavenger
    [153885] = true, -- Deadsoul Shambler
    [152656] = true, -- Deadsoul Stalker
    [152898] = true, -- Deadsoul Chorus
    [151818] = true, -- Deadsoul Miscreation
    [175502] = true, -- Grand Automaton
    [156245] = true, -- Grand Automaton
    [156244] = true, -- Winged Automaton
    [173051] = true, -- Suppressor Xelors

    -- Dragonflight
    -- Dungeons
    [187159] = true, -- Shrieking Whelp (The Azure Vault)
    [191847] = true, -- Nokhud Plainstomper (The Nokhud Offensive)
    [192800] = true, -- Nokhud Lancemaster (The Nokhud Offensive)
    [194317] = true, -- Stormcaller Boroo (The Nokhud Offensive)
    [194316] = true, -- Stormcaller Zarii (The Nokhud Offensive)
    [194315] = true, -- Stormcaller Solongo (The Nokhud Offensive)
    [195265] = true, -- Stormcaller Arynga (The Nokhud Offensive)
    [195696] = true, -- Primalist Thunderbeast (The Nokhud Offensive)
    [187897] = true, -- Defier Draghar (Ruby Life Pools)
    [206214] = true, -- Infinite Infiltrator (Dawn of the Infinite: Galakrond's Fall)

    -- The War Within
    -- Dungeons
    [217531] = true, -- Ixin <Sureki Attendant> (Ara-Kara, City of Echoes)
    [218324] = true, -- Nakt <Sureki Attendant> (Ara-Kara, City of Echoes)
    [217533] = true, -- Atik <Sureki Attendant> (Ara-Kara, City of Echoes)
    [216338] = true, -- Hulking Bloodguard (Ara-Kara, City of Echoes)
    [216364] = true, -- Blood Overseer (Ara-Kara, City of Echoes)
    [217039] = true, -- Nerubian Hauler (Ara-Kara, City of Echoes)
    [220197] = true, -- Royal Swarmguard (City of Threads)
    [220196] = true, -- Herald of Ansurek (City of Threads)
    [220423] = true, -- Retired Lord Vul'azak (City of Threads)
    [216328] = true, -- Unstable Test Subject (City of Threads)
    [210109] = true, -- Earth Infused Golem (The Stonevault)
    [214264] = true, -- Cursedforge Honor Guard (The Stonevault)
    [213343] = true, -- Forge Loader (The Stonevault)
    [213954] = true, -- Rock Smasher (The Stonevault)
    [212765] = true, -- Void-Bound Despoiler (The Stonevault)
    [214761] = true, -- Nightfall Ritualist (The Dawnbreaker)
    [214762] = true, -- Nightfall Commander (The Dawnbreaker)
    [210966] = true, -- Sureki Webmage (The Dawnbreaker)
    [211261] = true, -- Ascendant Vis'coxria (The Dawnbreaker)
    [213934] = true, -- Nightfall Tactician (The Dawnbreaker)
    [213932] = true, -- Sureki Militant (The Dawnbreaker)
    [211341] = true, -- Manifested Shadow (The Dawnbreaker)
    [211262] = true, -- Ixkreten the Unbreakable (The Dawnbreaker)
    [211263] = true, -- Deathscreamer Iken'tak (The Dawnbreaker)
    [213885] = true, -- Nightfall Dark Architect (The Dawnbreaker)
    [206696] = true, -- Arathi Knight (Priory of the Sacred Flame)
    [206710] = true, -- Lightspawn (Priory of the Sacred Flame)
    [212826] = true, -- Guard Captain Suleyman (Priory of the Sacred Flame)
    [212827] = true, -- High Priest Aemya (Priory of the Sacred Flame)
    [212831] = true, -- Forge Master Damian (Priory of the Sacred Flame)
    [239833] = true, -- Elaena Emberlanz (Priory of the Sacred Flame)
    [239834] = true, -- Taener Duelmal (Priory of the Sacred Flame)
    [239836] = true, -- Sergeant Shaynemail (Priory of the Sacred Flame)
    [223423] = true, -- Careless Hopgoblin (Cinderbrew Meadery)
    [220946] = true, -- Venture Co. Honey Harvester (Cinderbrew Meadery)
    [211121] = true, -- Rank Overseer (Darkflame Cleft)
    [212411] = true, -- Torchsnarl (Darkflame Cleft)
    [231325] = true, -- Darkfuse Jumpstarter (Operation: Floodgate)
    [231197] = true, -- Bubbles (Operation: Floodgate)
    [230740] = true, -- Shreddinator 3000 (Operation: Floodgate)
};

local function Create(unitframe)
    if unitframe.StealthDetect then
        return;
    end

    local frame = CreateFrame('Frame', '$parentStealthDetect', unitframe.HealthBarsContainer.healthBar);
    frame:SetAllPoints(unitframe.HealthBarsContainer.healthBar);
    frame:SetFrameStrata('HIGH');

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetPoint('LEFT', unitframe.HealthBarsContainer.healthBar, 'RIGHT', 4, 0);
    icon:SetTexture(STEALTH_TEXTURE);
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    icon:SetSize(20, 20);

    local border = frame:CreateTexture(nil, 'BORDER');
    border:SetPoint('TOPLEFT', icon, 'TOPLEFT', -1, 1);
    border:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 1, -1);
    border:SetColorTexture(0.3, 0.3, 0.3);

    local glow = CreateFrame('Frame', nil, frame);
    glow:SetAllPoints(icon);

    frame.icon   = icon;
    frame.border = border;
    frame.glow   = glow;

    frame:Hide();

    unitframe.StealthDetect = frame;
end

local function Update(unitframe)
    if not ENABLED or (NOT_IN_COMBAT and playerState.inCombat) then
        unitframe.StealthDetect:Hide();
        return;
    end

    local found = false;

    if units[unitframe.data.npcId] then
        found = true;
    else
        local aura = U_UnitHasAura(unitframe.data.unit, auras);

        if aura then
            found = true;
        end
    end

    local shouldShow = ALWAYS and found or (isStealthed and found);

    unitframe.StealthDetect:SetShown(shouldShow);
end

local function UpdateGlow(unitframe)
    local glowFrame = unitframe.StealthDetect and unitframe.StealthDetect.glow;

    if not glowFrame then
        return;
    end

    U_GlowStopAll(glowFrame, LCG_SUFFIX);

    if GLOW_ENABLED then
        if GLOW_TYPE == 1 then
            LCG_PixelGlow_Start(glowFrame, GLOW_COLOR, 8, nil, 8, nil, 1, 1, nil, LCG_SUFFIX);
        else
            U_GlowStart(glowFrame, GLOW_TYPE, GLOW_COLOR, LCG_SUFFIX)
        end
    end
end

local function Hide(unitframe)
    if unitframe.StealthDetect then
        unitframe.StealthDetect:Hide();
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    UpdateGlow(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    Hide(unitframe);
end

function Module:UnitAura(unitframe)
    Update(unitframe);
end

function Module:Update(unitframe)
    UpdateGlow(unitframe);
    Update(unitframe);
end

function Module:UpdateAll()
    self:ForAllActiveAndShownUnitFrames(Update);
end

function Module:UpdateLocalConfig()
    isStealthed = IsStealthed();

    ENABLED       = O.db.stealth_detect_enabled;
    ALWAYS        = O.db.stealth_detect_always;
    NOT_IN_COMBAT = O.db.stealth_detect_not_in_combat;

    GLOW_ENABLED = O.db.stealth_detect_glow_enabled;
    GLOW_TYPE    = O.db.stealth_detect_glow_type;

    if not GLOW_TYPE or GLOW_TYPE == 0 then
        GLOW_ENABLED = false;
    end

    GLOW_COLOR    = GLOW_COLOR or {};
    GLOW_COLOR[1] = O.db.stealth_detect_glow_color[1];
    GLOW_COLOR[2] = O.db.stealth_detect_glow_color[2];
    GLOW_COLOR[3] = O.db.stealth_detect_glow_color[3];
    GLOW_COLOR[4] = O.db.stealth_detect_glow_color[4] or 1;

    if ENABLED then
        self:RegisterEvent('UPDATE_STEALTH');

        if NOT_IN_COMBAT then
            self:RegisterEvent('PLAYER_REGEN_ENABLED', 'UpdateAll');
            self:RegisterEvent('PLAYER_REGEN_DISABLED', 'UpdateAll');
        end
    else
        self:UnregisterEvent('UPDATE_STEALTH');
        self:UnregisterEvent('PLAYER_REGEN_ENABLED');
        self:UnregisterEvent('PLAYER_REGEN_DISABLED');
    end
end

function Module:UPDATE_STEALTH()
    isStealthed = IsStealthed();

    self:UpdateAll();
end

function Module:StartUp()
    self:UpdateLocalConfig();
end