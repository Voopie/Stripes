local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('TargetName');
Module.Updater = CreateFrame('Frame');

-- Lua API
local pairs = pairs;

-- WoW API
local UnitName = UnitName;

-- Stripes API
local GetUnitColor = U.GetUnitColor;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local ENABLED, ONLY_ENEMY, NOT_ME;

local PlayerName = D.Player.Name;
local YOU = YOU;

local UPDATE_INTERVAL = 0.2;
local elapsed = 0;

local function TargetChanged(unitframe)
    if unitframe.data.widgetsOnly or unitframe.data.unitType == 'SELF' or (ONLY_ENEMY and unitframe.data.commonReaction == 'FRIENDLY') then
        unitframe.TargetName.text:SetShown(false);
        return;
    end

    if unitframe.TargetName.targetName then
        if unitframe.TargetName.targetName == PlayerName then
            if NOT_ME then
                unitframe.TargetName.text:SetText('');
            else
                unitframe.TargetName.text:SetText('»  ' .. YOU);
                unitframe.TargetName.text:SetTextColor(1, 0.2, 0.2);
            end
        else
            unitframe.TargetName.text:SetText('»  ' .. unitframe.TargetName.targetName);
            unitframe.TargetName.text:SetTextColor(GetUnitColor(unitframe.data.unit .. 'target', 2));
        end

        unitframe.TargetName.text:SetShown(true);
    else
        unitframe.TargetName.text:SetShown(false);
    end
end

local function OnUpdate(_, elap)
    elapsed = elapsed + elap;

    if elapsed >= UPDATE_INTERVAL then
        elapsed = 0;

        for _, unitframe in pairs(NP) do
            if unitframe:IsShown() then
                local name = UnitName(unitframe.data.unit .. 'target');

                if unitframe.TargetName.targetName ~= name then
                    unitframe.TargetName.targetName = name;
                    TargetChanged(unitframe);
                end
            end
        end
    end
end

local function Create(unitframe)
    if unitframe.TargetName then
        return;
    end

    local text = unitframe:CreateFontString(nil, 'OVERLAY', 'StripesNameFont');
    PixelUtil.SetPoint(text, 'LEFT', unitframe.name, 'RIGHT', 2, 0);
    text:SetTextColor(1, 1, 1);

    unitframe.TargetName = {
        text       = text,
        targetName = UnitName(unitframe.data.unit .. 'target'),
    };
end

local function Reset(unitframe)
    if unitframe.TargetName then
        unitframe.TargetName.text:SetText('');
        unitframe.TargetName.targetName = nil;
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Reset(unitframe);
    TargetChanged(unitframe);
end

function Module:UnitRemoved(unitframe)
    Reset(unitframe);
end

function Module:Update(unitframe)
    Reset(unitframe);
    TargetChanged(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED    = O.db.target_name_enabled;
    ONLY_ENEMY = O.db.target_name_only_enemy;
    NOT_ME     = O.db.target_name_not_me;

    Module.Updater:SetScript('OnUpdate', ENABLED and OnUpdate or nil);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', function(unitframe)
        TargetChanged(unitframe);
    end);
end