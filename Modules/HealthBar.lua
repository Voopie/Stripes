local S, L, O, U, D, E = unpack((select(2, ...)));
local Stripes = S:GetNameplateModule('Handler');
local Module = S:NewNameplateModule('HealthBar');
local Colors = S:GetModule('Options_Colors');

-- WoW API
local UnitSelectionType, UnitSelectionColor, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned =
      UnitSelectionType, UnitSelectionColor, UnitTreatAsPlayerForDisplay, UnitPlayerControlled, UnitExists, UnitIsUnit, UnitIsPlayer, UnitInParty, UnitInRaid, UnitGroupRolesAssigned;
local GetRaidTargetIndex = GetRaidTargetIndex;

-- Stripes API
local S_UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;
local U_UnitIsTapped, U_UnitIsOnThreatListWithPlayer, U_IsPlayerEffectivelyTank = U.UnitIsTapped, U.UnitIsOnThreatListWithPlayer, U.IsPlayerEffectivelyTank;

-- Libraries
local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start, LCG_PixelGlow_Stop = LCG.PixelGlow_Start, LCG.PixelGlow_Stop;
local LCG_AutoCastGlow_Start, LCG_AutoCastGlow_Stop, LCG_ButtonGlow_Start, LCG_ButtonGlow_Stop = LCG.AutoCastGlow_Start, LCG.AutoCastGlow_Stop, LCG.ButtonGlow_Start, LCG.ButtonGlow_Stop;

local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_STATUSBAR = LSM.MediaType.STATUSBAR;

-- Local Config
local DB = {};

local StripesThreatPercentageFont = CreateFont('StripesThreatPercentageFont');

local DEFAULT_STATUSBAR_TEXTURE = 'Interface\\TargetingFrame\\UI-TargetingFrame-BarFill';

local statusColors = {
    [0] = { 1.00, 0.00, 0.00, 1 },  -- not tanking, lower threat than tank. (red)
    [1] = { 0.75, 0.70, 0.15, 1 },  -- not tanking, higher threat than tank. (yellow)
    [2] = { 1.00, 0.35, 0.10, 1 },  -- insecurely tanking, another unit have higher threat but not tanking. (orange)
    [3] = { 0.15, 0.75, 0.15, 1 },  -- securely tanking, highest threat (green)
};

local offTankColor       = { 0.60, 0.00, 0.85, 1 };
local otherPetTankColor  = { 0.00, 0.44, 1.00, 1 };
local playerPetTankColor = { 0.00, 0.44, 1.00, 1 };

local PLAYER_ROLE;
local PLAYER_IS_TANK = false;

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

local playerUnits = D.PlayerUnits;

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
    elseif frame.data.isDead then
        r, g, b, a = DB.HPBAR_COLOR_DEAD[1], DB.HPBAR_COLOR_DEAD[2], DB.HPBAR_COLOR_DEAD[3], DB.HPBAR_COLOR_DEAD[4];
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
            elseif U_UnitIsTapped(frame.unit) then
                r, g, b, a = DB.HPBAR_COLOR_TAPPED[1], DB.HPBAR_COLOR_TAPPED[2], DB.HPBAR_COLOR_TAPPED[3], DB.HPBAR_COLOR_TAPPED[4];
            elseif frame.optionTable.colorHealthBySelection then
                if frame.optionTable.considerSelectionInCombatAsHostile and U_UnitIsOnThreatListWithPlayer(frame.displayedUnit) then
                    r, g, b, a = DB.HPBAR_COLOR_ENEMY_NPC[1], DB.HPBAR_COLOR_ENEMY_NPC[2], DB.HPBAR_COLOR_ENEMY_NPC[3], DB.HPBAR_COLOR_ENEMY_NPC[4];
                elseif frame.data.isPlayer and frame.data.unitType == 'FRIENDLY_PLAYER' then
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
                        elseif frame.data.unitType == 'FRIENDLY_PET' then
                            r, g, b, a = DB.HPBAR_COLOR_FRIENDLY_PET[1], DB.HPBAR_COLOR_FRIENDLY_PET[2], DB.HPBAR_COLOR_FRIENDLY_PET[3], DB.HPBAR_COLOR_FRIENDLY_PET[4];
                        elseif frame.data.unitType == 'ENEMY_PET' then
                            r, g, b, a = DB.HPBAR_COLOR_ENEMY_PET[1], DB.HPBAR_COLOR_ENEMY_PET[2], DB.HPBAR_COLOR_ENEMY_PET[3], DB.HPBAR_COLOR_ENEMY_PET[4];
                        else
                            r, g, b, a = UnitSelectionColor(frame.displayedUnit, frame.optionTable.colorHealthWithExtendedColors);
                        end
                    end
                end
            elseif frame.data.unitType == 'FRIENDLY_NPC' then
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

local function CreateThreatPercentage(unitframe)
    if unitframe.ThreatPercentage then
        return;
    end

    local frame = CreateFrame('Frame', '$parentThreatPercentage', unitframe);
    frame:SetAllPoints(unitframe.HealthBarsContainer.healthBar);

    local text = frame:CreateFontString(nil, 'BACKGROUND', 'StripesThreatPercentageFont');
    text:SetPoint(DB.TP_POINT, frame, DB.TP_RELATIVE_POINT, DB.TP_OFFSET_X, DB.TP_OFFSET_Y);
    text:SetTextColor(1, 1, 1, 1);

    frame.text = text;

    unitframe.ThreatPercentage = frame;
end

local function UpdateThreatPercentageTextAndColor(unitframe, value, r, g, b, a)
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
    local threatPercentage = unitframe.ThreatPercentage;

    threatPercentage.text:ClearAllPoints();
    threatPercentage.text:SetPoint(DB.TP_POINT, threatPercentage, DB.TP_RELATIVE_POINT, DB.TP_OFFSET_X, DB.TP_OFFSET_Y);
