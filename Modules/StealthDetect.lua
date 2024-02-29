local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('StealthDetect');

-- Stripes API
local UnitHasAura = U.UnitHasAura;

-- Libraries
local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start, LCG_PixelGlow_Stop = LCG.PixelGlow_Start, LCG.PixelGlow_Stop;
local LCG_AutoCastGlow_Start, LCG_AutoCastGlow_Stop, LCG_ButtonGlow_Start, LCG_ButtonGlow_Stop = LCG.AutoCastGlow_Start, LCG.AutoCastGlow_Stop, LCG.ButtonGlow_Start, LCG.ButtonGlow_Stop;
local LCG_SUFFIX = 'S_STEALTHDETECT';

-- Local Config
local ENABLED, ALWAYS, NOT_IN_COMBAT, GLOW_ENABLED, GLOW_TYPE, GLOW_COLOR;

local PlayerState = D.Player.State;

local STEALTH_TEXTURE = 1391768;

local isStealthed;

local auras = {
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

    [ 79140] = true, -- Vendetta (Rogue)
    [188501] = true, -- Spectral Sight (Demon Hunter)
};

local units = {
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
    [150254] = true, -- Scraphound (Operation Mechagon: JY)
    [150292] = true, -- Mechagon Cavalry (Operation Mechagon: JY)
    [144298] = true, -- Defense Bot Mk III (Operation Mechagon: UP)

    -- Shadowlands
    -- Dungeons
    [164563] = true, -- Vicious Gargon (Halls of Atonement)
    [163524] = true, -- Kyrian Dark-Praetor (Spires of Ascension)
    [164929] = true, -- Tirnenn Villager (Mists of Tirna Scithe)
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
};

local function Create(unitframe)
    if unitframe.StealthDetect then
        return;
    end

    local frame = CreateFrame('Frame', '$parentStealthDetect', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);
    frame:SetFrameStrata('HIGH');

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    frame.icon:SetPoint('LEFT', unitframe.healthBar, 'RIGHT', 4, 0);
    frame.icon:SetTexture(STEALTH_TEXTURE);
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    frame.icon:SetSize(20, 20);

    frame.border = frame:CreateTexture(nil, 'BORDER');
    frame.border:SetPoint('TOPLEFT', frame.icon, 'TOPLEFT', -1, 1);
    frame.border:SetPoint('BOTTOMRIGHT', frame.icon, 'BOTTOMRIGHT', 1, -1);
    frame.border:SetColorTexture(0.3, 0.3, 0.3);

    frame.glow = CreateFrame('Frame', nil, frame);
    frame.glow:SetAllPoints(frame.icon);

    frame:Hide();

    unitframe.StealthDetect = frame;
end

local function Update(unitframe)
    if ENABLED then
        if NOT_IN_COMBAT and PlayerState.inCombat then
            unitframe.StealthDetect:Hide();
        else
            local found = false;

            if units[unitframe.data.npcId] then
                found = true;
            else
                local aura = UnitHasAura(unitframe.data.unit, auras);

                if aura then
                    found = true;
                end
            end

            if ALWAYS then
                unitframe.StealthDetect:SetShown(found);
            else
                unitframe.StealthDetect:SetShown(isStealthed and found);
            end
        end
    else
        unitframe.StealthDetect:Hide();
    end
end

local function UpdateGlow(unitframe)
    local glowFrame = unitframe.StealthDetect and unitframe.StealthDetect.glow;

    if not glowFrame then
        return;
    end

    LCG_PixelGlow_Stop(glowFrame, LCG_SUFFIX);
    LCG_AutoCastGlow_Stop(glowFrame, LCG_SUFFIX);
    LCG_ButtonGlow_Stop(glowFrame);

    if GLOW_ENABLED then
        if GLOW_TYPE == 1 then
            LCG_PixelGlow_Start(glowFrame, GLOW_COLOR, 8, nil, 8, nil, 1, 1, nil, LCG_SUFFIX);
        elseif GLOW_TYPE == 2 then
            LCG_AutoCastGlow_Start(glowFrame, GLOW_COLOR, nil, nil, nil, nil, nil, LCG_SUFFIX);
        elseif GLOW_TYPE == 3 then
            LCG_ButtonGlow_Start(glowFrame);
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
    self:ForAllActiveUnitFrames(Update);
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