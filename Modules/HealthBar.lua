local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('HealthBar');
local Colors = S:GetModule('Options_Colors');

-- WoW API
local UnitIsFriend, UnitSelectionType, UnitSelectionColor, UnitDetailedThreatSituation, UnitThreatPercentageOfLead, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned =
      UnitIsFriend, UnitSelectionType, UnitSelectionColor, UnitDetailedThreatSituation, UnitThreatPercentageOfLead, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned;
local CompactUnitFrame_IsTapDenied, CompactUnitFrame_IsOnThreatListWithPlayer = CompactUnitFrame_IsTapDenied, CompactUnitFrame_IsOnThreatListWithPlayer;
local GetRaidTargetIndex = GetRaidTargetIndex;
local AuraUtil_ForEachAura, BUFF_MAX_DISPLAY = AuraUtil.ForEachAura, BUFF_MAX_DISPLAY;

-- Stripes API
local UnitIsTapped, IsPlayer, IsPlayerEffectivelyTank = U.UnitIsTapped, U.IsPlayer, U.IsPlayerEffectivelyTank;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Libraries
local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start, LCG_PixelGlow_Stop = LCG.PixelGlow_Start, LCG.PixelGlow_Stop;
local LCG_AutoCastGlow_Start, LCG_AutoCastGlow_Stop, LCG_ButtonGlow_Start, LCG_ButtonGlow_Stop = LCG.AutoCastGlow_Start, LCG.AutoCastGlow_Stop, LCG.ButtonGlow_Start, LCG.ButtonGlow_Stop;

local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_STATUSBAR = LSM.MediaType.STATUSBAR;

-- Nameplates frames
local NP = S.NamePlates;

-- Local Config
local DB = {};

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
local playerPetTankColor = { 0.00, 0.44, 1.00, 1 };

local PLAYER_IS_TANK = false;
local PLAYER_UNIT, PET_UNIT = 'player', 'pet';

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

local function IsUseClassColor(unitframe)
    if unitframe.data.unitType == 'ENEMY_PLAYER' and DB.HEALTH_BAR_CLASS_COLOR_ENEMY then
        return true;
    end

    if unitframe.data.unitType == 'FRIENDLY_PLAYER' and DB.HEALTH_BAR_CLASS_COLOR_FRIENDLY then
        return true;
    end

    return false;
end

local function UpdateHealthColor(frame)
    if not frame.displayedUnit then
        return;
    end

    local r, g, b, a;

    if not frame.data.isConnected then
        r, g, b, a = DB.HPBAR_COLOR_DC[1], DB.HPBAR_COLOR_DC[2], DB.HPBAR_COLOR_DC[3], DB.HPBAR_COLOR_DC[4];
    else
        if frame.optionTable.healthBarColorOverride then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
            r, g, b, a = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b, healthBarColorOverride.a or 1;
        else
            if (frame.optionTable.allowClassColorsForNPCs or frame.data.isPlayer or UnitTreatAsPlayerForDisplay(frame.displayedUnit)) and frame.optionTable.useClassColors and IsUseClassColor(frame) then
                local classColor;
                if DB.HEALTH_BAR_COLOR_CLASS_USE then
                    classColor = O.db['health_bar_color_class_' .. frame.data.className];
                    if classColor then
                        r, g, b, a = classColor[1], classColor[2], classColor[3], classColor[4] or 1;
                    end
                else
                    classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[frame.data.className];
                    if classColor then
                        r, g, b, a = classColor.r, classColor.g, classColor.b, 1;
                    end
                end

                if not r then
                    r, g, b, a = 0.8, 0.8, 0.8, 1;
                end
            elseif CompactUnitFrame_IsTapDenied(frame) then
                r, g, b, a = DB.HPBAR_COLOR_TAPPED[1], DB.HPBAR_COLOR_TAPPED[2], DB.HPBAR_COLOR_TAPPED[3], DB.HPBAR_COLOR_TAPPED[4];
            elseif frame.optionTable.colorHealthBySelection then
                if frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) then
                    r, g, b, a = DB.HPBAR_COLOR_ENEMY_NPC[1], DB.HPBAR_COLOR_ENEMY_NPC[2], DB.HPBAR_COLOR_ENEMY_NPC[3], DB.HPBAR_COLOR_ENEMY_NPC[4];
                elseif frame.data.isPlayer and UnitIsFriend(PLAYER_UNIT, frame.displayedUnit) then
                    r, g, b, a = DB.HPBAR_COLOR_FRIENDLY_PLAYER[1], DB.HPBAR_COLOR_FRIENDLY_PLAYER[2], DB.HPBAR_COLOR_FRIENDLY_PLAYER[3], DB.HPBAR_COLOR_FRIENDLY_PLAYER[4];
                else
                    local selectionType = UnitSelectionType(frame.displayedUnit, frame.optionTable.colorHealthWithExtendedColors);
                    if selectionType == 2 then
                        r, g, b, a = DB.HPBAR_COLOR_NEUTRAL[1], DB.HPBAR_COLOR_NEUTRAL[2], DB.HPBAR_COLOR_NEUTRAL[3], DB.HPBAR_COLOR_NEUTRAL[4];
                    else
                        if frame.data.unitType == 'ENEMY_PLAYER' then
                            r, g, b, a = DB.HPBAR_COLOR_ENEMY_PLAYER[1], DB.HPBAR_COLOR_ENEMY_PLAYER[2], DB.HPBAR_COLOR_ENEMY_PLAYER[3], DB.HPBAR_COLOR_ENEMY_PLAYER[4];
                        elseif frame.data.unitType == 'ENEMY_NPC' then
                            r, g, b, a = DB.HPBAR_COLOR_ENEMY_NPC[1], DB.HPBAR_COLOR_ENEMY_NPC[2], DB.HPBAR_COLOR_ENEMY_NPC[3], DB.HPBAR_COLOR_ENEMY_NPC[4];
                        elseif frame.data.unitType == 'FRIENDLY_NPC' then
                            r, g, b, a = DB.HPBAR_COLOR_FRIENDLY_NPC[1], DB.HPBAR_COLOR_FRIENDLY_NPC[2], DB.HPBAR_COLOR_FRIENDLY_NPC[3], DB.HPBAR_COLOR_FRIENDLY_NPC[4];
                        else
                            r, g, b, a = UnitSelectionColor(frame.displayedUnit, frame.optionTable.colorHealthWithExtendedColors);
                        end
                    end
                end
            elseif UnitIsFriend(PLAYER_UNIT, frame.displayedUnit) then
                r, g, b, a = DB.HPBAR_COLOR_FRIENDLY_NPC[1], DB.HPBAR_COLOR_FRIENDLY_NPC[2], DB.HPBAR_COLOR_FRIENDLY_NPC[3], DB.HPBAR_COLOR_FRIENDLY_NPC[4];
            else
                r, g, b, a = DB.HPBAR_COLOR_ENEMY_NPC[1], DB.HPBAR_COLOR_ENEMY_NPC[2], DB.HPBAR_COLOR_ENEMY_NPC[3], DB.HPBAR_COLOR_ENEMY_NPC[4];
            end
        end
    end

    local cR, cG, cB, cA = frame.healthBar:GetStatusBarColor();
    if r ~= cR or g ~= cG or b ~= cB or a ~= cA then
        frame.healthBar:SetStatusBarColor(r, g, b, a);
    end
