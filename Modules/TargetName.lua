local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('TargetName');
local Stripes = S:GetNameplateModule('Handler');

-- WoW API
local UnitName, UnitExists, UnitGroupRolesAssigned = UnitName, UnitExists, UnitGroupRolesAssigned;

-- Stripes API
local S_ShouldShowName, S_GetCachedName = Stripes.ShouldShowName, Stripes.GetCachedName;
local U_GetUnitColor = U.GetUnitColor;

-- Local Config
local ENABLED, ONLY_ENEMY, NOT_ME, ROLE_ICON;

local playerData = D.Player;

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

    if not ENABLED or not unitframe.data.targetName or unitframe.data.isUnimportantUnit or not S_ShouldShowName(unitframe) or unitframe.data.widgetsOnly or unitframe.data.isPersonal or (ONLY_ENEMY and unitframe.data.commonReaction == 'FRIENDLY') then
        unitframe.TargetName:Hide();
        return;
    end

    if unitframe.data.targetName == playerData.Name then
        if NOT_ME then
            unitframe.TargetName:SetText('');
        else
            local roleIconText = ROLE_ICON and partyRolesCache[playerData.Name] and ('» ' .. partyRolesCache[playerData.Name] .. ' ' .. YOU) or ('» ' .. YOU);
            unitframe.TargetName:SetText(roleIconText);
            unitframe.TargetName:SetTextColor(1, 0.2, 0.2);
        end
    else
        local useTranslit, useReplaceDiacritics, useCut = true, true, true;
        local targetName = S_GetCachedName(unitframe.data.targetName, useTranslit, useReplaceDiacritics, useCut);
        local roleIconText = ROLE_ICON and partyRolesCache[unitframe.data.targetName] and ('» ' .. partyRolesCache[unitframe.data.targetName] .. ' ' .. targetName) or ('» ' .. targetName);
        unitframe.TargetName:SetText(roleIconText);
        unitframe.TargetName:SetTextColor(U_GetUnitColor(unitframe.data.unit .. 'target', 2));
    end

    unitframe.TargetName:Show();
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

    local targetName = unitframe:CreateFontString(nil, 'OVERLAY', 'StripesNameFont');
    PixelUtil.SetPoint(targetName, 'LEFT', unitframe.name, 'RIGHT', 2, 0);
    targetName:SetDrawLayer('OVERLAY', 7);
    targetName:SetTextColor(1, 1, 1, 1);
    targetName:Hide();

    unitframe.TargetName = targetName;
end

local function Update(unitframe)
    if Stripes.NameOnly:IsActive(unitframe) then
        unitframe.TargetName:SetParent(unitframe);
    else
        unitframe.TargetName:SetParent(unitframe.HealthBarsContainer.healthBar);
    end
end

local function Reset(unitframe)
    if unitframe.TargetName then
        unitframe.TargetName:SetText('');
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    Reset(unitframe);
    TargetChanged(unitframe);
end

function Module:UnitRemoved(unitframe)
    Reset(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
    Reset(unitframe);
    TargetChanged(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED    = O.db.target_name_enabled;
    ONLY_ENEMY = O.db.target_name_only_enemy;
    NOT_ME     = O.db.target_name_not_me;
    ROLE_ICON  = O.db.target_name_role_icon;

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
    partyRolesCache[playerData.Name] = ROLE_ICONS[role] or '';

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
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', function(unitframe)
        Update(unitframe);
        TargetChanged(unitframe);
    end);
end