local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('MythicPlusSpiteful');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local string_format = string.format;

-- WoW API
local UnitName = UnitName;

-- Local Config
local ENABLED, ONLY_ON_ME, TIME_TO_DIE;

local PlayerData = D.Player;

local SPITEFUL_NPC_ID  = 174773;
local SPITEFUL_TEXTURE = 135945;

local function Create(unitframe)
    if unitframe.Spiteful then
        return;
    end

    local frame = CreateFrame('Frame', '$parentSpiteful', unitframe.healthBar);
    frame:SetPoint('BOTTOM', unitframe, 'TOP', 0, 4);
    frame:SetSize(32, 32);
    frame:SetFrameStrata('LOW');

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    frame.icon:SetAllPoints();
    frame.icon:SetTexture(SPITEFUL_TEXTURE);
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    frame.icon:Hide();

    frame.ttd = frame:CreateFontString(nil, 'OVERLAY', 'StripesHealthTextFont');
    frame.ttd:SetPoint('TOPRIGHT', unitframe.healthBar, 'BOTTOMRIGHT', 0, 0);
    frame.ttd:Hide();

    unitframe.Spiteful = frame;
end

local function Update(unitframe)
    if not unitframe.Spiteful then
        return;
    end

    if not ENABLED or unitframe.data.isPersonal then
        unitframe.Spiteful.icon:Hide();
        unitframe.Spiteful.ttd:Hide();

        return;
    end

    if unitframe:IsShown() then
        local showIcon = unitframe.data.npcId == SPITEFUL_NPC_ID;
        local showTTD  = showIcon and TIME_TO_DIE and unitframe.data.healthPerF;

        unitframe.Spiteful.icon:SetShown(showIcon and (ONLY_ON_ME and unitframe.data.targetName == PlayerData.Name or not ONLY_ON_ME));
        unitframe.Spiteful.ttd:SetShown(showTTD);

        if showTTD then
            unitframe.Spiteful.ttd:SetText(string.format('%.1f%s', unitframe.data.healthPerF / 8, L['SECOND_SHORT']))
        end
    end
end

local function OnUpdate(unitframe)
    if not unitframe.Spiteful or not unitframe.data.unit then
        return;
    end

    local targetName = UnitName(unitframe.data.unit .. 'target');
    local shouldUpdate = TIME_TO_DIE or targetName ~= unitframe.data.targetName or targetName == PlayerData.Name;

    if shouldUpdate then
        unitframe.data.targetName = targetName;
        Update(unitframe);
    end
end

local function Reset(unitframe)
    if unitframe.Spiteful then
        unitframe.Spiteful.icon:Hide();
        unitframe.Spiteful.ttd:Hide();
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    Reset(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED     = O.db.spiteful_enabled;
    ONLY_ON_ME  = O.db.spiteful_show_only_on_me;
    TIME_TO_DIE = O.db.spiteful_ttd_enabled;

    local isSpitefulCurrentWeek = U.IsAffixCurrent(123);

    if ENABLED and isSpitefulCurrentWeek then
        Stripes.Updater:Add('MythicPlusSpiteful', OnUpdate);
    else
        Stripes.Updater:Remove('MythicPlusSpiteful');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
end