end

-- Execution
local function Execution_Start(unitframe, onlyGlow)
    if not onlyGlow then
        local color = DB.EXECUTION_COLOR;
        local cR, cG, cB, cA = unitframe.healthBar:GetStatusBarColor();

        if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
            unitframe.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
        end
    end

    if DB.EXECUTION_GLOW then
        if not unitframe.healthBar.executionGlow then
            LCG_PixelGlow_Start(unitframe.healthBar, nil, 16, nil, 6, nil, 1, 1, nil, 'S_EXECUTION');
            unitframe.healthBar.executionGlow = true;
        end
    else
        LCG_PixelGlow_Stop(unitframe.healthBar, 'S_EXECUTION');
        unitframe.healthBar.executionGlow = nil;
    end
end

local function Execution_Stop(unitframe)
    LCG_PixelGlow_Stop(unitframe.healthBar, 'S_EXECUTION');
    unitframe.healthBar.executionGlow = nil;
end

-- Custom Health Bar Color
local function UpdateCustomHealthBarColor(unitframe)
    if unitframe.healthBar.highPrioColored or unitframe.healthBar.currentTargetColored then
        unitframe.healthBar.customColored = nil;
    else
        LCG_PixelGlow_Stop(unitframe.healthBar, 'S_CUSTOMHP');
        LCG_AutoCastGlow_Stop(unitframe.healthBar, 'S_CUSTOMHP');
        LCG_ButtonGlow_Stop(unitframe.healthBar);

        if DB.CUSTOM_HP_ENABLED and DB.CUSTOM_HP_DATA[unitframe.data.npcId] and DB.CUSTOM_HP_DATA[unitframe.data.npcId].enabled then
            if DB.CUSTOM_HP_DATA[unitframe.data.npcId].color_enabled then
                local color = Colors:Get(DB.CUSTOM_HP_DATA[unitframe.data.npcId].color_name);
                local cR, cG, cB, cA = unitframe.healthBar:GetStatusBarColor();

                if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                    unitframe.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
                end

                unitframe.healthBar.customColored = true;
            else
                unitframe.healthBar.customColored = nil;
            end

            if DB.CUSTOM_HP_DATA[unitframe.data.npcId].glow_enabled then
                if DB.CUSTOM_HP_DATA[unitframe.data.npcId].glow_type == 1 then
                    LCG_PixelGlow_Start(unitframe.healthBar, Colors:Get(DB.CUSTOM_HP_DATA[unitframe.data.npcId].glow_color_name), 16, nil, 6, nil, 1, 1, nil, 'S_CUSTOMHP');
                elseif DB.CUSTOM_HP_DATA[unitframe.data.npcId].glow_type == 2 then
                    LCG_AutoCastGlow_Start(unitframe.healthBar, Colors:Get(DB.CUSTOM_HP_DATA[unitframe.data.npcId].glow_color_name), nil, nil, nil, nil, nil, 'S_CUSTOMHP');
                elseif DB.CUSTOM_HP_DATA[unitframe.data.npcId].glow_type == 3 then
                    LCG_ButtonGlow_Start(unitframe.healthBar);
                end
            end
        else
            unitframe.healthBar.customColored = nil;
        end
    end
end

-- Threat
local function CreateThreatPercentage(unitframe)
    if unitframe.ThreatPercentage then
        return;
    end

    local frame = CreateFrame('Frame', '$parentThreatPercentage', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'BACKGROUND', 'StripesThreatPercentageFont');
    PixelUtil.SetPoint(frame.text, DB.TP_POINT, frame, DB.TP_RELATIVE_POINT, DB.TP_OFFSET_X, DB.TP_OFFSET_Y);
    frame.text:SetTextColor(1, 1, 1, 1);

    unitframe.ThreatPercentage = frame;
end

local function UpdateThreatPercentage(unitframe, value, r, g, b, a)
    if not value or not DB.TP_ENABLED then
        unitframe.ThreatPercentage.text:SetText('');
        return;
    end

    unitframe.ThreatPercentage.text:SetText(string.format('%.0f%%', value));

    if DB.TP_COLORING then
        unitframe.ThreatPercentage.text:SetTextColor(r, g, b, a or 1);
    else
        unitframe.ThreatPercentage.text:SetTextColor(1, 1, 1, 1);
    end
end

local function UpdateThreatPercentagePosition(unitframe)
    unitframe.ThreatPercentage.text:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.ThreatPercentage.text, DB.TP_POINT, unitframe.ThreatPercentage, DB.TP_RELATIVE_POINT, DB.TP_OFFSET_X, DB.TP_OFFSET_Y);
end

local function Threat_GetThreatSituationStatus(unit)
    local isTanking, status, threatpct = UnitDetailedThreatSituation(PLAYER_UNIT, unit);
    local display = threatpct;

    if isTanking then
        local lead = UnitThreatPercentageOfLead(PLAYER_UNIT, unit);
        display = lead == 0 and 100 or lead;
    end

    return display, status, isTanking;
end

