local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('HealthBar');

-- Lua API
local unpack = unpack;

-- WoW API
local UnitIsConnected, UnitClass, UnitIsFriend, UnitSelectionColor, UnitDetailedThreatSituation, UnitThreatPercentageOfLead, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned =
      UnitIsConnected, UnitClass, UnitIsFriend, UnitSelectionColor, UnitDetailedThreatSituation, UnitThreatPercentageOfLead, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned;
local CompactUnitFrame_IsTapDenied, CompactUnitFrame_IsOnThreatListWithPlayer = CompactUnitFrame_IsTapDenied, CompactUnitFrame_IsOnThreatListWithPlayer;

-- Stripes API
local UnitIsTapped, IsPlayer, IsPlayerEffectivelyTank = U.UnitIsTapped, U.IsPlayer, U.IsPlayerEffectivelyTank;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Libraries
local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start, LCG_PixelGlow_Stop = LCG.PixelGlow_Start, LCG.PixelGlow_Stop;

local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_STATUSBAR = LSM.MediaType.STATUSBAR;

-- Local Config
local AURAS_HPBAR_COLOR_ENABLED;
local THREAT_ENABLED, CUSTOM_HP_ENABLED, CUSTOM_HP_DATA;
local EXECUTION_ENABLED, EXECUTION_COLOR, EXECUTION_GLOW, EXECUTION_LOW_PERCENT, EXECUTION_HIGH_ENABLED, EXECUTION_HIGH_PERCENT;
local HEALTH_BAR_CLASS_COLOR_ENEMY, HEALTH_BAR_CLASS_COLOR_FRIENDLY;
local HEALTH_BAR_TEXTURE, BORDER_HIDE, BORDER_THIN;
local SHOW_CLICKABLE_AREA, ENEMY_MINUS_HEIGHT, ENEMY_HEIGHT, FRIENDLY_HEIGHT, PLAYER_HEIGHT;
local TP_ENABLED, TP_COLORING, TP_POINT, TP_RELATIVE_POINT, TP_OFFSET_X, TP_OFFSET_Y;

local StripesThreatPercentageFont = CreateFont('StripesThreatPercentageFont');

local DEFAULT_STATUSBAR_TEXTURE = 'Interface\\TargetingFrame\\UI-TargetingFrame-BarFill';

Module.defaultStatusColors = {
    [0] = { 1.00, 0.00, 0.00, 1 },  -- not tanking, lower threat than tank. (red)
    [1] = { 0.75, 0.70, 0.15, 1 },  -- not tanking, higher threat than tank. (yellow)
    [2] = { 1.00, 0.35, 0.10, 1 },  -- insecurely tanking, another unit have higher threat but not tanking. (orange)
    [3] = { 0.15, 0.75, 0.15, 1 },  -- securely tanking, highest threat (green)
};

Module.defaultOffTankColor = { 0.60, 0.00, 0.85 };

local statusColors = {
    [0] = { 1.00, 0.00, 0.00, 1 },  -- not tanking, lower threat than tank. (red)
    [1] = { 0.75, 0.70, 0.15, 1 },  -- not tanking, higher threat than tank. (yellow)
    [2] = { 1.00, 0.35, 0.10, 1 },  -- insecurely tanking, another unit have higher threat but not tanking. (orange)
    [3] = { 0.15, 0.75, 0.15, 1 },  -- securely tanking, highest threat (green)
};

local offTankColor = { 0.60, 0.00, 0.85 };
local petTankColor = { 0.00, 0.44, 1.00 };

local PLAYER_IS_TANK = false;

local PLAYER_UNIT = 'player';

local function IsUseClassColor(unitframe)
    if unitframe.data.unitType == 'ENEMY_PLAYER' and HEALTH_BAR_CLASS_COLOR_ENEMY then
        return true;
    end

    if unitframe.data.unitType == 'FRIENDLY_PLAYER' and HEALTH_BAR_CLASS_COLOR_FRIENDLY then
        return true;
    end

    return false;
end

