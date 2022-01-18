local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('TargetName');
local Stripes = S:GetNameplateModule('Handler');

-- WoW API
local UnitName, UnitExists, UnitGroupRolesAssigned = UnitName, UnitExists, UnitGroupRolesAssigned;

-- Stripes API
local GetUnitColor = U.GetUnitColor;
local ShouldShowName = Stripes.ShouldShowName;

-- Libraries
local LT = S.Libraries.LT;
local LDC = S.Libraries.LDC;

-- Local Config
local ENABLED, ONLY_ENEMY, NOT_ME, ROLE_ICON;
local NAME_TRANSLIT, NAME_REPLACE_DIACRITICS;

local PlayerData = D.Player;
local YOU = YOU;

local partyRolesCache = {};
local ROLE_ICONS = {
    ['TANK']    = INLINE_TANK_ICON,
    ['DAMAGER'] = INLINE_DAMAGER_ICON,
    ['HEALER']  = INLINE_HEALER_ICON,
    ['NONE']    = '',
};

local function TargetChanged(unitframe)
    if not unitframe.TargetName then
        return;
    end

    if not ShouldShowName(unitframe) or unitframe.data.widgetsOnly or unitframe.data.unitType == 'SELF' or (ONLY_ENEMY and unitframe.data.commonReaction == 'FRIENDLY') then
        unitframe.TargetName:SetShown(false);
        return;
    end

    if unitframe.data.targetName then
        if unitframe.data.targetName == PlayerData.Name then
            if NOT_ME then
                unitframe.TargetName:SetText('');
            else
                if ROLE_ICON and partyRolesCache[PlayerData.Name] then
                    unitframe.TargetName:SetText('» ' .. partyRolesCache[PlayerData.Name] .. ' ' .. YOU);
                else
                    unitframe.TargetName:SetText('» ' .. YOU);
                end

                unitframe.TargetName:SetTextColor(1, 0.2, 0.2);
            end
        else
            local targetName = unitframe.data.targetName;

            if NAME_TRANSLIT then
                targetName = LT:Transliterate(targetName);
            end

            if NAME_REPLACE_DIACRITICS then
                targetName = LDC:Replace(targetName);
            end

            if ROLE_ICON and partyRolesCache[unitframe.data.targetName] then
                unitframe.TargetName:SetText('» ' .. partyRolesCache[unitframe.data.targetName] .. ' '.. targetName);
            else
                unitframe.TargetName:SetText('» ' .. targetName);
            end

            unitframe.TargetName:SetTextColor(GetUnitColor(unitframe.data.unit .. 'target', 2));
        end

        unitframe.TargetName:SetShown(true);
    else
        unitframe.TargetName:SetShown(false);
    end
end

local function OnUpdate(unitframe)
    if not unitframe.TargetName then
        return;
    end

    local name = UnitName(unitframe.data.unit .. 'target');

    if unitframe.data.targetName ~= name then
        unitframe.data.targetName = name;
        TargetChanged(unitframe);
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

    NAME_TRANSLIT           = O.db.name_text_translit;
    NAME_REPLACE_DIACRITICS = O.db.name_text_replace_diacritics;

    if ENABLED then
        Stripes.Updater:Add('TargetName', OnUpdate);
    else
        Stripes.Updater:Remove('TargetName');
    end
end

function Module:UpdatePartyCache()
    wipe(partyRolesCache);

    -- Player role
    local spec = GetSpecialization();
    local role = spec and GetSpecializationRole(spec) or '';
    partyRolesCache[PlayerData.Name] = ROLE_ICONS[role] or '';

    local unit;

    -- Party roles
    if not IsInRaid() and IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            unit = 'party' .. i;

            if UnitExists(unit) then
                partyRolesCache[UnitName(unit)] = ROLE_ICONS[UnitGroupRolesAssigned(unit) or ''] or '';
            end
        end
    end

    -- Raid roles
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            unit = 'raid' .. i;

            if UnitExists(unit) then
                partyRolesCache[UnitName(unit)] = ROLE_ICONS[UnitGroupRolesAssigned(unit) or ''] or '';
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
    partyRolesCache[UnitName(unit)] = ROLE_ICONS[role] or '';
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