local function Threat_HighPrioColor(unitframe)
    if not DB.THREAT_ENABLED or not DB.THREAT_COLOR_PRIO_HIGH then
        unitframe.healthBar.highPrioColored = nil;
        unitframe.data.tpNeedUpdate = true;
        return;
    end

    if PLAYER_IS_TANK and DB.THREAT_COLOR_PRIO_HIGH_EXCLUDE_TANK_ROLE then
        unitframe.healthBar.highPrioColored = nil;
        return;
    end

    local display, status = Threat_GetThreatSituationStatus(unitframe.data.unit);

    if display and status == 3 and not IsPlayer(unitframe.data.unit) then
        local r, g, b, a = statusColors[status][1], statusColors[status][2], statusColors[status][3], statusColors[status][4];

        if UnitIsTapped(unitframe.data.unit) then
            if DB.THREAT_COLOR_ISTAPPED_BORDER then
                unitframe.healthBar.border:SetVertexColor(r, g, b, a);
            end
        else
            unitframe.healthBar:SetStatusBarColor(r, g, b, a);
            unitframe.healthBar.highPrioColored = true;
        end

        UpdateThreatPercentage(unitframe, display, r, g, b, a);
        unitframe.data.tpNeedUpdate = false;
    else
        unitframe.healthBar.highPrioColored = nil;
    end
end

local function Threat_UpdateColor(unitframe)
    if not DB.THREAT_ENABLED then
        unitframe.data.tpNeedUpdate = true;
        return;
    end

    local display, status = Threat_GetThreatSituationStatus(unitframe.data.unit);
    local offTank, petTank, playerPetTank = false, false, false;

    if not status or status < 3 then
        local tank_unit = unitframe.data.unit .. 'target';
        if UnitExists(tank_unit) and not UnitIsUnit(tank_unit, PLAYER_UNIT) then
            if (UnitInParty(tank_unit) or UnitInRaid(tank_unit)) and UnitGroupRolesAssigned(tank_unit) == 'TANK' then
                -- group tank
                offTank = true;
            elseif not UnitIsPlayer(tank_unit) then
                if UnitIsUnit(tank_unit, PET_UNIT) then
                    -- player's pet
                    playerPetTank = true;
                elseif UnitPlayerControlled(tank_unit) then
                    -- player controlled npc (pet, vehicle, totem)
                    petTank = true;
                end
            end
        end
    end

    if display and not IsPlayer(unitframe.data.unit) then
        local r, g, b, a;

        if PLAYER_IS_TANK and offTank then
            r, g, b, a = offTankColor[1], offTankColor[2], offTankColor[3], offTankColor[4];
        elseif playerPetTank then
            r, g, b, a = playerPetTankColor[1], playerPetTankColor[2], playerPetTankColor[3], playerPetTankColor[4];
        elseif petTank then
            r, g, b, a = petTankColor[1], petTankColor[2], petTankColor[3], petTankColor[4];
        else
            r, g, b, a = statusColors[status][1], statusColors[status][2], statusColors[status][3], statusColors[status][4];
        end

        if UnitIsTapped(unitframe.data.unit) then
            if DB.THREAT_COLOR_ISTAPPED_BORDER then
                unitframe.healthBar.border:SetVertexColor(r, g, b, a);
            end
        else
            unitframe.healthBar:SetStatusBarColor(r, g, b, a);
        end

        UpdateThreatPercentage(unitframe, display, r, g, b, a);
        unitframe.data.tpNeedUpdate = false;
    end
end

local function Threat_UpdatePercentage(unitframe)
    local display, status = Threat_GetThreatSituationStatus(unitframe.data.unit);

    if display and not IsPlayer(unitframe.data.unit) then
        local offTank, petTank, playerPetTank = false, false, false;

        if not status or status < 3 then
            local tank_unit = unitframe.data.unit .. 'target';
            if UnitExists(tank_unit) and not UnitIsUnit(tank_unit, PLAYER_UNIT) then
                if (UnitInParty(tank_unit) or UnitInRaid(tank_unit)) and UnitGroupRolesAssigned(tank_unit) == 'TANK' then
                    -- group tank
                    offTank = true;
                elseif not UnitIsPlayer(tank_unit) then
                    if UnitIsUnit(tank_unit, PET_UNIT) then
                        -- player's pet
                        playerPetTank = true;
                    elseif UnitPlayerControlled(tank_unit) then
                        -- player controlled npc (pet, vehicle, totem)
                        petTank = true;
                    end
                end
            end
        end

        local r, g, b, a;

        if PLAYER_IS_TANK and offTank then
            r, g, b, a = offTankColor[1], offTankColor[2], offTankColor[3], offTankColor[4];
        elseif playerPetTank then
            r, g, b, a = playerPetTankColor[1], playerPetTankColor[2], playerPetTankColor[3], playerPetTankColor[4];
        elseif petTank then
            r, g, b, a = petTankColor[1], petTankColor[2], petTankColor[3], petTankColor[4];
        else
            r, g, b, a = statusColors[status][1], statusColors[status][2], statusColors[status][3], statusColors[status][4];
        end

        UpdateThreatPercentage(unitframe, display, r, g, b, a);
    end
end

local function GetAuraColor(unit)
    local _, name, spellId;
    local buffIndex = 1;
    local has = false;
    local color;

    AuraUtil_ForEachAura(unit, 'PLAYER HARMFUL', BUFF_MAX_DISPLAY, function(...)
        name, _, _, _, _, _, _, _, _, spellId = ...;

        local spellData = O.db.auras_hpbar_color_data[spellId] or O.db.auras_hpbar_color_data[name];

        if spellData and spellData.enabled then
            has = true;
            color = spellData.color;
            return true;
        end

        return buffIndex > BUFF_MAX_DISPLAY;
    end);

    if has then
        return color[1], color[2], color[3], color[4] or 1;
    end

    return false;
end

local function UpdateAurasColor(unitframe)
    if not DB.AURAS_HPBAR_COLORING then
        return false;
    end

    if DB.RAID_TARGET_HPBAR_COLORING and unitframe.data.raidIndex then
        return false;
    end

    local r, g, b, a = GetAuraColor(unitframe.data.unit);

    if not r then
        return false;
    end

    local cR, cG, cB, cA = unitframe.healthBar:GetStatusBarColor();

    if r ~= cR or g ~= cG or b ~= cB or a ~= cA then
        unitframe.healthBar:SetStatusBarColor(r, g, b, a or 1);
    end

    return true;
end

local function UpdateRaidTarget(unitframe)
    if not DB.RAID_TARGET_HPBAR_COLORING then
        unitframe.data.raidIndex = nil;
        return false;
    end

    local raidIndex = GetRaidTargetIndex(unitframe.data.unit);

    if not raidIndex then
        unitframe.data.raidIndex = nil;
        return false;
    end

    if RAID_TARGET_COLORS[raidIndex] then
        local color = RAID_TARGET_COLORS[raidIndex];
        local cR, cG, cB, cA = unitframe.healthBar:GetStatusBarColor();

        if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
            unitframe.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
        end

        unitframe.data.raidIndex = raidIndex;

        return true;
    end

    return false;
