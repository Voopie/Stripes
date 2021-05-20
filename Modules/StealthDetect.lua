local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('StealthDetect');

local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start = LCG.PixelGlow_Start;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local ENABLED, ALWAYS;

local STEALTH_TEXTURE = 1391768;
local GLOW_COLOR = { 0.64, 0.24, 0.94 };

local stealthed;

-- TODO: also check for auras

local units = {
    -- Shadowlands
    -- Dungeons
    [165349] = true, -- Animated Corpsehound (Maldraxxus)
    [164563] = true, -- Vicious Gargon (Halls of Atonement)
    [163524] = true, -- Kyrian Dark-Praetor (Spires of Ascension)
    [164929] = true, -- Tirnenn Villager (Mists of Tirna Scithe)

    -- Maw
    [173188] = true, -- Mawsworn Outrider
    [167331] = true, -- Nascent Shade
    [175857] = true, -- Crystalline Paingolem
    [173138] = true, -- Mawsworn Outrider
    [175700] = true, -- Mawsworn Eviscerator
    [176002] = true, -- Stygian Goliath

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
    frame.glow:SetAllPoints(frame.icon)

    LCG_PixelGlow_Start(frame.glow, GLOW_COLOR, 8, nil, 8, nil, 1, 1, nil, 'S_STEALTHDETECT');

    frame:SetShown(false);

    unitframe.StealthDetect = frame;
end

local function Update(unitframe)
    if ENABLED then
        if ALWAYS then
            unitframe.StealthDetect:SetShown(units[unitframe.data.npcId]);
        else
            unitframe.StealthDetect:SetShown(stealthed and units[unitframe.data.npcId]);
        end
    else
        unitframe.StealthDetect:SetShown(false);
    end
end

local function Hide(unitframe)
    if unitframe.StealthDetect then
        unitframe.StealthDetect:SetShown(false);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    Hide(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    stealthed = IsStealthed();

    ENABLED = O.db.stealth_detect_enabled;
    ALWAYS  = O.db.stealth_detect_always;
end

function Module:UPDATE_STEALTH()
    stealthed = IsStealthed();

    for _, unitframe in pairs(NP) do
        Update(unitframe);
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:RegisterEvent('UPDATE_STEALTH');
end