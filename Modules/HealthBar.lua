local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('HealthBar');

-- Lua API
local unpack = unpack;

-- WoW API
local UnitIsConnected, UnitClass, UnitIsFriend, UnitSelectionType, UnitSelectionColor, UnitDetailedThreatSituation, UnitThreatPercentageOfLead, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned =
      UnitIsConnected, UnitClass, UnitIsFriend, UnitSelectionType, UnitSelectionColor, UnitDetailedThreatSituation, UnitThreatPercentageOfLead, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned;
local CompactUnitFrame_IsTapDenied, CompactUnitFrame_IsOnThreatListWithPlayer = CompactUnitFrame_IsTapDenied, CompactUnitFrame_IsOnThreatListWithPlayer;
local GetRaidTargetIndex = GetRaidTargetIndex;
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;

-- Stripes API
local UnitIsTapped, IsPlayer, IsPlayerEffectivelyTank = U.UnitIsTapped, U.IsPlayer, U.IsPlayerEffectivelyTank;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Libraries
local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start, LCG_PixelGlow_Stop = LCG.PixelGlow_Start, LCG.PixelGlow_Stop;

local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_STATUSBAR = LSM.MediaType.STATUSBAR;

-- Nameplates frames
local NP = S.NamePlates;

-- Local Config
local RAID_TARGET_HPBAR_COLORING, AURAS_HPBAR_COLORING;
local THREAT_ENABLED, THREAT_COLOR_ISTAPPED_BORDER, CUSTOM_HP_ENABLED, CUSTOM_HP_DATA;
local EXECUTION_ENABLED, EXECUTION_COLOR, EXECUTION_GLOW, EXECUTION_LOW_PERCENT, EXECUTION_HIGH_ENABLED, EXECUTION_HIGH_PERCENT;
local HEALTH_BAR_CLASS_COLOR_ENEMY, HEALTH_BAR_CLASS_COLOR_FRIENDLY;
local HEALTH_BAR_TEXTURE, BORDER_SIZE, BORDER_HIDE, BORDER_COLOR, BORDER_SELECTED_COLOR, SAME_BORDER_COLOR;
local SHOW_CLICKABLE_AREA, ENEMY_MINUS_HEIGHT, ENEMY_HEIGHT, FRIENDLY_HEIGHT, PLAYER_HEIGHT;
local TP_ENABLED, TP_COLORING, TP_POINT, TP_RELATIVE_POINT, TP_OFFSET_X, TP_OFFSET_Y;
local HPBAR_COLOR_DC, HPBAR_COLOR_TAPPED, HPBAR_COLOR_ENEMY_NPC, HPBAR_COLOR_ENEMY_PLAYER, HPBAR_COLOR_FRIENDLY_NPC, HPBAR_COLOR_FRIENDLY_PLAYER, HPBAR_COLOR_NEUTRAL;
local CUSTOM_BORDER_ENABLED, CUSTOM_BORDER_PATH, CUSTOM_BORDER_WIDTH, CUSTOM_BORDER_HEIGHT, CUSTOM_BORDER_HEIGHT_MINUS, CUSTOM_BORDER_X_OFFSET, CUSTOM_BORDER_Y_OFFSET;

local StripesThreatPercentageFont = CreateFont('StripesThreatPercentageFont');

local DEFAULT_STATUSBAR_TEXTURE = 'Interface\\TargetingFrame\\UI-TargetingFrame-BarFill';

Module.defaultStatusColors = {
    [0] = { 1.00, 0.00, 0.00, 1 },  -- not tanking, lower threat than tank. (red)
    [1] = { 0.75, 0.70, 0.15, 1 },  -- not tanking, higher threat than tank. (yellow)
    [2] = { 1.00, 0.35, 0.10, 1 },  -- insecurely tanking, another unit have higher threat but not tanking. (orange)
    [3] = { 0.15, 0.75, 0.15, 1 },  -- securely tanking, highest threat (green)
};

