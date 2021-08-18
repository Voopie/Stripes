local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('TargetName');
Module.Updater = CreateFrame('Frame');

-- Lua API
local pairs = pairs;

-- WoW API
local UnitName, UnitExists, UnitGroupRolesAssigned = UnitName, UnitExists, UnitGroupRolesAssigned;

-- Stripes API
local GetUnitColor = U.GetUnitColor;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local ENABLED, ONLY_ENEMY, NOT_ME, ROLE_ICON;

local PlayerName = D.Player.Name;
local YOU = YOU;

local partyCache = {};

local UPDATE_INTERVAL = 0.2;
local elapsed = 0;

local function TargetChanged(unitframe)
    if unitframe.data.widgetsOnly or unitframe.data.unitType == 'SELF' or (ONLY_ENEMY and unitframe.data.commonReaction == 'FRIENDLY') then
        unitframe.TargetName:SetShown(false);
        return;
    end

    if unitframe.data.targetName then
        if unitframe.data.targetName == PlayerName then
            if NOT_ME then
                unitframe.TargetName:SetText('');
            else
                if ROLE_ICON and partyCache[PlayerName] then
                    unitframe.TargetName:SetText('» ' .. partyCache[PlayerName] .. ' ' .. YOU);
                else
                    unitframe.TargetName:SetText('» ' .. YOU);
                end

                unitframe.TargetName:SetTextColor(1, 0.2, 0.2);
            end
        else
            if ROLE_ICON and partyCache[unitframe.data.targetName] then
                unitframe.TargetName:SetText('» ' .. partyCache[unitframe.data.targetName] .. ' '.. unitframe.data.targetName);
            else
                unitframe.TargetName:SetText('» ' .. unitframe.data.targetName);
            end

            unitframe.TargetName:SetTextColor(GetUnitColor(unitframe.data.unit .. 'target', 2));
        end

        unitframe.TargetName:SetShown(true);
    else
        unitframe.TargetName:SetShown(false);
    end
end

local function OnUpdate(_, elap)
    elapsed = elapsed + elap;

    if elapsed >= UPDATE_INTERVAL then
        elapsed = 0;

        for _, unitframe in pairs(NP) do
            if unitframe:IsShown() then
                local name = UnitName(unitframe.data.unit .. 'target');

                if unitframe.data.targetName ~= name then
                    unitframe.data.targetName = name;
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

    unitframe.TargetName = unitframe:CreateFontString(nil, 'OVERLAY', 'StripesNameFont');
    PixelUtil.SetPoint(unitframe.TargetName, 'LEFT', unitframe.name, 'RIGHT', 2, 0);
    unitframe.TargetName:SetTextColor(1, 1, 1, 1);
    unitframe.TargetName:SetShown(false);
end

local function Reset(unitframe)
    if unitframe.TargetName then
        unitframe.TargetName:SetText('');
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
    ROLE_ICON  = O.db.target_name_role_icon;

    Module.Updater:SetScript('OnUpdate', ENABLED and OnUpdate or nil);
end

function Module:UpdatePartyCache()
    wipe(partyCache);

    -- Player role
    local spec = GetSpecialization();
    local role = spec and GetSpecializationRole(spec) or '';
    partyCache[PlayerName] = _G['INLINE_' .. role .. '_ICON'] or '';

    local unit;

    -- Party roles
    if not IsInRaid() and IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            unit = 'party' .. i;

            if UnitExists(unit) then
                partyCache[UnitName(unit)] = _G['INLINE_' .. (UnitGroupRolesAssigned(unit) or '') .. '_ICON'] or '';
            end
        end
    end

    -- Raid roles
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            unit = 'raid' .. i;

            if UnitExists(unit) then
                partyCache[UnitName(unit)] = _G['INLINE_' .. (UnitGroupRolesAssigned(unit) or '') .. '_ICON'] or '';
            end
        end
    end
end

function Module:PLAYER_LOGIN()
    self:UpdatePartyCache();
end

function Module:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= 'player' then
        return;
    end

    local spec = GetSpecialization();
    local role = spec and GetSpecializationRole(spec);
    partyCache[UnitName(unit)] = _G['INLINE_' .. role .. '_ICON'] or '';
end

function Module:GROUP_ROSTER_UPDATE()
    self:UpdatePartyCache();
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
    self:RegisterEvent('GROUP_ROSTER_UPDATE');
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', TargetChanged);
end