end

local function UpdateThreatName(unitframe, value, r, g, b)
    if not value or not DB.THREAT_NAME_COLORING then
        unitframe.data.threatNameColored = nil;
        unitframe.data.threatColorR = nil;
        unitframe.data.threatColorG = nil;
        unitframe.data.threatColorB = nil;
        return;
    end

    unitframe.name:SetVertexColor(r, g, b);

    unitframe.data.threatNameColored = true;
    unitframe.data.threatColorR = r;
    unitframe.data.threatColorG = g;
    unitframe.data.threatColorB = b;
end

local function GetThreatColor(unitframe, display)
    display = display or unitframe.data.threatDisplay;

    if not display then
        return;
    end

    local status = unitframe.data.threatStatus;
    local offTank, otherPetTank, playerPetTank = false, false, false;

    if not status or status < 3 then
        local tankUnit = unitframe.data.unit .. 'target';
        if UnitExists(tankUnit) and not UnitIsUnit(tankUnit, 'player') then
            if (UnitInParty(tankUnit) or UnitInRaid(tankUnit)) and UnitGroupRolesAssigned(tankUnit) == 'TANK' then
                -- group tank
                offTank = true;
            elseif not UnitIsPlayer(tankUnit) then
                if UnitIsUnit(tankUnit, 'pet') then
                    -- player's pet
                    playerPetTank = true;
                elseif UnitPlayerControlled(tankUnit) then
                    -- other player controlled npc (pet, vehicle, totem)
                    otherPetTank = true;
                end
            end
        end
    end

    local r, g, b, a;

    if PLAYER_IS_TANK and offTank then
        r, g, b, a = offTankColor[1], offTankColor[2], offTankColor[3], offTankColor[4];
    elseif playerPetTank then
        r, g, b, a = playerPetTankColor[1], playerPetTankColor[2], playerPetTankColor[3], playerPetTankColor[4];
    elseif otherPetTank then
        r, g, b, a = otherPetTankColor[1], otherPetTankColor[2], otherPetTankColor[3], otherPetTankColor[4];
    else
        r, g, b, a = statusColors[status][1], statusColors[status][2], statusColors[status][3], statusColors[status][4];
    end

    return r, g, b, a;
end

local function UpdateThreatPercentage(unitframe)
    if unitframe.data.isPlayer then
        UpdateThreatPercentageTextAndColor(unitframe);
        return;
    end

    local display = unitframe.data.threatDisplay;
    local r, g, b, a = GetThreatColor(unitframe, display);

    if r then
        UpdateThreatPercentageTextAndColor(unitframe, display, r, g, b, a);
    end
end

local function GetAuraColor(unit)
    local Cache = S:GetModule('Auras_Cache');

    if not Cache then
        return;
    end

    local auraColor;

    U.UnitHasAura(unit, nil, function(aura)
        if playerUnits[aura.sourceUnit] then
            local dataBySpellId = DB.AURAS_HPBAR_COLORING_DATA[aura.spellId];

            if dataBySpellId and dataBySpellId.enabled then
                auraColor = dataBySpellId.color;
            else
                local dataBySpellName = DB.AURAS_HPBAR_COLORING_DATA[aura.name];

                if dataBySpellName and dataBySpellName.enabled then
                    auraColor = dataBySpellName.color;
                end
            end

            if auraColor then
                return true;
            end
        end
    end);

    if auraColor and auraColor[1] then
        return auraColor[1], auraColor[2], auraColor[3], auraColor[4] or 1;
    end

    return false;
end

local function UpdateExecutionGlow(unitframe, shouldExecute)
    local isExecutionGlow = unitframe.data.isExecutionGlow;
    local healthPercent   = unitframe.data.healthPer;

    shouldExecute = shouldExecute == nil and (DB.EXECUTION_ENABLED and (healthPercent <= DB.EXECUTION_LOW_PERCENT or (DB.EXECUTION_HIGH_ENABLED and healthPercent >= DB.EXECUTION_HIGH_PERCENT))) or shouldExecute;

    if not shouldExecute then
        if isExecutionGlow then
            LCG_PixelGlow_Stop(unitframe.HealthBarsContainer.healthBar, 'S_EXECUTION');
            unitframe.data.isExecutionGlow = nil;
        end

        return;
    end

    if DB.EXECUTION_GLOW then
        if shouldExecute and not isExecutionGlow then
            LCG_PixelGlow_Start(unitframe.HealthBarsContainer.healthBar, nil, 16, nil, 6, nil, 1, 1, nil, 'S_EXECUTION');
            unitframe.data.isExecutionGlow = true;
        end
    else
        if isExecutionGlow then
            LCG_PixelGlow_Stop(unitframe.HealthBarsContainer.healthBar, 'S_EXECUTION');
            unitframe.data.isExecutionGlow = nil;
        end
    end
end