local function UpdateHealthColor(frame)
    local r, g, b;

    if not UnitIsConnected(frame.displayedUnit) then
        r, g, b = 0.5, 0.5, 0.5;
    else
        if frame.optionTable.healthBarColorOverride then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
        else
            local _, englishClass = UnitClass(frame.displayedUnit);
            local classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[englishClass];
            if (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.displayedUnit) or UnitTreatAsPlayerForDisplay(frame.displayedUnit)) and classColor and frame.optionTable.useClassColors and IsUseClassColor(frame) then
                r, g, b = classColor.r, classColor.g, classColor.b;
            elseif CompactUnitFrame_IsTapDenied(frame) then
                r, g, b = 0.9, 0.9, 0.9;
            elseif frame.optionTable.colorHealthBySelection then
                if frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) then
                    r, g, b = 1.0, 0.0, 0.0;
                elseif UnitIsPlayer(frame.displayedUnit) and UnitIsFriend(PLAYER_UNIT, frame.displayedUnit) then
                    r, g, b = 0.667, 0.667, 1.0;
                else
                    r, g, b = UnitSelectionColor(frame.displayedUnit, frame.optionTable.colorHealthWithExtendedColors);
                end
            elseif UnitIsFriend(PLAYER_UNIT, frame.displayedUnit) then
                r, g, b = 0.0, 1.0, 0.0;
            else
                r, g, b = 1.0, 0.0, 0.0;
            end
        end
    end

    local cR, cG, cB = frame.healthBar:GetStatusBarColor();
    if ( r ~= cR or g ~= cG or b ~= cB ) then
        frame.healthBar:SetStatusBarColor(r, g, b);

        if frame.optionTable.colorHealthWithExtendedColors then
            frame.selectionHighlight:SetVertexColor(r, g, b);
        else
            frame.selectionHighlight:SetVertexColor(1, 1, 1);
        end
    end
end

-- Execution
local function Execution_Start(unitframe)
    unitframe.healthBar:SetStatusBarColor(unpack(EXECUTION_COLOR));

    if EXECUTION_GLOW then
        LCG_PixelGlow_Stop(unitframe.healthBar, 'S_EXECUTION');
        LCG_PixelGlow_Start(unitframe.healthBar, nil, 16, nil, 6, nil, 1, 1, nil, 'S_EXECUTION');
    end
end

local function Execution_Stop(unitframe)
    LCG_PixelGlow_Stop(unitframe.healthBar, 'S_EXECUTION');
end

-- Custom Health Bar Color
local function CustomHealthBar_CheckNPC(npcId)
    if not CUSTOM_HP_ENABLED then
        return false;
    end

    if npcId and CUSTOM_HP_DATA[npcId] and CUSTOM_HP_DATA[npcId].enabled then
        return true;
    end

    return false;
end

local function CustomHealthBar_UpdateColor(unitframe)
    unitframe.healthBar:SetStatusBarColor(unpack(CUSTOM_HP_DATA[unitframe.data.npcId].color));
end

-- Threat
local function CreateThreatPercentage(unitframe)
    if unitframe.ThreatPercentage then
        return;
    end

    local frame = CreateFrame('Frame', '$parentThreatPercentage', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'BACKGROUND', 'StripesThreatPercentageFont');
    PixelUtil.SetPoint(frame.text, TP_POINT, frame, TP_RELATIVE_POINT, TP_OFFSET_X, TP_OFFSET_Y);
    frame.text:SetTextColor(1, 1, 1, 1);

    unitframe.ThreatPercentage = frame;
end

local function UpdateThreatPercentage(unitframe, value, r, g, b, a)
    if not TP_ENABLED or not value then
        unitframe.ThreatPercentage.text:SetText('');
        return;
    end

    unitframe.ThreatPercentage.text:SetText(string.format('%s%%', value));

    if TP_COLORING then
        unitframe.ThreatPercentage.text:SetTextColor(r, g, b, a or 1);
    else
        unitframe.ThreatPercentage.text:SetTextColor(1, 1, 1, 1);
    end
end

local function UpdateThreatPercentagePosition(unitframe)
    unitframe.ThreatPercentage.text:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.ThreatPercentage.text, TP_POINT, unitframe.ThreatPercentage, TP_RELATIVE_POINT, TP_OFFSET_X, TP_OFFSET_Y);
end

local function Threat_GetThreatSituationStatus(unit)
    local isTanking, status, threatpct = UnitDetailedThreatSituation(PLAYER_UNIT, unit);
    local display = threatpct;

    if isTanking then
        local lead = UnitThreatPercentageOfLead(PLAYER_UNIT, unit);
        display = lead == 0 and 100 or lead;
    end

    return display, status;