Module.defaultOffTankColor = { 0.60, 0.00, 0.85, 1 };

local statusColors = {
    [0] = { 1.00, 0.00, 0.00, 1 },  -- not tanking, lower threat than tank. (red)
    [1] = { 0.75, 0.70, 0.15, 1 },  -- not tanking, higher threat than tank. (yellow)
    [2] = { 1.00, 0.35, 0.10, 1 },  -- insecurely tanking, another unit have higher threat but not tanking. (orange)
    [3] = { 0.15, 0.75, 0.15, 1 },  -- securely tanking, highest threat (green)
};

local offTankColor = { 0.60, 0.00, 0.85, 1 };
local petTankColor = { 0.00, 0.44, 1.00, 1 };

local PLAYER_IS_TANK = false;
local PLAYER_UNIT = 'player';

local RAID_TARGET_COLORS = {
    [1] = {    1,    1,  0.2, 1 }, -- YELLOW (STAR)
    [2] = {    1,  0.5,  0.2, 1 }, -- ORANGE (CIRCLE)
    [3] = {  0.8,  0.2,    1, 1 }, -- PURPLE (DIAMOND)
    [4] = {  0.2,    1, 0.25, 1 }, -- GREEN  (TRIANGLE)
    [5] = { 0.75, 0.85,  0.9, 1 }, -- SILVER (MOON)
    [6] = {  0.2,  0.5,    1, 1 }, -- BLUE   (SQUARE)
    [7] = {    1,  0.2, 0.25, 1 }, -- RED    (CROSS)
    [8] = {    1,    1,    1, 1 }, -- WHITE  (SKULL)
};