end

local function UpdateAuraColor(unitframe)
    if unitframe.healthBar.highPrioColored or unitframe.healthBar.currentTargetColored or unitframe.healthBar.customColored or unitframe.healthBar.raidTargetColored then
        unitframe.healthBar.auraColored = nil;
    else
        unitframe.healthBar.auraColored = UpdateAurasColor(unitframe);
    end
end

local function UpdateRaidTargetColor(unitframe)
    if unitframe.healthBar.highPrioColored or unitframe.healthBar.currentTargetColored or unitframe.healthBar.customColored then
        unitframe.healthBar.raidTargetColored = nil;
    else
        unitframe.healthBar.raidTargetColored = UpdateRaidTarget(unitframe);
        if not unitframe.healthBar.raidTargetColored then
            UpdateAuraColor(unitframe);
        end
    end
end

local function UpdateCurrentTargetColor(unitframe)
    if unitframe.healthBar.highPrioColored then
        unitframe.healthBar.currentTargetColored = nil;
    else
        if DB.CURRENT_TARGET_COLOR_ENABLED and unitframe.data.isTarget then
            local color = DB.CURRENT_TARGET_USE_CLASS_COLOR and DB.CURRENT_TARGET_CLASS_COLOR or DB.CURRENT_TARGET_COLOR;
            local cR, cG, cB, cA = unitframe.healthBar:GetStatusBarColor();

            if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                unitframe.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
            end

            unitframe.healthBar.currentTargetColored = true;
        elseif DB.CURRENT_FOCUS_COLOR_ENABLED and unitframe.data.isFocus then
            local color = DB.CURRENT_FOCUS_USE_CLASS_COLOR and DB.CURRENT_FOCUS_CLASS_COLOR or DB.CURRENT_FOCUS_COLOR;
            local cR, cG, cB, cA = unitframe.healthBar:GetStatusBarColor();

            if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                unitframe.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
            end

            unitframe.healthBar.currentTargetColored = true;
        else
            unitframe.healthBar.currentTargetColored = nil;
        end
    end
end

--[[
    Coloring prio:
    0) Threat High
    1) Current target
    2) Custom
    3) Raid target
    4) Aura
    5) Execution
    6) Threat
]]

function Module.UpdateHealthBar(unitframe)
    if not unitframe:IsShown() or unitframe.data.unitType == 'SELF' then
        return;
    end

    Threat_HighPrioColor(unitframe);
    UpdateCurrentTargetColor(unitframe);
    UpdateCustomHealthBarColor(unitframe);
    UpdateRaidTargetColor(unitframe);
    UpdateAuraColor(unitframe);

    if unitframe.healthBar.highPrioColored or unitframe.healthBar.currentTargetColored or unitframe.healthBar.customColored or unitframe.healthBar.raidTargetColored or unitframe.healthBar.auraColored then
        if DB.EXECUTION_ENABLED and (unitframe.data.healthPer <= DB.EXECUTION_LOW_PERCENT or (DB.EXECUTION_HIGH_ENABLED and unitframe.data.healthPer >= DB.EXECUTION_HIGH_PERCENT)) then
            Execution_Start(unitframe, true);
        else
            Execution_Stop(unitframe);
        end

        return;
    end

    UpdateHealthColor(unitframe);

    if DB.EXECUTION_ENABLED and (unitframe.data.healthPer <= DB.EXECUTION_LOW_PERCENT or (DB.EXECUTION_HIGH_ENABLED and unitframe.data.healthPer >= DB.EXECUTION_HIGH_PERCENT)) then
        Execution_Start(unitframe);
    else
        Execution_Stop(unitframe);
        Threat_UpdateColor(unitframe);
    end
end

local function UpdateBorder(unitframe)
    if DB.BORDER_HIDE then
        if unitframe.data.unitType == 'SELF' then
            unitframe.healthBar.border:SetVertexColor(0, 0, 0);
            unitframe.healthBar.border:Show();
        else
            unitframe.healthBar.border:Hide();
        end

        return;
    end

    unitframe.healthBar.border:Show();

    if DB.SAME_BORDER_COLOR then
        unitframe.healthBar.border:SetVertexColor(unitframe.healthBar:GetStatusBarTexture():GetVertexColor());
        return;
    end

    if UnitIsUnit(unitframe.data.unit, 'target') then
        unitframe.healthBar.border:SetVertexColor(DB.BORDER_SELECTED_COLOR[1], DB.BORDER_SELECTED_COLOR[2], DB.BORDER_SELECTED_COLOR[3], DB.BORDER_SELECTED_COLOR[4]);
        return;
    end

    unitframe.healthBar.border:SetVertexColor(DB.BORDER_COLOR[1], DB.BORDER_COLOR[2], DB.BORDER_COLOR[3], DB.BORDER_COLOR[4]);
end

local function UpdateBorderSizes(unitframe)
    local borderSize, minPixels = DB.BORDER_SIZE, DB.BORDER_SIZE - 0.5;

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
        unitframe.healthBar:SetHeight(DB.PLAYER_HEIGHT);

        if unitframe.powerBar and unitframe.powerBar:IsShown() then
            unitframe.powerBar:SetHeight(DB.PLAYER_HEIGHT);
        end

        if ClassNameplateManaBarFrame and ClassNameplateManaBarFrame:IsShown() then
            PixelUtil.SetHeight(ClassNameplateManaBarFrame, DB.PLAYER_HEIGHT);
        end
    elseif unitframe.data.commonReaction == 'ENEMY' then
        if unitframe.data.minus then
            unitframe.healthBar:SetHeight(DB.ENEMY_MINUS_HEIGHT);
            unitframe.healthBar.sHeight = DB.ENEMY_MINUS_HEIGHT;
        else
            unitframe.healthBar:SetHeight(DB.ENEMY_HEIGHT);
            unitframe.healthBar.sHeight = DB.ENEMY_HEIGHT;
        end
    elseif unitframe.data.commonReaction == 'FRIENDLY' then
        unitframe.healthBar:SetHeight(DB.FRIENDLY_HEIGHT);
        unitframe.healthBar.sHeight = DB.FRIENDLY_HEIGHT;
    end

    UpdateBorderSizes(unitframe);
end

local function UpdateClickableArea(unitframe)
    if not DB.SHOW_CLICKABLE_AREA or unitframe.data.unitType == 'SELF' then
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