end

local function Threat_UpdateColor(unitframe)
    if not THREAT_ENABLED then
        return;
    end

    local display, status = Threat_GetThreatSituationStatus(unitframe.data.unit);
    local offTank, petTank = false, false;

    if not status or status < 3 then
        local tank_unit = unitframe.data.unit .. 'target';
        if UnitExists(tank_unit) and not UnitIsUnit(tank_unit, PLAYER_UNIT) then
            if (UnitInParty(tank_unit) or UnitInRaid(tank_unit)) and UnitGroupRolesAssigned(tank_unit) == 'TANK' then
                -- group tank
                offTank = true;
            elseif not UnitIsPlayer(tank_unit) and UnitPlayerControlled(tank_unit) then
                -- player controlled npc (pet, vehicle, totem)
                petTank = true;
            end
        end
    end

    if display and not IsPlayer(unitframe.data.unit) then
        local r, g, b, a;
        if PLAYER_IS_TANK and offTank then
            r, g, b, a = unpack(offTankColor);
        elseif petTank then
            r, g, b, a = unpack(petTankColor);
        else
            r, g, b, a = unpack(statusColors[status]);
        end

        if UnitIsTapped(unitframe.data.unit) then
            unitframe.healthBar.border:SetVertexColor(r, g, b, a);
        else
            unitframe.healthBar:SetStatusBarColor(r, g, b, a);
        end

        UpdateThreatPercentage(unitframe, display, r, g, b, a);
    end
end

local function GetAuraColor(unit)
    local spellId;

    for i = 1, BUFF_MAX_DISPLAY do
        spellId = select(10, UnitAura(unit, i, 'PLAYER HARMFUL'));

        if not spellId then
            return false;
        end

        if O.db.auras_hpbar_color_data[spellId] and O.db.auras_hpbar_color_data[spellId].enabled then
            return unpack(O.db.auras_hpbar_color_data[spellId].color);
        end
    end

    return false;
end

local function Auras_UpdateColor(unitframe)
    if not AURAS_HPBAR_COLOR_ENABLED then
        return;
    end

    local r, g, b, a = GetAuraColor(unitframe.data.unit);

    if not r then
        return;
    end

    unitframe.healthBar:SetStatusBarColor(r, g, b, a or 1);

    return true;
end

local function Update(unitframe)
    if unitframe.data.unitType == 'SELF' then
        return;
    end

    if unitframe:IsShown() then
        UpdateHealthColor(unitframe);
        Execution_Stop(unitframe);

        if Auras_UpdateColor(unitframe) then
            return;
        end

        if EXECUTION_ENABLED and (unitframe.data.healthPer <= EXECUTION_LOW_PERCENT or (EXECUTION_HIGH_ENABLED and unitframe.data.healthPer >= EXECUTION_HIGH_PERCENT)) then
            Execution_Start(unitframe);
        else
            if CustomHealthBar_CheckNPC(unitframe.data.npcId) then
                CustomHealthBar_UpdateColor(unitframe);
            else
                Threat_UpdateColor(unitframe);
            end
        end
    end
end

local function UpdateBorder(unitframe)
    if BORDER_HIDE then
        if unitframe.data.unitType == 'SELF' then
            unitframe.healthBar.border:SetVertexColor(0, 0, 0);
        else
            unitframe.healthBar.border:SetVertexColor(unitframe.healthBar:GetStatusBarTexture():GetVertexColor());
        end
    end
end