local COLORING_FUNCTIONS = {
    HIGH_THREAT = function(unitframe)
        local result = nil;

        if unitframe.data.isPlayer or not (DB.THREAT_ENABLED and DB.THREAT_COLOR_PRIO_HIGH) then
            unitframe.data.tpNeedUpdate = true;
            return result;
        end

        if PLAYER_IS_TANK and DB.THREAT_COLOR_PRIO_HIGH_EXCLUDE_TANK_ROLE then
            return result;
        end

        local display, status = unitframe.data.threatDisplay, unitframe.data.threatStatus;

        if display and status == 3 then
            local r, g, b, a = statusColors[status][1], statusColors[status][2], statusColors[status][3], statusColors[status][4];

            if DB.THREAT_NAME_COLORING and DB.THREAT_NAME_ONLY then
                UpdateThreatName(unitframe, display, r, g, b);
            else
                if U_UnitIsTapped(unitframe.data.unit) then
                    if DB.THREAT_COLOR_ISTAPPED_BORDER then
                        unitframe.HealthBarsContainer.border:SetVertexColor(r, g, b, a);
                    end
                else
                    local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

                    if r ~= cR or g ~= cG or b ~= cB or a ~= cA then
                        unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(r, g, b, a);
                    end

                    result = 'HIGH_THREAT';
                end

                UpdateThreatName(unitframe, display, r, g, b);
            end

            UpdateExecutionGlow(unitframe);
            UpdateThreatPercentageTextAndColor(unitframe, display, r, g, b, a);
            unitframe.data.tpNeedUpdate = false;
        end

        return result;
    end,

    LOW_THREAT = function(unitframe)
        local result = nil;

        if not PLAYER_IS_TANK or unitframe.data.isPlayer or not (DB.THREAT_ENABLED and DB.THREAT_COLOR_PRIO_HIGH) then
            unitframe.data.tpNeedUpdate = true;
            return result;
        end

        if D.NPCS_WO_AGGRO[unitframe.data.npcId] then
            return;
        end

        local display, status = unitframe.data.threatDisplay, unitframe.data.threatStatus;

        if display and status < 3 then
            local r, g, b, a = statusColors[status][1], statusColors[status][2], statusColors[status][3], statusColors[status][4];

            if DB.THREAT_NAME_COLORING and DB.THREAT_NAME_ONLY then
                UpdateThreatName(unitframe, display, r, g, b);
            else
                if U_UnitIsTapped(unitframe.data.unit) then
                    if DB.THREAT_COLOR_ISTAPPED_BORDER then
                        unitframe.HealthBarsContainer.border:SetVertexColor(r, g, b, a);
                    end
                else
                    local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

                    if r ~= cR or g ~= cG or b ~= cB or a ~= cA then
                        unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(r, g, b, a);
                    end

                    result = 'LOW_THREAT';
                end

                UpdateThreatName(unitframe, display, r, g, b);
            end

            UpdateExecutionGlow(unitframe);
            UpdateThreatPercentageTextAndColor(unitframe, display, r, g, b, a);
            unitframe.data.tpNeedUpdate = false;
        end

        return result;
    end,

    CURRENT_TARGET_FOCUS = function(unitframe)
        local result = nil;

        if DB.CURRENT_TARGET_COLOR_ENABLED and unitframe.data.isTarget then
            local color = DB.CURRENT_TARGET_USE_CLASS_COLOR and DB.CURRENT_TARGET_CLASS_COLOR or DB.CURRENT_TARGET_COLOR;
            local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

            if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
            end

            result = 'CURRENT_TARGET';
        elseif DB.CURRENT_FOCUS_COLOR_ENABLED and unitframe.data.isFocus then
            local color = DB.CURRENT_FOCUS_USE_CLASS_COLOR and DB.CURRENT_FOCUS_CLASS_COLOR or DB.CURRENT_FOCUS_COLOR;
            local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

            if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
            end

            result = 'CURRENT_FOCUS';
        end

        return result;
    end,

    CUSTOM = function(unitframe)
        local result = nil;

        LCG_PixelGlow_Stop(unitframe.HealthBarsContainer.healthBar, 'S_CUSTOMHP');
        LCG_AutoCastGlow_Stop(unitframe.HealthBarsContainer.healthBar, 'S_CUSTOMHP');
        LCG_ButtonGlow_Stop(unitframe.HealthBarsContainer.healthBar);

        if unitframe.data.isPlayer then
            return result;
        end

        if DB.CUSTOM_NPC_ENABLED and DB.CUSTOM_NPC_DATA[unitframe.data.npcId] and DB.CUSTOM_NPC_DATA[unitframe.data.npcId].enabled then
            local custom = DB.CUSTOM_NPC_DATA[unitframe.data.npcId];

            if custom.color_enabled then
                local color = Colors:Get(custom.color_name);
                local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

                if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                    unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
                end

                result = 'CUSTOM';
            end

            if custom.glow_enabled then
                if custom.glow_type == 1 then
                    LCG_PixelGlow_Start(unitframe.HealthBarsContainer.healthBar, Colors:Get(custom.glow_color_name), 16, nil, 6, nil, 1, 1, nil, 'S_CUSTOMHP');
                elseif custom.glow_type == 2 then
                    LCG_AutoCastGlow_Start(unitframe.HealthBarsContainer.healthBar, Colors:Get(custom.glow_color_name), nil, nil, nil, nil, nil, 'S_CUSTOMHP');
                elseif custom.glow_type == 3 then
                    LCG_ButtonGlow_Start(unitframe.HealthBarsContainer.healthBar);
                end
            end
        end

        return result;
    end,

    RAID_TARGET = function(unitframe)
        local result = nil;

        if not DB.RAID_TARGET_HPBAR_COLORING then
            unitframe.data.raidIndex = nil;
            return result;
        end

        local raidIndex = GetRaidTargetIndex(unitframe.data.unit);

        if not raidIndex then
            unitframe.data.raidIndex = nil;
            return result;
        end

        if RAID_TARGET_COLORS[raidIndex] then
            local color = RAID_TARGET_COLORS[raidIndex];
            local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

            if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
            end

            unitframe.data.raidIndex = raidIndex;

            result = 'RAID_TARGET';
        end

        return result;
    end,

    AURA = function(unitframe)
        local result = nil;

        if not DB.AURAS_HPBAR_COLORING then
            return result;
        end

        local r, g, b, a = GetAuraColor(unitframe.data.unit);

        if not r then
            return result;
        end

        local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

        if r ~= cR or g ~= cG or b ~= cB or a ~= cA then
            unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(r, g, b, a or 1);
        end

        result = 'AURA';

        return result;
    end,

    EXECUTION = function(unitframe)
        local result = nil;

        local healthPercent = unitframe.data.healthPer;
        local shouldExecute = DB.EXECUTION_ENABLED and (healthPercent <= DB.EXECUTION_LOW_PERCENT or (DB.EXECUTION_HIGH_ENABLED and healthPercent >= DB.EXECUTION_HIGH_PERCENT));

        if shouldExecute then
            local color = DB.EXECUTION_COLOR;
            local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

            if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
                unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4]);
            end

            result = 'EXECUTION';
        end

        UpdateExecutionGlow(unitframe, shouldExecute);

        return result;
    end,

    THREAT = function(unitframe)
        local result = nil;

        if unitframe.data.isPlayer or not DB.THREAT_ENABLED then
            unitframe.data.tpNeedUpdate = true;
            return result;
        end

        local display = unitframe.data.threatDisplay;
        local r, g, b, a = GetThreatColor(unitframe, display);

        if r then
            if DB.THREAT_NAME_COLORING and DB.THREAT_NAME_ONLY then
                UpdateThreatName(unitframe, display, r, g, b);
            else
                if U_UnitIsTapped(unitframe.data.unit) then
                    if DB.THREAT_COLOR_ISTAPPED_BORDER then
                        unitframe.HealthBarsContainer.border:SetVertexColor(r, g, b, a);
                    end
                else
                    local cR, cG, cB, cA = unitframe.HealthBarsContainer.healthBar:GetStatusBarColor();

                    if r ~= cR or g ~= cG or b ~= cB or a ~= cA then
                        unitframe.HealthBarsContainer.healthBar:SetStatusBarColor(r, g, b, a);
                    end
                end

                result = 'THREAT';

                UpdateThreatName(unitframe, display, r, g, b);
            end

            UpdateThreatPercentageTextAndColor(unitframe, display, r, g, b, a);
            unitframe.data.tpNeedUpdate = false;
        end

        return result;
    end,
};

