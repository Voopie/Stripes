local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('PvPHealersIndicator');

-- Lua API
local string_gsub, string_format, table_wipe, unpack, ipairs = string.gsub, string.format, wipe, unpack, ipairs;

-- WoW API
local GetArenaOpponentSpec, GetNumArenaOpponentSpecs, GetBattlefieldScore, GetNumBattlefieldScores = GetArenaOpponentSpec, GetNumArenaOpponentSpecs, GetBattlefieldScore, GetNumBattlefieldScores;
local GetSpecializationInfoByID, UnitName = GetSpecializationInfoByID, UnitName;
local UNKNOWN = UNKNOWN;

local PlayerState = D.Player.State;

local HEALERS_TEXTURE = S.Media.Path .. 'Textures\\icons_healers';
local TANKS_TEXTURE   = S.Media.Path .. 'Textures\\icons_tanks';
local SOUNDFILE_ID    = 567458;

-- Local Config
local ENABLED, SOUND_ENABLED, ICON_SCALE;

local ICON_COORDS = {
    [257] = {   0, 1/4,   0, 1/2 }, -- Priest Holy
    [256] = { 1/4, 2/4,   0, 1/2 }, -- Priest Discipline
    [105] = { 2/4, 3/4,   0, 1/2 }, -- Druid Restoration
    [270] = { 3/4, 4/4,   0, 1/2 }, -- Monk Mistweaver
    [65]  = {   0, 1/4, 1/2, 2/2 }, -- Paladin Holy
    [264] = { 1/4, 2/4, 1/2, 2/2 }, -- Shaman Restoration

    [268] = {   0, 1/4,   0, 1/2 }, -- Monk Brewmaster
    [104] = { 1/4, 2/4,   0, 1/2 }, -- Druid Guardian
    [66]  = { 2/4, 3/4,   0, 1/2 }, -- Paladin Protection
    [73]  = { 3/4, 4/4,   0, 1/2 }, -- Warrior Protection
    [250] = {   0, 1/4, 1/2, 2/2 }, -- Death Knight Blood
    [581] = { 1/4, 2/4, 1/2, 2/2 }, -- Demon Hunter Vengeance
};

local tankSpecIDs = {
    [268] = true, -- Monk Brewmaster
    [104] = true, -- Druid Guardian
    [66]  = true, -- Paladin Protection
    [73]  = true, -- Warrior Protection
    [250] = true, -- Death Knight Blood
    [581] = true, -- Demon Hunter Vengeance
};

local healerSpecIDs = {
    257, -- Priest Holy
    256, -- Priest Discipline
    105, -- Druid Restoration
    270, -- Monk Mistweaver
	65,	 -- Paladin Holy
	264, -- Shaman Restoration

    -- Hooking tanks
    268, -- Monk Brewmaster
    104, -- Druid Guardian
    66,  -- Paladin Protection
    73,  -- Warrior Protection
    250, -- Death Knight Blood
    581, -- Demon Hunter Vengeance
};

local Healers, HealerSpecs = {}, {}

for _, specID in ipairs(healerSpecIDs) do
	local _, name = GetSpecializationInfoByID(specID);
	if name and not HealerSpecs[name] then
		HealerSpecs[name] = specID;
	end
end

local function GetNameWithRealm(unit)
    local name, realm = UnitName(unit);
    realm = (realm and realm ~= '') and string_gsub(realm, '[%s%-]', '');

    if name and realm then
        name = name .. '-' .. realm;
    end

    return name;
end

local function UpdateData()
	if not PlayerState.inPvPInstance then
        return;
    end

    local numOpps = GetNumArenaOpponentSpecs();

    if numOpps == 0 then
        local _, name, talentSpec;

        for i = 1, GetNumBattlefieldScores() do
            name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i);
            if name then
                name = string_gsub(name, '%-' .. string_gsub(D.Player.RealmNormalized, '[%s%-]', ''), '');
                if name and HealerSpecs[talentSpec] then
                    Healers[name] = talentSpec;
                elseif name and Healers[name] then
                    Healers[name] = nil;
                end
            end
        end
    elseif numOpps >= 1 then
        for i = 1, numOpps do
            local name = GetNameWithRealm(string_format('arena%d', i));

            if name and name ~= UNKNOWN then
                local s = GetArenaOpponentSpec(i);
                local _, talentSpec = nil, UNKNOWN;

                if s and s > 0 then
                    _, talentSpec = GetSpecializationInfoByID(s);
                end

                if talentSpec and talentSpec ~= UNKNOWN and HealerSpecs[talentSpec] then
                    Healers[name] = talentSpec;
                end
            end
        end
    end
end

local function Create(unitframe)
    if unitframe.PVPHealers then
        return;
    end

    local frame = CreateFrame('Frame', '$parentPVPHealersIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    frame.icon:SetPoint('BOTTOM', unitframe, 'TOP', 0, 4);
    frame.icon:SetSize(32, 32);

    frame:SetShown(false);

    unitframe.PVPHealers = frame;
end

local function Update(unitframe)
    if not ENABLED or unitframe.data.unitType == 'SELF' or not PlayerState.inPvPInstance then
        unitframe.PVPHealers:SetShown(false);
        return;
    end

    local name = GetNameWithRealm(unitframe.data.unit);

    if Healers[name] then
        local specID = HealerSpecs[Healers[name]];

        unitframe.PVPHealers.icon:SetTexture(tankSpecIDs[specID] and TANKS_TEXTURE or HEALERS_TEXTURE);
        unitframe.PVPHealers.icon:SetTexCoord(unpack(ICON_COORDS[specID]));
        unitframe.PVPHealers:SetScale(ICON_SCALE);
        unitframe.PVPHealers:SetShown(true);
    else
        unitframe.PVPHealers:SetShown(false);
    end
end

local function UpdateMouseoverUnit()
    if not SOUND_ENABLED then
        return;
    end

    if not PlayerState.inPvPInstance then
        return;
    end

    if Healers[GetNameWithRealm('mouseover')] then
        PlaySoundFile(SOUNDFILE_ID);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.PVPHealers then
        unitframe.PVPHealers:SetShown(false);
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED       = O.db.pvp_healers_enabled;
    SOUND_ENABLED = O.db.pvp_healers_sound;
    ICON_SCALE    = O.db.pvp_healers_icon_scale;
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_ENTERING_WORLD', function()
        table_wipe(Healers);
    end);

    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', UpdateMouseoverUnit);
    self:RegisterEvent('ARENA_OPPONENT_UPDATE', UpdateData);
    self:RegisterEvent('UPDATE_BATTLEFIELD_SCORE', UpdateData);
end