--[[
    Coloring prio:
    1) Raid target
    2) Aura
    3) Execution
    4) Custom
    5) Threat
]]

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
    local r, g, b, a;

    if not UnitIsConnected(frame.displayedUnit) then
        r, g, b, a = HPBAR_COLOR_DC[1], HPBAR_COLOR_DC[2], HPBAR_COLOR_DC[3], HPBAR_COLOR_DC[4];
    else
        if frame.optionTable.healthBarColorOverride then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
            r, g, b, a = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b, healthBarColorOverride.a or 1;
        else
            local _, englishClass = UnitClass(frame.displayedUnit);
            local classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[englishClass];
            if (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.displayedUnit) or UnitTreatAsPlayerForDisplay(frame.displayedUnit)) and classColor and frame.optionTable.useClassColors and IsUseClassColor(frame) then
                r, g, b = classColor.r, classColor.g, classColor.b;
            elseif CompactUnitFrame_IsTapDenied(frame) then
                r, g, b, a = HPBAR_COLOR_TAPPED[1], HPBAR_COLOR_TAPPED[2], HPBAR_COLOR_TAPPED[3], HPBAR_COLOR_TAPPED[4];
            elseif frame.optionTable.colorHealthBySelection then
                if frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) then
                    r, g, b, a = HPBAR_COLOR_ENEMY_NPC[1], HPBAR_COLOR_ENEMY_NPC[2], HPBAR_COLOR_ENEMY_NPC[3], HPBAR_COLOR_ENEMY_NPC[4];
                elseif UnitIsPlayer(frame.displayedUnit) and UnitIsFriend(PLAYER_UNIT, frame.displayedUnit) then
                    r, g, b, a = HPBAR_COLOR_FRIENDLY_PLAYER[1], HPBAR_COLOR_FRIENDLY_PLAYER[2], HPBAR_COLOR_FRIENDLY_PLAYER[3], HPBAR_COLOR_FRIENDLY_PLAYER[4];
                else
                    local selectionType = UnitSelectionType(frame.displayedUnit, frame.optionTable.colorHealthWithExtendedColors);
                    if selectionType == 2 then
                        r, g, b, a = HPBAR_COLOR_NEUTRAL[1], HPBAR_COLOR_NEUTRAL[2], HPBAR_COLOR_NEUTRAL[3], HPBAR_COLOR_NEUTRAL[4];
                    else
                        if frame.data.unitType == 'ENEMY_PLAYER' then
                            r, g, b, a = HPBAR_COLOR_ENEMY_PLAYER[1], HPBAR_COLOR_ENEMY_PLAYER[2], HPBAR_COLOR_ENEMY_PLAYER[3], HPBAR_COLOR_ENEMY_PLAYER[4];
                        elseif frame.data.unitType == 'ENEMY_NPC' then
                            r, g, b, a = HPBAR_COLOR_ENEMY_NPC[1], HPBAR_COLOR_ENEMY_NPC[2], HPBAR_COLOR_ENEMY_NPC[3], HPBAR_COLOR_ENEMY_NPC[4];
                        elseif frame.data.unitType == 'FRIENDLY_NPC' then
                            r, g, b, a = HPBAR_COLOR_FRIENDLY_NPC[1], HPBAR_COLOR_FRIENDLY_NPC[2], HPBAR_COLOR_FRIENDLY_NPC[3], HPBAR_COLOR_FRIENDLY_NPC[4];
                        else
                            r, g, b, a = UnitSelectionColor(frame.displayedUnit, frame.optionTable.colorHealthWithExtendedColors);
                        end
                    end
                end
            elseif UnitIsFriend(PLAYER_UNIT, frame.displayedUnit) then
                r, g, b, a = HPBAR_COLOR_FRIENDLY_NPC[1], HPBAR_COLOR_FRIENDLY_NPC[2], HPBAR_COLOR_FRIENDLY_NPC[3], HPBAR_COLOR_FRIENDLY_NPC[4];
            else
                r, g, b, a = HPBAR_COLOR_ENEMY_NPC[1], HPBAR_COLOR_ENEMY_NPC[2], HPBAR_COLOR_ENEMY_NPC[3], HPBAR_COLOR_ENEMY_NPC[4];
            end
        end
    end

    local cR, cG, cB, cA = frame.healthBar:GetStatusBarColor();
    if ( r ~= cR or g ~= cG or b ~= cB or a ~= cA ) then
        frame.healthBar:SetStatusBarColor(r, g, b, a);

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

    unitframe.ThreatPercentage.text:SetText(string.format('%.0f%%', value));

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
            r, g, b, a = offTankColor[1], offTankColor[2], offTankColor[3], offTankColor[4];
        elseif petTank then
            r, g, b, a = petTankColor[1], petTankColor[2], petTankColor[3], petTankColor[4];
        else
            r, g, b, a = statusColors[status][1], statusColors[status][2], statusColors[status][3], statusColors[status][4];
        end

        if UnitIsTapped(unitframe.data.unit) then
            if THREAT_COLOR_ISTAPPED_BORDER then
                unitframe.healthBar.border:SetVertexColor(r, g, b, a);
            end
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

local function UpdateAurasColor(unitframe)
    if not AURAS_HPBAR_COLORING then
        return false;
    end

    if RAID_TARGET_HPBAR_COLORING and unitframe.data.raidIndex then
        return false;
    end

    local r, g, b, a = GetAuraColor(unitframe.data.unit);

    if not r then
        return false;
    end

    unitframe.healthBar:SetStatusBarColor(r, g, b, a or 1);
    unitframe.data.wasAuraColored = true;

    return true;
end

local function UpdateRaidTargetColor(unitframe)
    if not RAID_TARGET_HPBAR_COLORING then
        unitframe.data.raidIndex = nil;
        return false;
    end

    local raidIndex = GetRaidTargetIndex(unitframe.data.unit);

    if not raidIndex then
        unitframe.data.raidIndex = nil;
        return false;
    end

    if RAID_TARGET_COLORS[raidIndex] then
        unitframe.healthBar:SetStatusBarColor(unpack(RAID_TARGET_COLORS[raidIndex]));
        unitframe.data.raidIndex = raidIndex;

        return true;
    end

    return false;
end