local COLORING_PRIORITY = {
    [1] = COLORING_FUNCTIONS.HIGH_THREAT,
    [2] = COLORING_FUNCTIONS.LOW_THREAT,
    [3] = COLORING_FUNCTIONS.CURRENT_TARGET_FOCUS,
    [4] = COLORING_FUNCTIONS.CUSTOM,
    [5] = COLORING_FUNCTIONS.RAID_TARGET,
    [6] = COLORING_FUNCTIONS.AURA,
    [7] = COLORING_FUNCTIONS.EXECUTION,
    [8] = COLORING_FUNCTIONS.THREAT,
};

local function GetColoringFunctionPriority(func)
    for priority, cFunc in ipairs(COLORING_PRIORITY) do
        if cFunc == func then
            return priority;
        end
    end
end

local function UpdateHealthBarColorByPriority(unitframe)
    for priority, colorFunc in ipairs(COLORING_PRIORITY) do
        local result = colorFunc(unitframe);

        if result then
            unitframe.data.coloringResult   = result;
            unitframe.data.coloringPriority = priority;

            return result;
        end
    end
end

local function UpdateHealthBarColor(unitframe, partial)
    if not unitframe:IsShown() or not unitframe.data.unit or unitframe.data.isPersonal then
        return;
    end

    if unitframe.data.isUnimportantUnit then
        UpdateHealthColor(unitframe);
        return;
    end

    local result = UpdateHealthBarColorByPriority(unitframe);

    if not result and not partial then
        UpdateHealthColor(unitframe);
    end
end

local function UpdateBorder(unitframe)
    local border = unitframe.HealthBarsContainer.border;

    if Stripes.NameOnly:IsActive(unitframe) then
        border:Hide();
        return;
    end

    if DB.BORDER_HIDE then
        if unitframe.data.isPersonal then
            border:SetVertexColor(0, 0, 0);
            border:Show();
        else
            border:Hide();
        end

        return;
    end

    border:Show();

    if DB.SAME_BORDER_COLOR then
        border:SetVertexColor(unitframe.HealthBarsContainer.healthBar:GetStatusBarTexture():GetVertexColor());
    elseif unitframe.data.isTarget then
        border:SetVertexColor(DB.BORDER_SELECTED_COLOR[1], DB.BORDER_SELECTED_COLOR[2], DB.BORDER_SELECTED_COLOR[3], DB.BORDER_SELECTED_COLOR[4]);
    else
        border:SetVertexColor(DB.BORDER_COLOR[1], DB.BORDER_COLOR[2], DB.BORDER_COLOR[3], DB.BORDER_COLOR[4]);
    end
end

