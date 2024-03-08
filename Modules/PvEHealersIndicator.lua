local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('PvEHealersIndicator');

-- Sripes API
local U_GetNpcID = U.GetNpcID;

-- Local Config
local ENABLED, SOUND_ENABLED, ICON_SCALE, POINT, RELATIVE_POINT, OFFSET_X, OFFSET_Y, STRATA;

local TEXTURE = S.Media.Path .. 'Textures\\icons_healers';
local SOUNDFILE_ID = 567458;

local mobsIDs = {
    -- Cataclysm
    [41096] = true, -- Throne of the Tides: Naz'jar Oracle

    -- Warlords of Draenor
    [75713] = true, -- Shadowmoon Burial Grounds: Shadowmoon Bone-Mender

    -- Legion
    [95834]  = true, -- Halls of Valor: Valarjar Mystic
    [104270] = true, -- Court of Stars: Guardian Construct

    -- Battle for Azeroth
    [122973] = true, -- Atal'Dazar: Dazar'ai Confessor

    [137591] = true, -- King's Rest: Healing Tide Totem

    [130661] = true, -- MOTHERLODE!!: Venture Co. Earthshaper
    [133430] = true, -- MOTHERLODE!!: Venture Co. Mastermind
    [133593] = true, -- MOTHERLODE!!: Expert Technician

    [136186] = true, -- Shrine of the Storm: Tidesage Spiritualist
    [136297] = true, -- Shrine of the Storm: Forgotten Denizen

    [134990] = true, -- Temple of Sethraliss: Charged Dust Devil
    [134364] = true, -- Temple of Sethraliss: Faithless Tender

    [130028] = true, -- Tol Dagor: Ashvane Priest

    [131492] = true, -- Underrot: Devout Blood Priest

    [131666] = true, -- Waycrest Manor: Coven Thornshaper

    [150251] = true, -- Operation: Mechagon: Pistonhead Mechanic
    [144295] = true, -- Operation: Mechagon: Mechagon Mechanic

    -- Battle for Stromgarde
    [139064] = true, -- Ar'gorok Shaman
    [139066] = true, -- Ar'gorok Witch Doctor
    [138696] = true, -- Crusading Sunbringer
    [133464] = true, -- Alliance Priest
    [138962] = true, -- Darkspear Witch Doctor
    [138767] = true, -- Defiler Shadow Priest
    [138942] = true, -- Grizzled Shaman
    [139007] = true, -- Grizzled Witch Doctor
    [138892] = true, -- Wildhammer Shaman

    -- Darkshore
    [144974] = true, -- Forsaken Alchemist
    [144802] = true, -- Forsaken Alchemist
    [145488] = true, -- Blightguard Alchemist
    [144971] = true, -- Druid of the Branch
    [148610] = true, -- Druid of the Branch
    [145250] = true, -- Madfeather

    -- Shadowlands
    [164921] = true, -- Mists of Tirna Scithe: Drust Harvester
    [166275] = true, -- Mists of Tirna Scithe: Mistveil Shaper
    [166299] = true, -- Mists of Tirna Scithe: Mistveil Tender
    [167111] = true, -- Mists of Tirna Scithe: Spinemaw Staghorn

    [167965] = true, -- De Other Side: Lubricator
    [170490] = true, -- De Other Side: Atal'ai High Priest
    [170572] = true, -- De Other Side: Atal'ai Hoodoo Hexxer

    [165222] = true, -- The Necrotic Wake: Zolramus Bonemender
    [165872] = true, -- The Necrotic Wake: Flesh Crafter

    [168420] = true, -- Spires of Ascension: Forsworn Champion
    [163459] = true, -- Spires of Ascension: Forsworn Mender
    [168718] = true, -- Spires of Ascension: Forsworn Warden

    [174197] = true, -- Theater of Pain: Battlefield Ritualist

    [165529] = true, -- Halls of Atonement: Depraved Collector

    [177817] = true, -- Tazavesh (Lower): Support Officer
    [178141] = true, -- Tazavesh (Upper): Murkbrine Scalebinder
    [179733] = true, -- Tazavesh (Upper): Invigorating Fish Stick
    [180432] = true, -- Tazavesh (Upper): Devoted Accomplice

    -- Dragonflight
    [188067] = true, -- Ruby Life Pools: Flashfrost Chillweaver
    [197985] = true, -- Ruby Life Pools: Flame Channeler
};

local function Create(unitframe)
    if unitframe.PVEHealers then
        return;
    end

    local frame = CreateFrame('Frame', '$parentPVEHealersIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetPoint(POINT, unitframe.healthBar, RELATIVE_POINT, OFFSET_X, OFFSET_Y);
    icon:SetTexture(TEXTURE);
    icon:SetTexCoord(3/4, 4/4, 0, 1/2); -- Monk Mistweaver icon
    icon:SetSize(32, 32);

    frame.icon = icon;

    frame:Hide();

    unitframe.PVEHealers = frame;
end

local function Update(unitframe)
    if not unitframe.PVEHealers then
        return;
    end

    if not (ENABLED and unitframe.data.npcId and mobsIDs[unitframe.data.npcId]) then
        unitframe.PVEHealers:Hide();
        return;
    end

    local pveHealersFrame = unitframe.PVEHealers;

    pveHealersFrame:SetFrameStrata(STRATA == 1 and unitframe.healthBar:GetFrameStrata() or STRATA);
    pveHealersFrame:SetScale(ICON_SCALE);
    pveHealersFrame.icon:ClearAllPoints();
    pveHealersFrame.icon:SetPoint(POINT, unitframe.healthBar, RELATIVE_POINT, OFFSET_X, OFFSET_Y);
    pveHealersFrame:Show();
end

local function UpdateMouseoverUnit()
    if mobsIDs[U_GetNpcID('mouseover')] then
        PlaySoundFile(SOUNDFILE_ID);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.PVEHealers then
        unitframe.PVEHealers:Hide();
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED        = O.db.pve_healers_enabled;
    SOUND_ENABLED  = O.db.pve_healers_sound;
    ICON_SCALE     = O.db.pve_healers_icon_scale;
    POINT          = O.Lists.frame_points[O.db.pve_healers_icon_point] or 'BOTTOM';
    RELATIVE_POINT = O.Lists.frame_points[O.db.pve_healers_icon_relative_point] or 'TOP';
    OFFSET_X       = O.db.pve_healers_icon_offset_x;
    OFFSET_Y       = O.db.pve_healers_icon_offset_y;
    STRATA         = O.db.pve_healers_icon_strata ~= 1 and O.Lists.frame_strata[O.db.pve_healers_icon_strata] or 1;

    if ENABLED and SOUND_ENABLED then
        self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', UpdateMouseoverUnit);
    else
        self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
end