local function CreateCustomBorder(unitframe)
    if not unitframe.healthBar.CustomBorderTexture then
        unitframe.healthBar.CustomBorderTexture = unitframe.healthBar:CreateTexture(nil, 'OVERLAY');
    end
end

local function UpdateCustomBorder(unitframe)
    if not unitframe.healthBar.CustomBorderTexture then
        return;
    end

    if DB.CUSTOM_BORDER_ENABLED then
        unitframe.healthBar.CustomBorderTexture:SetTexture(DB.CUSTOM_BORDER_PATH);
        unitframe.healthBar.CustomBorderTexture:SetPoint('CENTER', DB.CUSTOM_BORDER_X_OFFSET, DB.CUSTOM_BORDER_Y_OFFSET);
        unitframe.healthBar.CustomBorderTexture:SetSize(DB.CUSTOM_BORDER_WIDTH, unitframe.data.minus and DB.CUSTOM_BORDER_HEIGHT_MINUS or DB.CUSTOM_BORDER_HEIGHT);
        unitframe.healthBar.CustomBorderTexture:Show();
    else
        unitframe.healthBar.CustomBorderTexture:Hide();
    end
end

local function UpdateBackgroundTexture(unitframe)
    if not unitframe.healthBar.background then
        return;
    end

    unitframe.healthBar.background:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.HEALTH_BAR_BACKGROUND_TEXTURE));
    unitframe.healthBar.background:SetVertexColor(DB.HEALTH_BAR_BACKGROUND_COLOR[1], DB.HEALTH_BAR_BACKGROUND_COLOR[2], DB.HEALTH_BAR_BACKGROUND_COLOR[3], DB.HEALTH_BAR_BACKGROUND_COLOR[4]);
end

local function CreateExtraTexture(unitframe)
    if unitframe.healthBar.ExtraTexture then
        return;
    end

    unitframe.healthBar.ExtraTexture = unitframe.healthBar:CreateTexture(nil, 'OVERLAY');
    unitframe.healthBar.ExtraTexture:SetAllPoints();
    unitframe.healthBar.ExtraTexture:Hide();
end

local function UpdateExtraTargetTexture(unitframe)
    if DB.CURRENT_TARGET_CUSTOM_TEXTURE_ENABLED then
        if DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY then
            unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.HEALTH_BAR_TEXTURE));

            unitframe.healthBar.ExtraTexture:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.CURRENT_TARGET_CUSTOM_TEXTURE_VALUE));
            unitframe.healthBar.ExtraTexture:SetVertexColor(DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[1], DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[2], DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[3], DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[4]);
            unitframe.healthBar.ExtraTexture:Show();
        else
            unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.CURRENT_TARGET_CUSTOM_TEXTURE_VALUE));
            unitframe.healthBar.ExtraTexture:Hide();
        end
    else
        unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.HEALTH_BAR_TEXTURE));
        unitframe.healthBar.ExtraTexture:Hide();
    end
end

local function UpdateExtraFocusTexture(unitframe)
    if DB.CURRENT_FOCUS_CUSTOM_TEXTURE_ENABLED then
        if DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY then
            unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.HEALTH_BAR_TEXTURE));

            unitframe.healthBar.ExtraTexture:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.CURRENT_FOCUS_CUSTOM_TEXTURE_VALUE));
            unitframe.healthBar.ExtraTexture:SetVertexColor(DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[1], DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[2], DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[3], DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[4]);
            unitframe.healthBar.ExtraTexture:Show();
        else
            unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.CURRENT_FOCUS_CUSTOM_TEXTURE_VALUE));
            unitframe.healthBar.ExtraTexture:Hide();
        end
    else
        if unitframe.data.isTarget then
            UpdateExtraTargetTexture(unitframe);
        else
            unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.HEALTH_BAR_TEXTURE));
            unitframe.healthBar.ExtraTexture:Hide();
        end
    end
end

local function UpdateExtraTexture(unitframe)
    if not unitframe.healthBar.ExtraTexture then
        return;
    end

    if unitframe.data.unitType == 'SELF' then
        unitframe.healthBar:SetStatusBarTexture(DEFAULT_STATUSBAR_TEXTURE);
        unitframe.healthBar.ExtraTexture:Hide();
    else
        if unitframe.data.isFocus then
            UpdateExtraFocusTexture(unitframe);
        elseif unitframe.data.isTarget then
            UpdateExtraTargetTexture(unitframe);
        else
            unitframe.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.HEALTH_BAR_TEXTURE));
            unitframe.healthBar.ExtraTexture:Hide();
        end
    end
end

local function CreateSpark(unitframe)
    if unitframe.healthBar.Spark then
        return;
    end

    unitframe.healthBar.Spark = unitframe.healthBar:CreateTexture(nil, 'OVERLAY');
    unitframe.healthBar.Spark:SetPoint('CENTER', 0, 0);
    unitframe.healthBar.Spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark');
    unitframe.healthBar.Spark:SetBlendMode('ADD');
end

local function UpdateSpark(unitframe)
    if unitframe.healthBar.Spark then
        if DB.SPARK_SHOW then
            unitframe.healthBar.Spark:SetSize(DB.SPARK_WIDTH, DB.SPARK_HEIGHT);

            local _, maxValue = unitframe.healthBar:GetMinMaxValues();
            local currentValue = unitframe.healthBar:GetValue();

            if DB.SPARK_HIDE_AT_MAX_HEALTH and currentValue == maxValue then
                unitframe.healthBar.Spark:Hide();
            else
                unitframe.healthBar.Spark:Show();
            end
        else
            unitframe.healthBar.Spark:Hide();
        end
    end
end

local function UpdateSparkPosition(unitframe)
    if unitframe.healthBar.Spark and DB.SPARK_SHOW then
        local _, maxValue = unitframe.healthBar:GetMinMaxValues();
        local currentValue = unitframe.healthBar:GetValue();

        if DB.SPARK_HIDE_AT_MAX_HEALTH and currentValue == maxValue then
            unitframe.healthBar.Spark:Hide();
        else
            local sparkPosition = (currentValue / maxValue) * unitframe.healthBar:GetWidth();
            unitframe.healthBar.Spark:SetPoint('CENTER', unitframe.healthBar, 'LEFT', sparkPosition, 0);
            unitframe.healthBar.Spark:Show();
        end
    end
end

