local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('MythicPlusSpiteful');
local Stripes = S:GetNameplateModule('Handler');

-- WoW API
local UnitName = UnitName;

-- Local config
local ENABLED, ONLY_ON_ME;

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

    frame:SetShown(false);

    unitframe.Spiteful = frame;
end

local function Update(unitframe)
    if not unitframe.Spiteful then
        return;
    end

    if not ENABLED or unitframe.data.unitType == 'SELF' then
        unitframe.Spiteful:SetShown(false);
        return;
    end

    if unitframe:IsShown() then
        if ENABLED and unitframe.data.npcId == SPITEFUL_NPC_ID then
            if ONLY_ON_ME then
                unitframe.Spiteful:SetShown(unitframe.data.targetName == PlayerData.Name);
            else
                unitframe.Spiteful:SetShown(true);
            end
        else
            unitframe.Spiteful:SetShown(false);
        end
    end
end

local function OnUpdate(unitframe)
    if not unitframe.Spiteful then
        return;
    end

    local name = UnitName(unitframe.data.unit .. 'target');

    if not unitframe.data.targetName or (name and name == PlayerData.Name) then
        Update(unitframe);
    end

    if unitframe.data.targetName ~= name then
        unitframe.data.targetName = name;
        Update(unitframe);
    end
end

local function Reset(unitframe)
    if unitframe.Spiteful then
        unitframe.Spiteful:SetShown(false);
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
    ENABLED    = O.db.spiteful_enabled;
    ONLY_ON_ME = O.db.spiteful_show_only_on_me;

    if ENABLED then
        Stripes.Updater:Add('MythicPlusSpiteful', OnUpdate);
    else
        Stripes.Updater:Remove('MythicPlusSpiteful');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
end