local function UpdateBorderSizes(unitframe)
    local borderSize, minPixels;

    if BORDER_THIN and unitframe.data.unitType ~= 'SELF' then
        borderSize, minPixels = 1, 1;
    else
        borderSize, minPixels = 1, 2;
    end

    PixelUtil.SetWidth(unitframe.healthBar.border.Left, borderSize, minPixels);
    PixelUtil.SetPoint(unitframe.healthBar.border.Left, 'TOPRIGHT', unitframe.healthBar.border, 'TOPLEFT', 0, borderSize, 0, minPixels);
    PixelUtil.SetPoint(unitframe.healthBar.border.Left, 'BOTTOMRIGHT', unitframe.healthBar.border, 'BOTTOMLEFT', 0, -borderSize, 0, minPixels);

    PixelUtil.SetWidth(unitframe.healthBar.border.Right, borderSize, minPixels);
    PixelUtil.SetPoint(unitframe.healthBar.border.Right, 'TOPLEFT', unitframe.healthBar.border, 'TOPRIGHT', 0, borderSize, 0, minPixels);
    PixelUtil.SetPoint(unitframe.healthBar.border.Right, 'BOTTOMLEFT', unitframe.healthBar.border, 'BOTTOMRIGHT', 0, -borderSize, 0, minPixels);

    PixelUtil.SetHeight(unitframe.healthBar.border.Bottom, borderSize, minPixels);
    PixelUtil.SetPoint(unitframe.healthBar.border.Bottom, 'TOPLEFT', unitframe.healthBar.border, 'BOTTOMLEFT', 0, 0);
    PixelUtil.SetPoint(unitframe.healthBar.border.Bottom, 'TOPRIGHT', unitframe.healthBar.border, 'BOTTOMRIGHT', 0, 0);

    if unitframe.healthBar.border.Top then
        PixelUtil.SetHeight(unitframe.healthBar.border.Top, borderSize, minPixels);
        PixelUtil.SetPoint(unitframe.healthBar.border.Top, 'BOTTOMLEFT', unitframe.healthBar.border, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(unitframe.healthBar.border.Top, 'BOTTOMRIGHT', unitframe.healthBar.border, 'TOPRIGHT', 0, 0);
    end

    if unitframe.data.unitType == 'SELF' and unitframe.powerBar and unitframe.powerBar:IsShown() then
        PixelUtil.SetWidth(unitframe.powerBar.border.Left, borderSize, minPixels);
        PixelUtil.SetPoint(unitframe.powerBar.border.Left, 'TOPRIGHT', unitframe.powerBar.border, 'TOPLEFT', 0, borderSize, 0, minPixels);
        PixelUtil.SetPoint(unitframe.powerBar.border.Left, 'BOTTOMRIGHT', unitframe.powerBar.border, 'BOTTOMLEFT', 0, -borderSize, 0, minPixels);

        PixelUtil.SetWidth(unitframe.powerBar.border.Right, borderSize, minPixels);
        PixelUtil.SetPoint(unitframe.powerBar.border.Right, 'TOPLEFT', unitframe.powerBar.border, 'TOPRIGHT', 0, borderSize, 0, minPixels);
        PixelUtil.SetPoint(unitframe.powerBar.border.Right, 'BOTTOMLEFT', unitframe.powerBar.border, 'BOTTOMRIGHT', 0, -borderSize, 0, minPixels);

        PixelUtil.SetHeight(unitframe.powerBar.border.Bottom, borderSize, minPixels);
        PixelUtil.SetPoint(unitframe.powerBar.border.Bottom, 'TOPLEFT', unitframe.powerBar.border, 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(unitframe.powerBar.border.Bottom, 'TOPRIGHT', unitframe.powerBar.border, 'BOTTOMRIGHT', 0, 0);

        if unitframe.powerBar.border.Top then
            PixelUtil.SetHeight(unitframe.powerBar.border.Top, borderSize, minPixels);
            PixelUtil.SetPoint(unitframe.powerBar.border.Top, 'BOTTOMLEFT', unitframe.powerBar.border, 'TOPLEFT', 0, 0);
            PixelUtil.SetPoint(unitframe.powerBar.border.Top, 'BOTTOMRIGHT', unitframe.powerBar.border, 'TOPRIGHT', 0, 0);
        end
    end
end

local function UpdateSizes(unitframe)
    if unitframe.data.unitType == 'SELF' then
        unitframe.healthBar:SetHeight(PLAYER_HEIGHT);

        if unitframe.powerBar and unitframe.powerBar:IsShown() then
            unitframe.powerBar:SetHeight(PLAYER_HEIGHT);
        end

        if ClassNameplateManaBarFrame and ClassNameplateManaBarFrame:IsShown() then
            PixelUtil.SetHeight(ClassNameplateManaBarFrame, PLAYER_HEIGHT);
        end
    elseif unitframe.data.commonReaction == 'ENEMY' then
        if unitframe.data.minus then
            unitframe.healthBar:SetHeight(ENEMY_MINUS_HEIGHT);
            unitframe.healthBar.sHeight = ENEMY_MINUS_HEIGHT;
        else
            unitframe.healthBar:SetHeight(ENEMY_HEIGHT);
            unitframe.healthBar.sHeight = ENEMY_HEIGHT;
        end
    elseif unitframe.data.commonReaction == 'FRIENDLY' then
        unitframe.healthBar:SetHeight(FRIENDLY_HEIGHT);
        unitframe.healthBar.sHeight = FRIENDLY_HEIGHT;
    end

    UpdateBorderSizes(unitframe);
end

local function UpdateClickableArea(unitframe)
    if not SHOW_CLICKABLE_AREA or unitframe.data.unitType == 'SELF' then
        if unitframe.ClickableArea then
            unitframe.ClickableArea:SetShown(false);
        end

        return;
    end

    if not unitframe.ClickableArea then
        unitframe.ClickableArea = CreateFrame('Frame', nil, unitframe);

        unitframe.ClickableArea.background = unitframe.ClickableArea:CreateTexture(nil, 'BACKGROUND', nil, -7);
        unitframe.ClickableArea.background:SetTexture('Interface\\Buttons\\WHITE8x8');
        unitframe.ClickableArea.background:SetAllPoints(unitframe.ClickableArea);
        unitframe.ClickableArea.background:SetVertexColor(1, 1, 1, 0.3);

        unitframe.ClickableArea.border = unitframe.ClickableArea:CreateTexture(nil, 'BACKGROUND', nil, -8);
        unitframe.ClickableArea.border:SetTexture('Interface\\Buttons\\WHITE8x8');
        unitframe.ClickableArea.border:SetPoint('TOPLEFT', unitframe.ClickableArea, 'TOPLEFT', -2, 2);
        unitframe.ClickableArea.border:SetPoint('BOTTOMRIGHT', unitframe.ClickableArea, 'BOTTOMRIGHT', 2, -2);
        unitframe.ClickableArea.border:SetVertexColor(0.3, 0.3, 0.3, 0.8);

        unitframe.ClickableArea:SetPoint('CENTER');
    end

    if unitframe.data.commonReaction == 'ENEMY' then
        if unitframe.data.canAttack then
            unitframe.ClickableArea:SetSize(C_NamePlate.GetNamePlateEnemySize());
        else
            unitframe.ClickableArea:SetSize(C_NamePlate.GetNamePlateFriendlySize());
        end
    elseif unitframe.data.commonReaction == 'FRIENDLY' then
        unitframe.ClickableArea:SetSize(C_NamePlate.GetNamePlateFriendlySize());
    end

    unitframe.ClickableArea:SetShown(true);
end

local function UpdateTexture(unitframe)
    if unitframe.data.unitType == 'SELF' then
        unitframe.healthBar:SetStatusBarTexture(DEFAULT_STATUSBAR_TEXTURE);
    else
        unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, HEALTH_BAR_TEXTURE));
    end