function Module:UnitAdded(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.healthBar:SetFrameStrata(unitframe.data.unitType == 'SELF' and 'HIGH' or 'MEDIUM');

    if unitframe.selectionHighlight then
        unitframe.selectionHighlight:SetAlpha(0);
    end

    CreateThreatPercentage(unitframe);
    UpdateThreatPercentage(unitframe);
    CreateCustomBorder(unitframe);
    UpdateCustomBorder(unitframe);
    CreateExtraTexture(unitframe);
    UpdateExtraTexture(unitframe);
    CreateSpark(unitframe);
    UpdateSpark(unitframe);
    UpdateSparkPosition(unitframe);
    UpdateBackgroundTexture(unitframe);
    UpdateBorder(unitframe);
    UpdateSizes(unitframe);
    UpdateClickableArea(unitframe);

    Module.UpdateHealthBar(unitframe);

    if unitframe.data.tpNeedUpdate then
        Threat_UpdatePercentage(unitframe);
    end
end

function Module:UnitRemoved(unitframe)
    unitframe.healthBar.auraColored          = nil;
    unitframe.healthBar.customColored        = nil;
    unitframe.healthBar.raidTargetColored    = nil;
    unitframe.healthBar.currentTargetColored = nil;
    unitframe.healthBar.highPrioColored      = nil;

    unitframe.data.raidIndex    = nil;
    unitframe.data.tpNeedUpdate = nil;

    LCG_PixelGlow_Stop(unitframe.healthBar, 'S_CUSTOMHP');
    LCG_AutoCastGlow_Stop(unitframe.healthBar, 'S_CUSTOMHP');
    LCG_ButtonGlow_Stop(unitframe.healthBar);

    LCG_PixelGlow_Stop(unitframe.healthBar, 'S_EXECUTION');
end

function Module:UnitAura(unitframe)
    UpdateAuraColor(unitframe);
end

function Module:Update(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.healthBar:SetFrameStrata(unitframe.data.unitType == 'SELF' and 'HIGH' or 'MEDIUM');

    UpdateThreatPercentagePosition(unitframe);
    UpdateCustomBorder(unitframe);
    UpdateExtraTexture(unitframe);
    UpdateSpark(unitframe);
    UpdateSparkPosition(unitframe);
    UpdateBackgroundTexture(unitframe);
    UpdateBorder(unitframe);
    UpdateSizes(unitframe);
    UpdateClickableArea(unitframe);

    Module.UpdateHealthBar(unitframe);

    if unitframe.data.tpNeedUpdate then
        Threat_UpdatePercentage(unitframe);
    end
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
        if unitframe.isActive and unitframe:IsShown() then
            UpdateRaidTargetColor(unitframe);
        end
    end
end

function Module:PLAYER_FOCUS_CHANGED()
    for _, unitframe in pairs(NP) do
        if unitframe.isActive and unitframe:IsShown() then
            UpdateExtraTexture(unitframe);
            Module.UpdateHealthBar(unitframe);
        end
    end
end

function Module:UpdateLocalConfig()
    DB.RAID_TARGET_HPBAR_COLORING = O.db.raid_target_hpbar_coloring;
    DB.AURAS_HPBAR_COLORING = O.db.auras_hpbar_color_enabled;

    DB.THREAT_ENABLED = O.db.threat_color_enabled;
    DB.THREAT_COLOR_ISTAPPED_BORDER = O.db.threat_color_istapped_border;

    DB.THREAT_COLOR_PRIO_HIGH                   = O.db.threat_color_prio_high;
    DB.THREAT_COLOR_PRIO_HIGH_EXCLUDE_TANK_ROLE = O.db.threat_color_prio_high_exclude_tank_role;

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

    playerPetTankColor[1] = O.db.threat_color_playerpettank[1];
    playerPetTankColor[2] = O.db.threat_color_playerpettank[2];
    playerPetTankColor[3] = O.db.threat_color_playerpettank[3];
    playerPetTankColor[4] = O.db.threat_color_playerpettank[4] or 1;

    DB.TP_ENABLED        = O.db.threat_percentage_enabled;
    DB.TP_COLORING       = O.db.threat_percentage_coloring;
    DB.TP_POINT          = O.Lists.frame_points[O.db.threat_percentage_point] or 'TOPLEFT';
    DB.TP_RELATIVE_POINT = O.Lists.frame_points[O.db.threat_percentage_relative_point] or 'BOTTOMLEFT';
    DB.TP_OFFSET_X       = O.db.threat_percentage_offset_x;
    DB.TP_OFFSET_Y       = O.db.threat_percentage_offset_y;
    UpdateFontObject(StripesThreatPercentageFont, O.db.threat_percentage_font_value, O.db.threat_percentage_font_size, O.db.threat_percentage_font_flag, O.db.threat_percentage_font_shadow);

    DB.CUSTOM_HP_ENABLED = O.db.custom_color_enabled;
    DB.CUSTOM_HP_DATA    = O.db.custom_color_data;

    DB.EXECUTION_ENABLED      = O.db.execution_enabled;
    DB.EXECUTION_COLOR        = DB.EXECUTION_COLOR or {};
    DB.EXECUTION_COLOR[1]     = O.db.execution_color[1];
    DB.EXECUTION_COLOR[2]     = O.db.execution_color[2];
    DB.EXECUTION_COLOR[3]     = O.db.execution_color[3];
    DB.EXECUTION_COLOR[4]     = O.db.execution_color[4] or 1;
    DB.EXECUTION_GLOW         = O.db.execution_glow;
    DB.EXECUTION_LOW_PERCENT  = O.db.execution_low_percent;
    DB.EXECUTION_HIGH_ENABLED = O.db.execution_high_enabled;
    DB.EXECUTION_HIGH_PERCENT = O.db.execution_high_percent;

    DB.HEALTH_BAR_CLASS_COLOR_ENEMY    = O.db.health_bar_class_color_enemy;
    DB.HEALTH_BAR_CLASS_COLOR_FRIENDLY = O.db.health_bar_class_color_friendly;

    DB.HEALTH_BAR_TEXTURE = O.db.health_bar_texture_value;

    DB.BORDER_HIDE = O.db.health_bar_border_hide;
    DB.BORDER_SIZE = O.db.health_bar_border_size;

    DB.SAME_BORDER_COLOR = O.db.health_bar_border_same_color;

    DB.BORDER_COLOR    = DB.BORDER_COLOR or {};
    DB.BORDER_COLOR[1] = O.db.health_bar_border_color[1];
    DB.BORDER_COLOR[2] = O.db.health_bar_border_color[2];
    DB.BORDER_COLOR[3] = O.db.health_bar_border_color[3];
    DB.BORDER_COLOR[4] = O.db.health_bar_border_color[4] or 1;

    DB.BORDER_SELECTED_COLOR    = DB.BORDER_SELECTED_COLOR or {};
    DB.BORDER_SELECTED_COLOR[1] = O.db.health_bar_border_selected_color[1];
    DB.BORDER_SELECTED_COLOR[2] = O.db.health_bar_border_selected_color[2];
    DB.BORDER_SELECTED_COLOR[3] = O.db.health_bar_border_selected_color[3];
    DB.BORDER_SELECTED_COLOR[4] = O.db.health_bar_border_selected_color[4] or 1;

    DB.SHOW_CLICKABLE_AREA = O.db.size_clickable_area_show;

    DB.ENEMY_MINUS_HEIGHT = O.db.size_enemy_minus_height;
    DB.ENEMY_HEIGHT       = O.db.size_enemy_height;
    DB.FRIENDLY_HEIGHT    = O.db.size_friendly_height;
    DB.PLAYER_HEIGHT      = O.db.size_self_height;

    DB.HPBAR_COLOR_DC    = DB.HPBAR_COLOR_DC or {};
    DB.HPBAR_COLOR_DC[1] = O.db.health_bar_color_dc[1];
    DB.HPBAR_COLOR_DC[2] = O.db.health_bar_color_dc[2];
    DB.HPBAR_COLOR_DC[3] = O.db.health_bar_color_dc[3];
    DB.HPBAR_COLOR_DC[4] = O.db.health_bar_color_dc[4] or 1;

    DB.HPBAR_COLOR_TAPPED    = DB.HPBAR_COLOR_TAPPED or {};
    DB.HPBAR_COLOR_TAPPED[1] = O.db.health_bar_color_tapped[1];
    DB.HPBAR_COLOR_TAPPED[2] = O.db.health_bar_color_tapped[2];
    DB.HPBAR_COLOR_TAPPED[3] = O.db.health_bar_color_tapped[3];
    DB.HPBAR_COLOR_TAPPED[4] = O.db.health_bar_color_tapped[4] or 1;

    DB.HPBAR_COLOR_ENEMY_NPC    = DB.HPBAR_COLOR_ENEMY_NPC or {};
    DB.HPBAR_COLOR_ENEMY_NPC[1] = O.db.health_bar_color_enemy_npc[1];
    DB.HPBAR_COLOR_ENEMY_NPC[2] = O.db.health_bar_color_enemy_npc[2];
    DB.HPBAR_COLOR_ENEMY_NPC[3] = O.db.health_bar_color_enemy_npc[3];
    DB.HPBAR_COLOR_ENEMY_NPC[4] = O.db.health_bar_color_enemy_npc[4] or 1;

    DB.HPBAR_COLOR_ENEMY_PLAYER    = DB.HPBAR_COLOR_ENEMY_PLAYER or {};
    DB.HPBAR_COLOR_ENEMY_PLAYER[1] = O.db.health_bar_color_enemy_player[1];
    DB.HPBAR_COLOR_ENEMY_PLAYER[2] = O.db.health_bar_color_enemy_player[2];
    DB.HPBAR_COLOR_ENEMY_PLAYER[3] = O.db.health_bar_color_enemy_player[3];
    DB.HPBAR_COLOR_ENEMY_PLAYER[4] = O.db.health_bar_color_enemy_player[4] or 1;

    DB.HPBAR_COLOR_FRIENDLY_NPC    = DB.HPBAR_COLOR_FRIENDLY_NPC or {};
    DB.HPBAR_COLOR_FRIENDLY_NPC[1] = O.db.health_bar_color_friendly_npc[1];
    DB.HPBAR_COLOR_FRIENDLY_NPC[2] = O.db.health_bar_color_friendly_npc[2];
    DB.HPBAR_COLOR_FRIENDLY_NPC[3] = O.db.health_bar_color_friendly_npc[3];
    DB.HPBAR_COLOR_FRIENDLY_NPC[4] = O.db.health_bar_color_friendly_npc[4] or 1;

    DB.HPBAR_COLOR_FRIENDLY_PLAYER    = DB.HPBAR_COLOR_FRIENDLY_PLAYER or {};
    DB.HPBAR_COLOR_FRIENDLY_PLAYER[1] = O.db.health_bar_color_friendly_player[1];
    DB.HPBAR_COLOR_FRIENDLY_PLAYER[2] = O.db.health_bar_color_friendly_player[2];
    DB.HPBAR_COLOR_FRIENDLY_PLAYER[3] = O.db.health_bar_color_friendly_player[3];
    DB.HPBAR_COLOR_FRIENDLY_PLAYER[4] = O.db.health_bar_color_friendly_player[4] or 1;

    DB.HPBAR_COLOR_NEUTRAL    = DB.HPBAR_COLOR_NEUTRAL or {};
    DB.HPBAR_COLOR_NEUTRAL[1] = O.db.health_bar_color_neutral_npc[1];
    DB.HPBAR_COLOR_NEUTRAL[2] = O.db.health_bar_color_neutral_npc[2];
    DB.HPBAR_COLOR_NEUTRAL[3] = O.db.health_bar_color_neutral_npc[3];
    DB.HPBAR_COLOR_NEUTRAL[4] = O.db.health_bar_color_neutral_npc[4] or 1;

    DB.CUSTOM_BORDER_ENABLED      = O.db.health_bar_custom_border_enabled;
    DB.CUSTOM_BORDER_PATH         = O.db.health_bar_custom_border_path;
    DB.CUSTOM_BORDER_WIDTH        = O.db.health_bar_custom_border_width;
    DB.CUSTOM_BORDER_HEIGHT       = O.db.health_bar_custom_border_height;
    DB.CUSTOM_BORDER_HEIGHT_MINUS = O.db.health_bar_custom_border_height_minus;
    DB.CUSTOM_BORDER_X_OFFSET     = O.db.health_bar_custom_border_x_offset;
    DB.CUSTOM_BORDER_Y_OFFSET     = O.db.health_bar_custom_border_y_offset;

    DB.CURRENT_TARGET_COLOR_ENABLED = O.db.current_target_health_bar_coloring;
    DB.CURRENT_TARGET_COLOR    = DB.CURRENT_TARGET_COLOR or {};
    DB.CURRENT_TARGET_COLOR[1] = O.db.current_target_health_bar_color[1];
    DB.CURRENT_TARGET_COLOR[2] = O.db.current_target_health_bar_color[2];
    DB.CURRENT_TARGET_COLOR[3] = O.db.current_target_health_bar_color[3];
    DB.CURRENT_TARGET_COLOR[4] = O.db.current_target_health_bar_color[4] or 1;

    DB.CURRENT_TARGET_USE_CLASS_COLOR = O.db.current_target_health_bar_use_class_color;

    if DB.CURRENT_TARGET_USE_CLASS_COLOR then
        DB.CURRENT_TARGET_CLASS_COLOR    = DB.CURRENT_TARGET_CLASS_COLOR or {};
        DB.CURRENT_TARGET_CLASS_COLOR[1] = D.Player.ClassColor.r;
        DB.CURRENT_TARGET_CLASS_COLOR[2] = D.Player.ClassColor.g;
        DB.CURRENT_TARGET_CLASS_COLOR[3] = D.Player.ClassColor.b;
        DB.CURRENT_TARGET_CLASS_COLOR[4] = D.Player.ClassColor.a or 1;
    end

    DB.CURRENT_TARGET_CUSTOM_TEXTURE_ENABLED       = O.db.current_target_custom_texture_enabled;
    DB.CURRENT_TARGET_CUSTOM_TEXTURE_VALUE         = O.db.current_target_custom_texture_value;
    DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY       = O.db.current_target_custom_texture_overlay;
    DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR    = DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR or {};
    DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[1] = O.db.current_target_custom_texture_overlay_color[1];
    DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[2] = O.db.current_target_custom_texture_overlay_color[2];
    DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[3] = O.db.current_target_custom_texture_overlay_color[3];
    DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR[4] = O.db.current_target_custom_texture_overlay_color[4] or 1;

    DB.CURRENT_FOCUS_COLOR_ENABLED = O.db.current_focus_health_bar_coloring;
    DB.CURRENT_FOCUS_COLOR    = DB.CURRENT_FOCUS_COLOR or {};
    DB.CURRENT_FOCUS_COLOR[1] = O.db.current_focus_health_bar_color[1];
    DB.CURRENT_FOCUS_COLOR[2] = O.db.current_focus_health_bar_color[2];
    DB.CURRENT_FOCUS_COLOR[3] = O.db.current_focus_health_bar_color[3];
    DB.CURRENT_FOCUS_COLOR[4] = O.db.current_focus_health_bar_color[4] or 1;

    DB.CURRENT_FOCUS_USE_CLASS_COLOR = O.db.current_focus_health_bar_use_class_color;

    if DB.CURRENT_FOCUS_USE_CLASS_COLOR then
        DB.CURRENT_FOCUS_CLASS_COLOR    = DB.CURRENT_FOCUS_CLASS_COLOR or {};
        DB.CURRENT_FOCUS_CLASS_COLOR[1] = D.Player.ClassColor.r;
        DB.CURRENT_FOCUS_CLASS_COLOR[2] = D.Player.ClassColor.g;
        DB.CURRENT_FOCUS_CLASS_COLOR[3] = D.Player.ClassColor.b;
        DB.CURRENT_FOCUS_CLASS_COLOR[4] = D.Player.ClassColor.a or 1;
    end

    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_ENABLED       = O.db.current_focus_custom_texture_enabled;
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_VALUE         = O.db.current_focus_custom_texture_value;
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY       = O.db.current_focus_custom_texture_overlay;
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_ALPHA = O.db.current_focus_custom_texture_overlay_alpha;
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_ALPHA_MODE = O.Lists.alpha_mode[O.db.current_focus_custom_texture_overlay_alpha_mode] or 'BLEND';
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR    = DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR or {};
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[1] = O.db.current_focus_custom_texture_overlay_color[1];
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[2] = O.db.current_focus_custom_texture_overlay_color[2];
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[3] = O.db.current_focus_custom_texture_overlay_color[3];
    DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR[4] = O.db.current_focus_custom_texture_overlay_color[4] or 1;

    DB.HEALTH_BAR_BACKGROUND_TEXTURE  = O.db.health_bar_background_texture_value;
    DB.HEALTH_BAR_BACKGROUND_COLOR    = DB.HEALTH_BAR_BACKGROUND_COLOR or {};
    DB.HEALTH_BAR_BACKGROUND_COLOR[1] = O.db.health_bar_background_color[1];
    DB.HEALTH_BAR_BACKGROUND_COLOR[2] = O.db.health_bar_background_color[2];
    DB.HEALTH_BAR_BACKGROUND_COLOR[3] = O.db.health_bar_background_color[3];
    DB.HEALTH_BAR_BACKGROUND_COLOR[4] = O.db.health_bar_background_color[4] or 1;

    DB.HEALTH_BAR_COLOR_CLASS_USE = O.db.health_bar_color_class_use;

    DB.SPARK_SHOW   = O.db.health_bar_spark_show;
    DB.SPARK_WIDTH  = O.db.health_bar_spark_width;
    DB.SPARK_HEIGHT = O.db.health_bar_spark_height;
    DB.SPARK_HIDE_AT_MAX_HEALTH = O.db.health_bar_spark_hide_at_max;
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
    self:RegisterEvent('ROLE_CHANGED_INFORM');
    self:RegisterEvent('PLAYER_ROLES_ASSIGNED'); -- Just to be sure...

    self:RegisterEvent('RAID_TARGET_UPDATE');
    self:RegisterEvent('PLAYER_FOCUS_CHANGED');

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', UpdateSparkPosition);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', function(unitframe)
        if DB.CURRENT_TARGET_CUSTOM_TEXTURE_ENABLED or DB.CURRENT_FOCUS_CUSTOM_TEXTURE_ENABLED then
            UpdateExtraTexture(unitframe);
        end

        if DB.CURRENT_TARGET_COLOR_ENABLED or DB.CURRENT_FOCUS_COLOR_ENABLED then
            Module.UpdateHealthBar(unitframe);
        end
    end);

    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', UpdateSizes);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', UpdateSizes);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthBorder', function(unitframe)
        UpdateBorder(unitframe);
        UpdateSizes(unitframe);
    end);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateStatusText', Module.UpdateHealthBar);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthColor', Module.UpdateHealthBar);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateAggroFlash', function(unitframe)
        Module.UpdateHealthBar(unitframe);

        if unitframe.data.tpNeedUpdate then
            Threat_UpdatePercentage(unitframe);
        end
    end);
end