local function UpdateBorderSizes(unitframe)
    local borderSize, minPixels = DB.BORDER_SIZE, DB.BORDER_SIZE - 0.5;

    if unitframe.data.isPersonal then
        borderSize, minPixels = 1, 2;
    end

    local healthBarBorder = unitframe.HealthBarsContainer.border;

    PixelUtil.SetWidth(healthBarBorder.Left, borderSize, minPixels);
    PixelUtil.SetPoint(healthBarBorder.Left, 'TOPRIGHT', healthBarBorder, 'TOPLEFT', 0, borderSize, 0, minPixels);
    PixelUtil.SetPoint(healthBarBorder.Left, 'BOTTOMRIGHT', healthBarBorder, 'BOTTOMLEFT', 0, -borderSize, 0, minPixels);

    PixelUtil.SetWidth(healthBarBorder.Right, borderSize, minPixels);
    PixelUtil.SetPoint(healthBarBorder.Right, 'TOPLEFT', healthBarBorder, 'TOPRIGHT', 0, borderSize, 0, minPixels);
    PixelUtil.SetPoint(healthBarBorder.Right, 'BOTTOMLEFT', healthBarBorder, 'BOTTOMRIGHT', 0, -borderSize, 0, minPixels);

    PixelUtil.SetHeight(healthBarBorder.Bottom, borderSize, minPixels);
    PixelUtil.SetPoint(healthBarBorder.Bottom, 'TOPLEFT', healthBarBorder, 'BOTTOMLEFT', 0, 0);
    PixelUtil.SetPoint(healthBarBorder.Bottom, 'TOPRIGHT', healthBarBorder, 'BOTTOMRIGHT', 0, 0);

    if healthBarBorder.Top then
        PixelUtil.SetHeight(healthBarBorder.Top, borderSize, minPixels);
        PixelUtil.SetPoint(healthBarBorder.Top, 'BOTTOMLEFT', healthBarBorder, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(healthBarBorder.Top, 'BOTTOMRIGHT', healthBarBorder, 'TOPRIGHT', 0, 0);
    end

    if unitframe.data.isPersonal and unitframe.powerBar and unitframe.powerBar:IsShown() then
        local powerBarBorder = unitframe.powerBar.border;

        PixelUtil.SetWidth(powerBarBorder.Left, borderSize, minPixels);
        PixelUtil.SetPoint(powerBarBorder.Left, 'TOPRIGHT', powerBarBorder, 'TOPLEFT', 0, borderSize, 0, minPixels);
        PixelUtil.SetPoint(powerBarBorder.Left, 'BOTTOMRIGHT', powerBarBorder, 'BOTTOMLEFT', 0, -borderSize, 0, minPixels);

        PixelUtil.SetWidth(powerBarBorder.Right, borderSize, minPixels);
        PixelUtil.SetPoint(powerBarBorder.Right, 'TOPLEFT', powerBarBorder, 'TOPRIGHT', 0, borderSize, 0, minPixels);
        PixelUtil.SetPoint(powerBarBorder.Right, 'BOTTOMLEFT', powerBarBorder, 'BOTTOMRIGHT', 0, -borderSize, 0, minPixels);

        PixelUtil.SetHeight(powerBarBorder.Bottom, borderSize, minPixels);
        PixelUtil.SetPoint(powerBarBorder.Bottom, 'TOPLEFT', powerBarBorder, 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(powerBarBorder.Bottom, 'TOPRIGHT', powerBarBorder, 'BOTTOMRIGHT', 0, 0);

        if powerBarBorder.Top then
            PixelUtil.SetHeight(powerBarBorder.Top, borderSize, minPixels);
            PixelUtil.SetPoint(powerBarBorder.Top, 'BOTTOMLEFT', powerBarBorder, 'TOPLEFT', 0, 0);
            PixelUtil.SetPoint(powerBarBorder.Top, 'BOTTOMRIGHT', powerBarBorder, 'TOPRIGHT', 0, 0);
        end
    end
end

local function UpdateSizes(unitframe)
    if unitframe.data.isPersonal then
        unitframe.HealthBarsContainer:SetHeight(DB.PLAYER_HEIGHT);

        if unitframe.powerBar and unitframe.powerBar:IsShown() then
            unitframe.powerBar:SetHeight(DB.PLAYER_HEIGHT);
        end

        if ClassNameplateManaBarFrame and ClassNameplateManaBarFrame:IsShown() then
            PixelUtil.SetHeight(ClassNameplateManaBarFrame, DB.PLAYER_HEIGHT);
        end
    elseif unitframe.data.commonReaction == 'ENEMY' then
        if unitframe.data.minus then
            unitframe.HealthBarsContainer:SetHeight(DB.ENEMY_MINUS_HEIGHT);
            unitframe.HealthBarsContainer.sHeight = DB.ENEMY_MINUS_HEIGHT;
        else
            unitframe.HealthBarsContainer:SetHeight(DB.ENEMY_HEIGHT);
            unitframe.HealthBarsContainer.sHeight = DB.ENEMY_HEIGHT;
        end
    elseif unitframe.data.commonReaction == 'FRIENDLY' then
        unitframe.HealthBarsContainer:SetHeight(DB.FRIENDLY_HEIGHT);
        unitframe.HealthBarsContainer.sHeight = DB.FRIENDLY_HEIGHT;
    end

    UpdateBorderSizes(unitframe);
end

local function UpdateClickableArea(unitframe)
    if not DB.SHOW_CLICKABLE_AREA or unitframe.data.isPersonal then
        if unitframe.ClickableArea then
            unitframe.ClickableArea:Hide();
        end

        return;
    end

    if not unitframe.ClickableArea then
        local clickableArea = CreateFrame('Frame', nil, unitframe);

        local background = clickableArea:CreateTexture(nil, 'BACKGROUND', nil, -7);
        background:SetTexture('Interface\\Buttons\\WHITE8x8');
        background:SetAllPoints(clickableArea);
        background:SetVertexColor(1, 1, 1, 0.3);

        local border = clickableArea:CreateTexture(nil, 'BACKGROUND', nil, -8);
        border:SetTexture('Interface\\Buttons\\WHITE8x8');
        border:SetPoint('TOPLEFT', clickableArea, 'TOPLEFT', -2, 2);
        border:SetPoint('BOTTOMRIGHT', clickableArea, 'BOTTOMRIGHT', 2, -2);
        border:SetVertexColor(0.3, 0.3, 0.3, 0.8);

        clickableArea:SetPoint('CENTER');

        clickableArea.background = background;
        clickableArea.border     = border;

        unitframe.ClickableArea = clickableArea;
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

    unitframe.ClickableArea:Show();
end

local function CreateCustomBorder(unitframe)
    if not unitframe.HealthBarsContainer.healthBar.CustomBorderTexture then
        unitframe.HealthBarsContainer.healthBar.CustomBorderTexture = unitframe.HealthBarsContainer.healthBar:CreateTexture(nil, 'OVERLAY');
    end
end

local function UpdateCustomBorder(unitframe)
    if not unitframe.HealthBarsContainer.healthBar.CustomBorderTexture then
        return;
    end

    if not DB.CUSTOM_BORDER_ENABLED then
        unitframe.HealthBarsContainer.healthBar.CustomBorderTexture:Hide();
        return;
    end

    local healthBarCustomBorderTexture = unitframe.HealthBarsContainer.healthBar.CustomBorderTexture;

    healthBarCustomBorderTexture:SetTexture(DB.CUSTOM_BORDER_PATH);
    healthBarCustomBorderTexture:SetPoint('CENTER', DB.CUSTOM_BORDER_X_OFFSET, DB.CUSTOM_BORDER_Y_OFFSET);
    healthBarCustomBorderTexture:SetSize(DB.CUSTOM_BORDER_WIDTH, unitframe.data.minus and DB.CUSTOM_BORDER_HEIGHT_MINUS or DB.CUSTOM_BORDER_HEIGHT);
    healthBarCustomBorderTexture:Show();
end

local function UpdateBackgroundTexture(unitframe)
    if not unitframe.HealthBarsContainer.healthBar.background then
        return;
    end

    unitframe.HealthBarsContainer.healthBar.background:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, DB.HEALTH_BAR_BACKGROUND_TEXTURE));
    unitframe.HealthBarsContainer.healthBar.background:SetVertexColor(DB.HEALTH_BAR_BACKGROUND_COLOR[1], DB.HEALTH_BAR_BACKGROUND_COLOR[2], DB.HEALTH_BAR_BACKGROUND_COLOR[3], DB.HEALTH_BAR_BACKGROUND_COLOR[4]);