local function Update(unitframe)
    if not unitframe:IsShown() or unitframe.data.unitType == 'SELF' then
        return;
    end

    if UpdateRaidTargetColor(unitframe) then
        return;
    end

    unitframe.data.auraColored = UpdateAurasColor(unitframe);

    if unitframe.data.auraColored then
        return;
    end

    UpdateHealthColor(unitframe);
    Execution_Stop(unitframe);

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

local function UpdateBorder(unitframe)
    if BORDER_HIDE then
        if unitframe.data.unitType == 'SELF' then
            unitframe.healthBar.border:SetVertexColor(0, 0, 0);
            unitframe.healthBar.border:Show();
        else
            unitframe.healthBar.border:Hide();
        end

        return;
    end

    unitframe.healthBar.border:Show();

    if SAME_BORDER_COLOR then
        unitframe.healthBar.border:SetVertexColor(unitframe.healthBar:GetStatusBarTexture():GetVertexColor());
        return;
    end

    if UnitIsUnit(unitframe.data.unit, 'target') then
        unitframe.healthBar.border:SetVertexColor(BORDER_SELECTED_COLOR[1], BORDER_SELECTED_COLOR[2], BORDER_SELECTED_COLOR[3], BORDER_SELECTED_COLOR[4]);
        return;
    end

    unitframe.healthBar.border:SetVertexColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
end

local function UpdateBorderSizes(unitframe)
    local borderSize, minPixels = BORDER_SIZE, BORDER_SIZE - 0.5;

    if unitframe.data.unitType == 'SELF' then
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

local function CreateCustomBorder(unitframe)
    if not unitframe.healthBar.CustomBorderTexture then
        unitframe.healthBar.CustomBorderTexture = unitframe.healthBar:CreateTexture(nil, 'OVERLAY');
    end
end

local function UpdateCustomBorder(unitframe)
    if not unitframe.healthBar.CustomBorderTexture then
        return;
    end

    if CUSTOM_BORDER_ENABLED then
        unitframe.healthBar.CustomBorderTexture:SetTexture(CUSTOM_BORDER_PATH);
        unitframe.healthBar.CustomBorderTexture:SetPoint('CENTER', CUSTOM_BORDER_X_OFFSET, CUSTOM_BORDER_Y_OFFSET);
        unitframe.healthBar.CustomBorderTexture:SetSize(CUSTOM_BORDER_WIDTH, unitframe.data.minus and CUSTOM_BORDER_HEIGHT_MINUS or CUSTOM_BORDER_HEIGHT);
        unitframe.healthBar.CustomBorderTexture:Show();
    else
        unitframe.healthBar.CustomBorderTexture:Hide();
    end
end