end

function Module:UnitAdded(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.healthBar:SetFrameStrata(unitframe.data.unitType == 'SELF' and 'HIGH' or 'MEDIUM');

    CreateThreatPercentage(unitframe);
    UpdateThreatPercentage(unitframe);

    Update(unitframe);
    UpdateTexture(unitframe);
    UpdateSizes(unitframe);
    UpdateClickableArea(unitframe);
end

function Module:Update(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.healthBar:SetFrameStrata(unitframe.data.unitType == 'SELF' and 'HIGH' or 'MEDIUM');

    UpdateThreatPercentagePosition(unitframe);

    Update(unitframe);
    UpdateTexture(unitframe);
    UpdateSizes(unitframe);
    UpdateClickableArea(unitframe);
end

function Module:UpdateLocalConfig()
    AURAS_HPBAR_COLOR_ENABLED = O.db.auras_hpbar_color_enabled;

    THREAT_ENABLED = O.db.threat_color_enabled;

    if not O.db.threat_color_reversed then
        statusColors[0] = O.db.threat_color_status_0;
        statusColors[1] = O.db.threat_color_status_1;
        statusColors[2] = O.db.threat_color_status_2;
        statusColors[3] = O.db.threat_color_status_3;
    else
        statusColors[0] = O.db.threat_color_status_3;
        statusColors[1] = O.db.threat_color_status_1;
        statusColors[2] = O.db.threat_color_status_2;
        statusColors[3] = O.db.threat_color_status_0;
    end

    offTankColor[1] = O.db.threat_color_offtank[1];
    offTankColor[2] = O.db.threat_color_offtank[2];
    offTankColor[3] = O.db.threat_color_offtank[3];
    offTankColor[4] = O.db.threat_color_offtank[4] or 1;

    petTankColor[1] = O.db.threat_color_pettank[1];
    petTankColor[2] = O.db.threat_color_pettank[2];
    petTankColor[3] = O.db.threat_color_pettank[3];
    petTankColor[4] = O.db.threat_color_pettank[4] or 1;

    TP_ENABLED        = O.db.threat_percentage_enabled;
    TP_COLORING       = O.db.threat_percentage_coloring;
    TP_POINT          = O.Lists.frame_points[O.db.threat_percentage_point] or 'TOPLEFT';
    TP_RELATIVE_POINT = O.Lists.frame_points[O.db.threat_percentage_relative_point] or 'BOTTOMLEFT';
    TP_OFFSET_X       = O.db.threat_percentage_offset_x;
    TP_OFFSET_Y       = O.db.threat_percentage_offset_y;
    UpdateFontObject(StripesThreatPercentageFont, O.db.threat_percentage_font_value, O.db.threat_percentage_font_size, O.db.threat_percentage_font_flag, O.db.threat_percentage_font_shadow);

    CUSTOM_HP_ENABLED = O.db.custom_color_enabled;
    CUSTOM_HP_DATA    = O.db.custom_color_data;

    EXECUTION_ENABLED      = O.db.execution_enabled;
    EXECUTION_COLOR        = EXECUTION_COLOR or {};
    EXECUTION_COLOR[1]     = O.db.execution_color[1];
    EXECUTION_COLOR[2]     = O.db.execution_color[2];
    EXECUTION_COLOR[3]     = O.db.execution_color[3];
    EXECUTION_COLOR[4]     = O.db.execution_color[4] or 1;
    EXECUTION_GLOW         = O.db.execution_glow;
    EXECUTION_LOW_PERCENT  = O.db.execution_low_percent;
    EXECUTION_HIGH_ENABLED = O.db.execution_high_enabled;
    EXECUTION_HIGH_PERCENT = O.db.execution_high_percent;

    HEALTH_BAR_CLASS_COLOR_ENEMY    = O.db.health_bar_class_color_enemy;
    HEALTH_BAR_CLASS_COLOR_FRIENDLY = O.db.health_bar_class_color_friendly;

    HEALTH_BAR_TEXTURE = O.db.health_bar_texture_value;

    BORDER_HIDE = O.db.health_bar_border_hide;
    BORDER_THIN = O.db.health_bar_border_thin;

    SHOW_CLICKABLE_AREA = O.db.size_clickable_area_show;

    ENEMY_MINUS_HEIGHT = O.db.size_enemy_minus_height;
    ENEMY_HEIGHT       = O.db.size_enemy_height;
    FRIENDLY_HEIGHT    = O.db.size_friendly_height;
    PLAYER_HEIGHT      = O.db.size_self_height;
end

function Module:PLAYER_LOGIN()
    PLAYER_IS_TANK = IsPlayerEffectivelyTank();
end

function Module:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= PLAYER_UNIT then
        return;
    end

    PLAYER_IS_TANK = IsPlayerEffectivelyTank();
end

function Module:ROLE_CHANGED_INFORM(changedName, _, _, newRole)
    if changedName ~= D.Player.Name then
        return;
    end

    PLAYER_IS_TANK = newRole == 'TANK';
end

function Module:PLAYER_ROLES_ASSIGNED()
    PLAYER_IS_TANK = IsPlayerEffectivelyTank();
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
    self:RegisterEvent('ROLE_CHANGED_INFORM');
    self:RegisterEvent('PLAYER_ROLES_ASSIGNED'); -- Just to be sure...

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthColor', Update);
    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', UpdateSizes);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', function(unitframe)
        Update(unitframe);
        UpdateSizes(unitframe);
    end);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthBorder', function(unitframe)
        UpdateBorder(unitframe);
        UpdateSizes(unitframe);
    end);
end