end

local function SetHealthBarTexture(unitframe, textureValue)
    if textureValue == unitframe.HealthBarsContainer.healthBar.textureValue then
        return;
    end

    unitframe.HealthBarsContainer.healthBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, textureValue));
    unitframe.HealthBarsContainer.healthBar.textureValue = textureValue;
end

local function CreateExtraTexture(unitframe)
    if unitframe.HealthBarsContainer.healthBar.ExtraTexture then
        return;
    end

    local extraTexture = unitframe.HealthBarsContainer.healthBar:CreateTexture(nil, 'OVERLAY');
    extraTexture:SetAllPoints();
    extraTexture:Hide();

    unitframe.HealthBarsContainer.healthBar.ExtraTexture = extraTexture;
end

local function SetExtraTextureAndColor(unitframe, textureValue, textureColor)
    local extraTexture = unitframe.HealthBarsContainer.healthBar.ExtraTexture;
    local r, g, b, a = extraTexture:GetVertexColor();

    local isSameValue = textureValue == extraTexture.textureValue;
    local isSameColor = r == textureColor[1] and g == textureColor[2] and b == textureColor[3] and a == textureColor[4];

    if isSameValue and isSameColor then
        return;
    end

    extraTexture:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, textureValue));
    extraTexture:SetVertexColor(textureColor[1], textureColor[2], textureColor[3], textureColor[4]);
    extraTexture.textureValue = textureValue;
end

local function UpdateExtraTexture(unitframe)
    if not unitframe.HealthBarsContainer.healthBar.ExtraTexture then
        return;
    end

    if unitframe.data.isPersonal then
        SetHealthBarTexture(unitframe, DEFAULT_STATUSBAR_TEXTURE);
        unitframe.HealthBarsContainer.healthBar.ExtraTexture:Hide();
    else
        local isTarget = unitframe.data.isTarget;
        local isFocus  = unitframe.data.isFocus;

        local textureEnabled = isTarget and DB.CURRENT_TARGET_CUSTOM_TEXTURE_ENABLED or isFocus and DB.CURRENT_FOCUS_CUSTOM_TEXTURE_ENABLED;

        if textureEnabled then
            local textureOverlay = isTarget and DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY or isFocus and DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY;
            local textureValue   = isTarget and DB.CURRENT_TARGET_CUSTOM_TEXTURE_VALUE or isFocus and DB.CURRENT_FOCUS_CUSTOM_TEXTURE_VALUE;
            local textureColor   = isTarget and DB.CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR or isFocus and DB.CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR;

            if textureOverlay then
                SetHealthBarTexture(unitframe, DB.HEALTH_BAR_TEXTURE);
                SetExtraTextureAndColor(unitframe, textureValue, textureColor);
                unitframe.HealthBarsContainer.healthBar.ExtraTexture:Show();
            else
                SetHealthBarTexture(unitframe, textureValue);
                unitframe.HealthBarsContainer.healthBar.ExtraTexture:Hide();
            end
        else
            SetHealthBarTexture(unitframe, DB.HEALTH_BAR_TEXTURE);
            unitframe.HealthBarsContainer.healthBar.ExtraTexture:Hide();
        end
    end
end

local function CreateSpark(unitframe)
    if unitframe.HealthBarsContainer.healthBar.Spark then
        return;
    end

    local spark = unitframe.HealthBarsContainer.healthBar:CreateTexture(nil, 'OVERLAY');
    spark:SetPoint('CENTER', unitframe.HealthBarsContainer.healthBar:GetStatusBarTexture(), 'RIGHT', 0, 0);
    spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark');
    spark:SetBlendMode('ADD');

    unitframe.HealthBarsContainer.healthBar.Spark = spark;
end