function Module:UnitAdded(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.healthBar:SetFrameStrata(unitframe.data.unitType == 'SELF' and 'HIGH' or 'MEDIUM');

    CreateThreatPercentage(unitframe);
    UpdateThreatPercentage(unitframe);

    CreateCustomBorder(unitframe);
    UpdateCustomBorder(unitframe);

    Update(unitframe);
    UpdateTexture(unitframe);
    UpdateBorder(unitframe);
    UpdateSizes(unitframe);
    UpdateClickableArea(unitframe);
end

function Module:UnitRemoved(unitframe)
    unitframe.data.auraColored = nil;
    unitframe.data.wasAuraColored = nil;
    unitframe.data.raidIndex = nil;
end

function Module:UnitAura(unitframe)
    unitframe.data.auraColored = UpdateAurasColor(unitframe);

    if not unitframe.data.auraColored and unitframe.data.wasAuraColored then
        Update(unitframe);
        unitframe.data.wasAuraColored = nil;
    end
end

function Module:Update(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.healthBar:SetFrameStrata(unitframe.data.unitType == 'SELF' and 'HIGH' or 'MEDIUM');

    UpdateThreatPercentagePosition(unitframe);

    UpdateCustomBorder(unitframe);

    Update(unitframe);
    UpdateTexture(unitframe);
    UpdateBorder(unitframe);
    UpdateSizes(unitframe);
    UpdateClickableArea(unitframe);
end

function Module:UpdateLocalConfig()
    RAID_TARGET_HPBAR_COLORING = O.db.raid_target_hpbar_coloring;
    AURAS_HPBAR_COLORING = O.db.auras_hpbar_color_enabled;

    THREAT_ENABLED = O.db.threat_color_enabled;

    THREAT_COLOR_ISTAPPED_BORDER = O.db.threat_color_istapped_border;

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
    BORDER_SIZE = O.db.health_bar_border_size;

    SAME_BORDER_COLOR = O.db.health_bar_border_same_color;

    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.health_bar_border_color[1];
    BORDER_COLOR[2] = O.db.health_bar_border_color[2];
    BORDER_COLOR[3] = O.db.health_bar_border_color[3];
    BORDER_COLOR[4] = O.db.health_bar_border_color[4] or 1;

    BORDER_SELECTED_COLOR    = BORDER_SELECTED_COLOR or {};
    BORDER_SELECTED_COLOR[1] = O.db.health_bar_border_selected_color[1];
    BORDER_SELECTED_COLOR[2] = O.db.health_bar_border_selected_color[2];
    BORDER_SELECTED_COLOR[3] = O.db.health_bar_border_selected_color[3];
    BORDER_SELECTED_COLOR[4] = O.db.health_bar_border_selected_color[4] or 1;

    SHOW_CLICKABLE_AREA = O.db.size_clickable_area_show;

    ENEMY_MINUS_HEIGHT = O.db.size_enemy_minus_height;
    ENEMY_HEIGHT       = O.db.size_enemy_height;
    FRIENDLY_HEIGHT    = O.db.size_friendly_height;
    PLAYER_HEIGHT      = O.db.size_self_height;

    HPBAR_COLOR_DC    = HPBAR_COLOR_DC or {};
    HPBAR_COLOR_DC[1] = O.db.health_bar_color_dc[1];
    HPBAR_COLOR_DC[2] = O.db.health_bar_color_dc[2];
    HPBAR_COLOR_DC[3] = O.db.health_bar_color_dc[3];
    HPBAR_COLOR_DC[4] = O.db.health_bar_color_dc[4] or 1;

    HPBAR_COLOR_TAPPED    = HPBAR_COLOR_TAPPED or {};
    HPBAR_COLOR_TAPPED[1] = O.db.health_bar_color_tapped[1];
    HPBAR_COLOR_TAPPED[2] = O.db.health_bar_color_tapped[2];
    HPBAR_COLOR_TAPPED[3] = O.db.health_bar_color_tapped[3];
    HPBAR_COLOR_TAPPED[4] = O.db.health_bar_color_tapped[4] or 1;

    HPBAR_COLOR_ENEMY_NPC    = HPBAR_COLOR_ENEMY_NPC or {};
    HPBAR_COLOR_ENEMY_NPC[1] = O.db.health_bar_color_enemy_npc[1];
    HPBAR_COLOR_ENEMY_NPC[2] = O.db.health_bar_color_enemy_npc[2];
    HPBAR_COLOR_ENEMY_NPC[3] = O.db.health_bar_color_enemy_npc[3];
    HPBAR_COLOR_ENEMY_NPC[4] = O.db.health_bar_color_enemy_npc[4] or 1;

    HPBAR_COLOR_ENEMY_PLAYER    = HPBAR_COLOR_ENEMY_PLAYER or {};
    HPBAR_COLOR_ENEMY_PLAYER[1] = O.db.health_bar_color_enemy_player[1];
    HPBAR_COLOR_ENEMY_PLAYER[2] = O.db.health_bar_color_enemy_player[2];
    HPBAR_COLOR_ENEMY_PLAYER[3] = O.db.health_bar_color_enemy_player[3];
    HPBAR_COLOR_ENEMY_PLAYER[4] = O.db.health_bar_color_enemy_player[4] or 1;

    HPBAR_COLOR_FRIENDLY_NPC    = HPBAR_COLOR_FRIENDLY_NPC or {};
    HPBAR_COLOR_FRIENDLY_NPC[1] = O.db.health_bar_color_friendly_npc[1];
    HPBAR_COLOR_FRIENDLY_NPC[2] = O.db.health_bar_color_friendly_npc[2];
    HPBAR_COLOR_FRIENDLY_NPC[3] = O.db.health_bar_color_friendly_npc[3];
    HPBAR_COLOR_FRIENDLY_NPC[4] = O.db.health_bar_color_friendly_npc[4] or 1;

    HPBAR_COLOR_FRIENDLY_PLAYER    = HPBAR_COLOR_FRIENDLY_PLAYER or {};
    HPBAR_COLOR_FRIENDLY_PLAYER[1] = O.db.health_bar_color_friendly_player[1];
    HPBAR_COLOR_FRIENDLY_PLAYER[2] = O.db.health_bar_color_friendly_player[2];
    HPBAR_COLOR_FRIENDLY_PLAYER[3] = O.db.health_bar_color_friendly_player[3];
    HPBAR_COLOR_FRIENDLY_PLAYER[4] = O.db.health_bar_color_friendly_player[4] or 1;

    HPBAR_COLOR_NEUTRAL    = HPBAR_COLOR_NEUTRAL or {};
    HPBAR_COLOR_NEUTRAL[1] = O.db.health_bar_color_neutral_npc[1];
    HPBAR_COLOR_NEUTRAL[2] = O.db.health_bar_color_neutral_npc[2];
    HPBAR_COLOR_NEUTRAL[3] = O.db.health_bar_color_neutral_npc[3];
    HPBAR_COLOR_NEUTRAL[4] = O.db.health_bar_color_neutral_npc[4] or 1;

    CUSTOM_BORDER_ENABLED      = O.db.health_bar_custom_border_enabled;
    CUSTOM_BORDER_PATH         = O.db.health_bar_custom_border_path;
    CUSTOM_BORDER_WIDTH        = O.db.health_bar_custom_border_width;
    CUSTOM_BORDER_HEIGHT       = O.db.health_bar_custom_border_height;
    CUSTOM_BORDER_HEIGHT_MINUS = O.db.health_bar_custom_border_height_minus;
    CUSTOM_BORDER_X_OFFSET     = O.db.health_bar_custom_border_x_offset;
    CUSTOM_BORDER_Y_OFFSET     = O.db.health_bar_custom_border_y_offset;
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

function Module:RAID_TARGET_UPDATE()
    for _, unitframe in pairs(NP) do
        if unitframe:IsShown() then
            if not UpdateRaidTargetColor(unitframe) then
                Update(unitframe);
            end
        end
    end
end

function Module:UNIT_NAME_UPDATE(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    Update(NP[nameplate]);
end

function Module:UNIT_THREAT_LIST_UPDATE(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    Update(NP[nameplate]);
end

function Module:UNIT_CONNECTION(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    Update(NP[nameplate]);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
    self:RegisterEvent('ROLE_CHANGED_INFORM');
    self:RegisterEvent('PLAYER_ROLES_ASSIGNED'); -- Just to be sure...

    self:RegisterEvent('RAID_TARGET_UPDATE');

    self:RegisterEvent('UNIT_NAME_UPDATE');
    self:RegisterEvent('UNIT_THREAT_LIST_UPDATE');
    self:RegisterEvent('UNIT_CONNECTION');

    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', UpdateSizes);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateStatusText', Update); -- UpdateStatusText because UpdateHealth used in UNIT_MAXHEALTH and we don't neeed it

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', function(unitframe)
        Update(unitframe);
        UpdateSizes(unitframe);
    end);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthBorder', function(unitframe)
        UpdateBorder(unitframe);
        UpdateSizes(unitframe);
    end);
end