local function UpdateSpark(unitframe)
    if not unitframe.HealthBarsContainer.healthBar.Spark then
        return;
    end

    if DB.SPARK_SHOW and not unitframe.data.isPersonal then
        unitframe.HealthBarsContainer.healthBar.Spark:SetSize(DB.SPARK_WIDTH, DB.SPARK_HEIGHT);

        local _, maxValue = unitframe.HealthBarsContainer.healthBar:GetMinMaxValues();
        local currentValue = unitframe.HealthBarsContainer.healthBar:GetValue();

        if DB.SPARK_HIDE_AT_MAX_HEALTH and currentValue == maxValue then
            unitframe.HealthBarsContainer.healthBar.Spark:Hide();
        else
            unitframe.HealthBarsContainer.healthBar.Spark:Show();
        end
    else
        unitframe.HealthBarsContainer.healthBar.Spark:Hide();
    end
end

local function UpdateSparkPosition(unitframe)
    if unitframe.HealthBarsContainer.healthBar.Spark and DB.SPARK_SHOW and not unitframe.data.isPersonal then
        if DB.SPARK_HIDE_AT_MAX_HEALTH then
            local _, maxValue = unitframe.HealthBarsContainer.healthBar:GetMinMaxValues();
            local currentValue = unitframe.HealthBarsContainer.healthBar:GetValue();

            if currentValue == maxValue then
                unitframe.HealthBarsContainer.healthBar.Spark:Hide();
            else
                unitframe.HealthBarsContainer.healthBar.Spark:Show();
            end
        else
            unitframe.HealthBarsContainer.healthBar.Spark:Show();
        end
    end
end

function Module:UnitAdded(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.HealthBarsContainer.healthBar:SetFrameStrata(unitframe.data.isPersonal and 'HIGH' or 'MEDIUM');

    if unitframe.selectionHighlight then
        unitframe.selectionHighlight:SetAlpha(0);
    end

    CreateThreatPercentage(unitframe);
    UpdateThreatPercentageTextAndColor(unitframe);
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

    UpdateHealthBarColor(unitframe);

    if unitframe.data.tpNeedUpdate then
        UpdateThreatPercentage(unitframe);
    end
end

function Module:UnitRemoved(unitframe)
    unitframe.data.wasAura      = nil;
    unitframe.data.raidIndex    = nil;
    unitframe.data.tpNeedUpdate = nil;

    unitframe.data.coloringResult   = nil;
    unitframe.data.coloringPriority = nil;

    unitframe.data.isExecutionGlow = nil;

    unitframe.data.threatNameColored = nil;
    unitframe.data.threatColorR = nil;
    unitframe.data.threatColorG = nil;
    unitframe.data.threatColorB = nil;

    LCG_PixelGlow_Stop(unitframe.HealthBarsContainer.healthBar, 'S_CUSTOMHP');
    LCG_AutoCastGlow_Stop(unitframe.HealthBarsContainer.healthBar, 'S_CUSTOMHP');
    LCG_ButtonGlow_Stop(unitframe.HealthBarsContainer.healthBar);

    LCG_PixelGlow_Stop(unitframe.HealthBarsContainer.healthBar, 'S_EXECUTION');
end

function Module:UnitAura(unitframe)
    local priority = GetColoringFunctionPriority(COLORING_FUNCTIONS.AURA);

    if not unitframe.data.coloringPriority or unitframe.data.coloringPriority >= priority then
        local result = COLORING_FUNCTIONS.AURA(unitframe);

        if result then
            unitframe.data.wasAura = true;
        elseif unitframe.data.wasAura then
            unitframe.data.wasAura = nil;
            UpdateHealthBarColor(unitframe);
        end
    end
end

function Module:Update(unitframe)
    -- Hack to fix overlapping borders for personal nameplate :(
    unitframe.HealthBarsContainer.healthBar:SetFrameStrata(unitframe.data.isPersonal and 'HIGH' or 'MEDIUM');

    UpdateThreatPercentagePosition(unitframe);
    UpdateCustomBorder(unitframe);
    UpdateExtraTexture(unitframe);
    UpdateSpark(unitframe);
    UpdateSparkPosition(unitframe);
    UpdateBackgroundTexture(unitframe);
    UpdateBorder(unitframe);
    UpdateSizes(unitframe);
    UpdateClickableArea(unitframe);

    UpdateHealthBarColor(unitframe);

    if unitframe.data.tpNeedUpdate then
        UpdateThreatPercentage(unitframe);
    end
end

local function SetReversedColors(state)
    if state then
        statusColors[0] = O.db.threat_color_status_3;
        statusColors[1] = O.db.threat_color_status_1;
        statusColors[2] = O.db.threat_color_status_2;
        statusColors[3] = O.db.threat_color_status_0;
    else
        statusColors[0] = O.db.threat_color_status_0;
        statusColors[1] = O.db.threat_color_status_1;
        statusColors[2] = O.db.threat_color_status_2;
        statusColors[3] = O.db.threat_color_status_3;
    end
end

local function UpdateReverseThreat()
    if not O.db.threat_color_reversed then
        SetReversedColors(false);
    else
        local reverseSpec = O.db.threat_color_reversed_spec;

        if reverseSpec == 1 then -- ALL
            SetReversedColors(true);
        elseif reverseSpec == 2 then -- TANK ONLY
            SetReversedColors(PLAYER_ROLE == 'TANK');
        elseif reverseSpec == 3 then -- TANK + DAMAGER
            SetReversedColors(PLAYER_ROLE == 'TANK' or PLAYER_ROLE == 'DAMAGER');
        elseif reverseSpec == 4 then -- TANK + HEALER
            SetReversedColors(PLAYER_ROLE == 'TANK' or PLAYER_ROLE == 'HEALER');
        elseif reverseSpec == 5 then -- DAMAGER ONLY
            SetReversedColors(PLAYER_ROLE == 'DAMAGER');
        elseif reverseSpec == 6 then -- DAMAGER + HEALER
            SetReversedColors(PLAYER_ROLE == 'DAMAGER' or PLAYER_ROLE == 'HEALER');
        elseif reverseSpec == 7 then -- HEALER ONLY
            SetReversedColors(PLAYER_ROLE == 'HEALER');
        end
    end
end

function Module:PLAYER_LOGIN()
    PLAYER_IS_TANK = U_IsPlayerEffectivelyTank();
    PLAYER_ROLE    = U.GetPlayerRole();

    UpdateReverseThreat();
end

function Module:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= 'player' then
        return;
    end

    PLAYER_IS_TANK = U_IsPlayerEffectivelyTank();
    PLAYER_ROLE    = U.GetPlayerRole();

    UpdateReverseThreat();
end

function Module:ROLE_CHANGED_INFORM(changedName, _, _, newRole)
    if changedName ~= D.Player.Name then
        return;
    end

    PLAYER_IS_TANK = newRole == 'TANK';
    PLAYER_ROLE    = U.GetPlayerRole();

    UpdateReverseThreat();
end

function Module:PLAYER_ROLES_ASSIGNED()
    PLAYER_IS_TANK = U_IsPlayerEffectivelyTank();
    PLAYER_ROLE    = U.GetPlayerRole();

    UpdateReverseThreat();
end

function Module:RAID_TARGET_UPDATE()
    self:ForAllActiveAndShownUnitFrames(function(unitframe)
        UpdateHealthBarColor(unitframe, not unitframe.data.raidIndex);
    end);
end

function Module:PLAYER_FOCUS_CHANGED()
    self:ForAllActiveAndShownUnitFrames(function(unitframe)
        UpdateExtraTexture(unitframe);
        UpdateHealthBarColor(unitframe);
    end);
end

function Module:UpdateLocalConfig()
    DB.RAID_TARGET_HPBAR_COLORING = O.db.raid_target_hpbar_coloring;
    DB.AURAS_HPBAR_COLORING = O.db.auras_hpbar_color_enabled;
    DB.AURAS_HPBAR_COLORING_DATA = O.db.auras_hpbar_color_data;

    DB.THREAT_ENABLED = O.db.threat_color_enabled;
    DB.THREAT_COLOR_ISTAPPED_BORDER = O.db.threat_color_istapped_border;

    DB.THREAT_COLOR_PRIO_HIGH                   = O.db.threat_color_prio_high;
    DB.THREAT_COLOR_PRIO_HIGH_EXCLUDE_TANK_ROLE = O.db.threat_color_prio_high_exclude_tank_role;

    UpdateReverseThreat();

    offTankColor[1] = O.db.threat_color_offtank[1];
    offTankColor[2] = O.db.threat_color_offtank[2];
    offTankColor[3] = O.db.threat_color_offtank[3];
    offTankColor[4] = O.db.threat_color_offtank[4] or 1;

    otherPetTankColor[1] = O.db.threat_color_pettank[1];
    otherPetTankColor[2] = O.db.threat_color_pettank[2];
    otherPetTankColor[3] = O.db.threat_color_pettank[3];
    otherPetTankColor[4] = O.db.threat_color_pettank[4] or 1;

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
    S_UpdateFontObject(StripesThreatPercentageFont, O.db.threat_percentage_font_value, O.db.threat_percentage_font_size, O.db.threat_percentage_font_flag, O.db.threat_percentage_font_shadow);

    DB.THREAT_NAME_COLORING = O.db.threat_color_name;
    DB.THREAT_NAME_ONLY     = O.db.threat_color_name_only;

    DB.CUSTOM_NPC_ENABLED = O.db.custom_npc_enabled;
    DB.CUSTOM_NPC_DATA    = O.db.custom_npc;

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

    DB.HPBAR_COLOR_DEAD    = DB.HPBAR_COLOR_DEAD or {};
    DB.HPBAR_COLOR_DEAD[1] = O.db.health_bar_color_dead[1];
    DB.HPBAR_COLOR_DEAD[2] = O.db.health_bar_color_dead[2];
    DB.HPBAR_COLOR_DEAD[3] = O.db.health_bar_color_dead[3];
    DB.HPBAR_COLOR_DEAD[4] = O.db.health_bar_color_dead[4] or 1;

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

    DB.HPBAR_COLOR_ENEMY_PET    = DB.HPBAR_COLOR_ENEMY_PET or {};
    DB.HPBAR_COLOR_ENEMY_PET[1] = O.db.health_bar_color_enemy_pet[1];
    DB.HPBAR_COLOR_ENEMY_PET[2] = O.db.health_bar_color_enemy_pet[2];
    DB.HPBAR_COLOR_ENEMY_PET[3] = O.db.health_bar_color_enemy_pet[3];
    DB.HPBAR_COLOR_ENEMY_PET[4] = O.db.health_bar_color_enemy_pet[4] or 1;

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

    DB.HPBAR_COLOR_FRIENDLY_PET    = DB.HPBAR_COLOR_FRIENDLY_PET or {};
    DB.HPBAR_COLOR_FRIENDLY_PET[1] = O.db.health_bar_color_friendly_pet[1];
    DB.HPBAR_COLOR_FRIENDLY_PET[2] = O.db.health_bar_color_friendly_pet[2];
    DB.HPBAR_COLOR_FRIENDLY_PET[3] = O.db.health_bar_color_friendly_pet[3];
    DB.HPBAR_COLOR_FRIENDLY_PET[4] = O.db.health_bar_color_friendly_pet[4] or 1;

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
            UpdateHealthBarColor(unitframe);
        end
    end);

    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', UpdateSizes);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', UpdateSizes);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthBorder', function(unitframe)
        UpdateBorder(unitframe);
        UpdateSizes(unitframe);
    end);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateStatusText', UpdateHealthBarColor);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthColor', UpdateHealthBarColor);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateAggroFlash', function(unitframe)
        UpdateHealthBarColor(unitframe);

        if unitframe.data.tpNeedUpdate then
            UpdateThreatPercentage(unitframe);
        end
    end);
end