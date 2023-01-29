local S, L, O, U, D, E = unpack(select(2, ...));
local Stripes = S:NewNameplateModule('Handler');

-- Lua API
local pairs, math_ceil, math_max = pairs, math.ceil, math.max;

-- WoW API
local UnitIsUnit, UnitExists, UnitName, GetUnitName, UnitFactionGroup, UnitIsPlayer, UnitIsEnemy, UnitIsConnected, UnitClassification, UnitReaction, UnitIsPVPSanctuary, UnitNameplateShowsWidgetsOnly =
      UnitIsUnit, UnitExists, UnitName, GetUnitName, UnitFactionGroup, UnitIsPlayer, UnitIsEnemy, UnitIsConnected, UnitClassification, UnitReaction, UnitIsPVPSanctuary, UnitNameplateShowsWidgetsOnly;
local UnitGUID, UnitHealth, UnitHealthMax, UnitGetTotalAbsorbs, UnitCreatureType, UnitPVPName, UnitCanAttack = UnitGUID, UnitHealth, UnitHealthMax, UnitGetTotalAbsorbs, UnitCreatureType, UnitPVPName, UnitCanAttack;
local UnitInGuild = U.UnitInGuild;
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;

-- Stripes API
local GetNpcIDByGUID, GetUnitLevel, GetUnitColor = U.GetNpcIDByGUID, U.GetUnitLevel, U.GetUnitColor;
local utf8sub = U.UTF8SUB;

-- Libraries
local LT = S.Libraries.LT;
local LDC = S.Libraries.LDC;
local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_FONT = LSM.MediaType.FONT;
local LIST_FONT_FLAGS = O.Lists.font_flags;

local Masque = LibStub('Masque', true);
Stripes.Masque = Masque;

if Masque then
    Stripes.MasqueAurasGroup           = Masque:Group(S.AddonName, L['MASQUE_AURAS']);
    Stripes.MasqueAurasSpellstealGroup = Masque:Group(S.AddonName, L['MASQUE_DISPELLABLE_AURAS']);
    Stripes.MasqueAurasMythicGroup     = Masque:Group(S.AddonName, L['MASQUE_MYTHIC_AURAS']);
    Stripes.MasqueAurasImportantGroup  = Masque:Group(S.AddonName, L['MASQUE_IMPORTANT_AURAS']);
    Stripes.MasqueAurasCustomGroup     = Masque:Group(S.AddonName, L['MASQUE_CUSTOM_AURAS']);
end

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local NAME_TEXT_ENABLED, NAME_ONLY_FRIENDLY_ENABLED, NAME_ONLY_FRIENDLY_PLAYERS_ONLY, NAME_ONLY_MODE;
local NAME_TRANSLIT, NAME_REPLACE_DIACRITICS;
local NAME_CUT_ENABLED, NAME_CUT_NUMBER;

local NAME_ONLY_FRIENDLY_UNIT_TYPES = {
    ['FRIENDLY_PLAYER'] = true,
    ['FRIENDLY_NPC']    = true,
};

-- Updater
Stripes.Updater = CreateFrame('Frame');

local UPDATER_INTERVAL = 0.2;
local updaterElapsed   = 0;

Stripes.Updater.List = {};
local UpdaterList = Stripes.Updater.List;

Stripes.Updater.Add = function(_, name, func)
    if not func or type(func) ~= 'function' then
        error('Stripes.Updater: 2nd parameter must be a function | ' .. name);
    end

    UpdaterList[name] = func;
end

Stripes.Updater.Remove = function(_, name)
    if UpdaterList[name] then
        UpdaterList[name] = nil;
    end
end

Stripes.Updater.GetElementsCount = function()
    return U.TableCount(UpdaterList);
end

Stripes.Updater.OnUpdate = function(_, elapsed)
    updaterElapsed = updaterElapsed + elapsed;

    if updaterElapsed >= UPDATER_INTERVAL then
        updaterElapsed = 0;

        for _, unitframe in pairs(NP) do
            if unitframe.isActive and unitframe:IsShown() then
                for _, func in pairs(UpdaterList) do
                    func(unitframe);
                end
            end
        end
    end
end

Stripes.Updater:SetScript('OnUpdate', Stripes.Updater.OnUpdate);

local function SetCVar(key, value)
    if C_CVar.GetCVar(key) ~= tostring(value) then
        C_CVar.SetCVar(key, value);
    end
end

Stripes.SetCVar = SetCVar;

Stripes.UpdateAll = function()
    S:ForAllModules('UpdateLocalConfig');
    S:ForAllNameplateModules('UpdateLocalConfig');

    for _, unitframe in pairs(NP) do
        if unitframe.unit and UnitExists(unitframe.unit) then
            CompactUnitFrame_UpdateWidgetsOnlyMode(unitframe);
            CompactUnitFrame_UpdateName(unitframe);

            if unitframe.displayedUnit and UnitExists(unitframe.displayedUnit) then
                CompactUnitFrame_UpdateHealth(unitframe);
                CompactUnitFrame_UpdateHealthBorder(unitframe);
                CompactUnitFrame_UpdateHealPrediction(unitframe);
                CompactUnitFrame_UpdateSelectionHighlight(unitframe);
            end

            CompactUnitFrame_UpdateStatusText(unitframe);
            CompactUnitFrame_UpdateClassificationIndicator(unitframe);
        end

        S:ForAllNameplateModules('Update', unitframe);
    end
end

Stripes.UpdateFontObject = function(fontObject, fontValue, fontSize, fontFlag, fontShadow)
    fontObject:SetFont(LSM:Fetch(LSM_MEDIATYPE_FONT, O.db.use_global_font_value and O.db.global_font_value or fontValue), math.max(3, O.db.use_global_font_size and O.db.global_font_size or fontSize), LIST_FONT_FLAGS[O.db.use_global_font_flag and O.db.global_font_flag or fontFlag]);

    if O.db.use_global_font_shadow then
        fontObject:SetShadowOffset(O.db.global_font_shadow and 1 or 0, O.db.global_font_shadow and -1 or 0);
    else
        fontObject:SetShadowOffset(fontShadow and 1 or 0, fontShadow and -1 or 0);
    end

    fontObject:SetShadowColor(0, 0, 0);
end

local SSN = ShouldShowName;
Stripes.ShouldShowName = function(unitframe)
    return NAME_TEXT_ENABLED and (unitframe.unit and SSN(unitframe));
end

local function IsNameOnlyMode()
    return NAME_ONLY_FRIENDLY_ENABLED;
end

local function IsNameOnlyModeAndFriendly(unitType, canAttack)
    if not NAME_ONLY_FRIENDLY_ENABLED or canAttack then
        return false;
    end

    if NAME_ONLY_FRIENDLY_PLAYERS_ONLY then
        return unitType == 'FRIENDLY_PLAYER';
    else
        if not canAttack then
            return true;
        else
            return NAME_ONLY_FRIENDLY_UNIT_TYPES[unitType];
        end
    end
end

Stripes.IsNameOnlyMode            = IsNameOnlyMode;
Stripes.IsNameOnlyModeAndFriendly = IsNameOnlyModeAndFriendly;

Stripes.UnimportantUnits = {
    [167999] = true, -- Echo of Sin (SL, Castle Nathria, Sire Denathrius)
    [176920] = true, -- Domination Arrow (SL, Sanctum of Domination, Sylvanas)
    [189707] = true, -- Chaotic Essence (SL, Season 4, Raid Fated Affix)
    [191714] = true, -- Seeking Stormling (DF, Vault of the Incarnates, Raszageth P2.5)
};

do
    local CACHE = {};

    Stripes.GetCachedName = function(name, useTranslit, useReplaceDiacritics, useCut)
        if CACHE[name] then
            return CACHE[name];
        end

        local newName = name;

        if useTranslit and NAME_TRANSLIT then
            newName = LT:Transliterate(name);
        end

        if useReplaceDiacritics and NAME_REPLACE_DIACRITICS then
            newName = LDC:Replace(newName);
        end

        if useCut and NAME_CUT_ENABLED then
            newName = utf8sub(newName, 0, NAME_CUT_NUMBER);
        end

        if newName ~= name then
            CACHE[name] = newName;
        end

        return newName;
    end

    Stripes.CachedNamesResetCache = function()
        wipe(CACHE);
    end

    Stripes.CachedNamesAdd = function(oldName, newName)
        CACHE[oldName] = newName;
    end
end

local function UpdateSizesSafe()
    if U.PlayerInCombat() then
        Stripes:RegisterEvent('PLAYER_REGEN_ENABLED');
        return;
    end

    C_NamePlate.SetNamePlateEnemySize(O.db.size_enemy_clickable_width, O.db.size_enemy_clickable_height);

    if IsNameOnlyMode() and O.db.name_only_friendly_stacking then
        if U.IsInInstance() then
            C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
        else
            C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
        end
    else
        if U.IsInInstance() then
            C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, O.db.size_friendly_instance_clickable_height);
        else
            C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
        end
    end

    C_NamePlate.SetNamePlateSelfSize(O.db.size_self_width, O.db.size_self_height);

    C_NamePlate.SetNamePlateEnemyClickThrough(O.db.size_enemy_click_through);
    C_NamePlate.SetNamePlateFriendlyClickThrough(O.db.size_friendly_click_through);

    SetCVar('NameplatePersonalClickThrough', O.db.size_self_click_through and 1 or 0);
    C_NamePlate.SetNamePlateSelfClickThrough(O.db.size_self_click_through);
end

Stripes.UpdateSizesSafe = UpdateSizesSafe;

local function UpdateHealth(unitframe)
    unitframe.data.healthCurrent = UnitHealth(unitframe.data.unit) or 0;
    unitframe.data.healthMax     = math_max(UnitHealthMax(unitframe.data.unit) or 1, 1);
    unitframe.data.healthPerF    = 100 * (unitframe.data.healthCurrent / unitframe.data.healthMax);
    unitframe.data.healthPer     = math_ceil(unitframe.data.healthPerF);
end

local function UpdateLevel(unitframe)
    unitframe.data.level, unitframe.data.classification, unitframe.data.diff = GetUnitLevel(unitframe.data.unit);
end

local function UpdateAbsorbs(unitframe)
    unitframe.data.absorbAmount = UnitGetTotalAbsorbs(unitframe.data.unit) or 0;
end

local function UpdateUnitReaction(unitframe)
    local unit = unitframe.data.unit;

    unitframe.data.reaction     = UnitReaction('player', unit);
    unitframe.data.factionGroup = UnitFactionGroup(unit);

    if UnitIsUnit(unit, 'player') then
        unitframe.data.unitType = 'SELF';
        unitframe.data.commonUnitType = 'SELF';
        unitframe.data.commonReaction = 'FRIENDLY';
    elseif UnitIsPVPSanctuary(unit) and not UnitIsEnemy('player', unit) then
        unitframe.data.unitType = 'FRIENDLY_PLAYER';
        unitframe.data.commonUnitType = 'PLAYER';
        unitframe.data.commonReaction = 'FRIENDLY';
    elseif not UnitIsEnemy('player', unit) and (not unitframe.data.reaction or unitframe.data.reaction > 4) then
        if unitframe.data.isPlayer then
            unitframe.data.unitType = 'FRIENDLY_PLAYER';
            unitframe.data.commonUnitType = 'PLAYER';
        else
            unitframe.data.unitType = 'FRIENDLY_NPC';
            unitframe.data.commonUnitType = 'NPC';
        end

        unitframe.data.commonReaction = 'FRIENDLY';
    else
        if unitframe.data.isPlayer then
            unitframe.data.unitType = 'ENEMY_PLAYER';
            unitframe.data.commonUnitType = 'PLAYER';
        else
            unitframe.data.unitType = 'ENEMY_NPC';
            unitframe.data.commonUnitType = 'NPC';
        end

        unitframe.data.commonReaction = 'ENEMY';
    end
end

local function UpdateStatus(unitframe)
    local unit = unitframe.data.unit;

    unitframe.data.name      = GetUnitName(unit, true);
    unitframe.data.isPlayer  = UnitIsPlayer(unit);
    unitframe.data.canAttack = UnitCanAttack('player', unit);

    UpdateUnitReaction(unitframe);

    if unitframe.data.commonUnitType == 'PLAYER' then
        unitframe.data.nameWoRealm, unitframe.data.realm = UnitName(unit);
        unitframe.data.namePVP = UnitPVPName(unit);
    end

    if unitframe.data.unitType == 'FRIENDLY_PLAYER' then
        unitframe.data.guild = UnitInGuild(unit);
    end
end

local function UpdateWidgetStatus(unitframe)
    unitframe.data.widgetsOnly = UnitNameplateShowsWidgetsOnly(unitframe.data.unit);
end

local function UpdateClassification(unitframe)
    unitframe.data.level, unitframe.data.classification, unitframe.data.diff = GetUnitLevel(unitframe.data.unit);
end

local function UpdateConnection(unitframe)
    unitframe.data.isConnected = UnitIsConnected(unitframe.data.unit);
end

local function UpdateTarget(unitframe)
    unitframe.data.isTarget = unitframe.displayedUnit and UnitIsUnit(unitframe.displayedUnit, 'target');
end

local function UpdateFocus(unitframe)
    unitframe.data.isFocus = unitframe.displayedUnit and UnitIsUnit(unitframe.displayedUnit, 'focus');
end

local function UpdateClassName(unitframe)
    unitframe.data.className = unitframe.data.isPlayer and UnitClassBase(unitframe.data.unit) or nil;
end

local function UpdateNpcId(unitframe)
    unitframe.data.npcId = not unitframe.data.isPlayer and GetNpcIDByGUID(unitframe.data.unitGUID, true) or 0;
end

local function UpdateUnitColor(unitframe)
    unitframe.data.colorR, unitframe.data.colorG, unitframe.data.colorB = GetUnitColor(unitframe.data.unit, 2);
end

local function CVarsReset()
    SetCVar('nameplateShowOnlyNames', GetCVarDefault('nameplateShowOnlyNames'));

    SetCVar('nameplateMotion', GetCVarDefault('nameplateMotion'));
    SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'));

    SetCVar('ShowClassColorInFriendlyNameplate', GetCVarDefault('ShowClassColorInFriendlyNameplate'));
    SetCVar('ShowClassColorInNameplate', GetCVarDefault('ShowClassColorInNameplate'));

    SetCVar('nameplateOverlapH', GetCVarDefault('nameplateOverlapH'));
    SetCVar('nameplateOverlapV', GetCVarDefault('nameplateOverlapV'));

    SetCVar('nameplateShowFriends', GetCVarDefault('nameplateShowFriends'));
    SetCVar('nameplateShowEnemies', GetCVarDefault('nameplateShowEnemies'));

    SetCVar('nameplateShowSelf', 0);
    SetCVar('NameplatePersonalShowAlways', 0);
    SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'));

    SetCVar('nameplateShowDebuffsOnFriendly', GetCVarDefault('nameplateShowDebuffsOnFriendly'));

    -- Scales
    SetCVar('nameplateLargerScale', GetCVarDefault('nameplateLargerScale'));
    SetCVar('nameplateGlobalScale', GetCVarDefault('nameplateGlobalScale'));
    SetCVar('nameplateSelectedScale', GetCVarDefault('nameplateSelectedScale'));
    SetCVar('nameplateSelfScale', GetCVarDefault('nameplateSelfScale'));

    -- Insets
    SetCVar('nameplateLargeTopInset', GetCVarDefault('nameplateLargeTopInset'));
    SetCVar('nameplateLargeBottomInset', GetCVarDefault('nameplateLargeBottomInset'));
    SetCVar('nameplateOtherTopInset', GetCVarDefault('nameplateOtherTopInset'));
    SetCVar('nameplateOtherBottomInset', GetCVarDefault('nameplateOtherBottomInset'));
    SetCVar('nameplateSelfTopInset', GetCVarDefault('nameplateSelfTopInset'));
    SetCVar('nameplateSelfBottomInset', GetCVarDefault('nameplateSelfBottomInset'));

    SetCVar('nameplateShowEnemyMinions', GetCVarDefault('nameplateShowEnemyMinions'));
    SetCVar('nameplateShowEnemyGuardians', GetCVarDefault('nameplateShowEnemyGuardians'));
    SetCVar('nameplateShowEnemyMinus', GetCVarDefault('nameplateShowEnemyMinus'));
    SetCVar('nameplateShowEnemyPets', GetCVarDefault('nameplateShowEnemyPets'));
    SetCVar('nameplateShowEnemyTotems', GetCVarDefault('nameplateShowEnemyTotems'));
    SetCVar('nameplateShowFriendlyMinions', GetCVarDefault('nameplateShowFriendlyMinions'));
    SetCVar('nameplateShowFriendlyGuardians', GetCVarDefault('nameplateShowFriendlyGuardians'));
    SetCVar('nameplateShowFriendlyNPCs', GetCVarDefault('nameplateShowFriendlyNPCs'));
    SetCVar('nameplateShowFriendlyPets', GetCVarDefault('nameplateShowFriendlyPets'));
    SetCVar('nameplateShowFriendlyTotems', GetCVarDefault('nameplateShowFriendlyTotems'));

    SetCVar('NameplatePersonalClickThrough', GetCVarDefault('NameplatePersonalClickThrough'));

    -- Alpha
    SetCVar('nameplateSelectedAlpha', GetCVarDefault('nameplateSelectedAlpha'));
    SetCVar('nameplateMaxAlpha', GetCVarDefault('nameplateMaxAlpha'));
    SetCVar('nameplateMaxAlphaDistance', GetCVarDefault('nameplateMaxAlphaDistance'));
    SetCVar('nameplateMinAlpha', GetCVarDefault('nameplateMinAlpha'));
    SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'));
    SetCVar('nameplateOccludedAlphaMult', GetCVarDefault('nameplateOccludedAlphaMult'));
end

Stripes.CVarsReset = CVarsReset;

local function CVarsUpdate()
    SetCVar('nameplateShowOnlyNames', O.db.name_only_friendly_mode == 1 and 1 or 0);

    SetCVar('nameplateMotion', O.db.motion - 1);
    SetCVar('nameplateMotionSpeed', O.db.motion_speed);

    SetCVar('ShowClassColorInFriendlyNameplate', O.db.health_bar_class_color_friendly and 1 or 0);
    SetCVar('ShowClassColorInNameplate', O.db.health_bar_class_color_enemy and 1 or 0);

    SetCVar('nameplateOverlapH', O.db.overlap_h);
    SetCVar('nameplateOverlapV', O.db.overlap_v);

    SetCVar('nameplateShowFriends', O.db.show_friendly and 1 or 0);
    SetCVar('nameplateShowEnemies', O.db.show_enemy and 1 or 0);

    SetCVar('nameplateShowSelf', O.db.show_personal and 1 or 0);
    SetCVar('NameplatePersonalShowAlways', O.db.show_personal_always and 1 or 0);
    SetCVar('nameplateResourceOnTarget', O.db.show_personal_resource_ontarget and 1 or 0);

    SetCVar('nameplateShowDebuffsOnFriendly', O.db.auras_show_debuffs_on_friendly and 1 or 0);

    -- Scales
    SetCVar('nameplateLargerScale', O.db.scale_large);
    SetCVar('nameplateGlobalScale', O.db.scale_global);
    SetCVar('nameplateSelectedScale', O.db.scale_selected);
    SetCVar('nameplateSelfScale', O.db.scale_self);

    -- Insets
    SetCVar('nameplateLargeTopInset', O.db.large_top_inset);
    SetCVar('nameplateLargeBottomInset', O.db.large_bottom_inset);
    SetCVar('nameplateOtherTopInset', O.db.other_top_inset);
    SetCVar('nameplateOtherBottomInset', O.db.other_bottom_inset);
    SetCVar('nameplateSelfTopInset', O.db.self_top_inset);
    SetCVar('nameplateSelfBottomInset', O.db.self_bottom_inset);

    SetCVar('nameplateShowEnemyMinions', O.db.show_enemy_minions and 1 or 0);
    SetCVar('nameplateShowEnemyGuardians', O.db.show_enemy_guardians and 1 or 0);
    SetCVar('nameplateShowEnemyMinus', O.db.show_enemy_minus and 1 or 0);
    SetCVar('nameplateShowEnemyPets', O.db.show_enemy_pets and 1 or 0);
    SetCVar('nameplateShowEnemyTotems', O.db.show_enemy_totems and 1 or 0);
    SetCVar('nameplateShowFriendlyMinions', O.db.show_friendly_minions and 1 or 0);
    SetCVar('nameplateShowFriendlyGuardians', O.db.show_friendly_guardians and 1 or 0);
    SetCVar('nameplateShowFriendlyNPCs', O.db.show_friendly_npcs and 1 or 0);
    SetCVar('nameplateShowFriendlyPets', O.db.show_friendly_pets and 1 or 0);
    SetCVar('nameplateShowFriendlyTotems', O.db.show_friendly_totems and 1 or 0);

    SetCVar('NameplatePersonalClickThrough', O.db.size_self_click_through and 1 or 0);

    -- Alpha
    SetCVar('nameplateSelectedAlpha', O.db.selected_alpha);
    SetCVar('nameplateMaxAlpha', O.db.max_alpha);
    SetCVar('nameplateMaxAlphaDistance', O.db.max_alpha_distance);
    SetCVar('nameplateMinAlpha', O.db.min_alpha);
    SetCVar('nameplateMinAlphaDistance', O.db.min_alpha_distance);
    SetCVar('nameplateOccludedAlphaMult', O.db.occluded_alpha_mult);
end

Stripes.CVarsUpdate = CVarsUpdate;

local usedCVars = {
    ['ShowClassColorInFriendlyNameplate'] = function(value)
        O.GetPanel('HealthBar').health_bar_class_color_friendly:SetChecked(value == '1');
        O.db.health_bar_class_color_friendly = value == '1';
    end,

    ['ShowClassColorInNameplate'] = function(value)
        O.GetPanel('HealthBar').health_bar_class_color_enemy:SetChecked(value == '1');
        O.db.health_bar_class_color_enemy = value == '1';
    end,

    ['nameplateOverlapH'] = function(value)
        O.GetPanel('Sizes').overlap_h:SetValue(tonumber(value));
        O.db.overlap_h = tonumber(value);
    end,

    ['nameplateOverlapV'] = function(value)
        O.GetPanel('Sizes').overlap_v:SetValue(tonumber(value));
        O.db.overlap_v = tonumber(value);
    end,

    ['nameplateMotion'] = function(value)
        O.GetPanel('Visibility').motion:SetValue(tonumber(value) + 1);
        O.db.motion = tonumber(value) + 1;
    end,

    ['nameplateMotionSpeed'] = function(value)
        O.GetPanel('Visibility').motion_speed:SetValue(tonumber(value));
        O.db.motion_speed = tonumber(value);
    end,

    ['nameplateShowEnemies'] = function(value)
        O.GetPanel('Visibility').show_enemy:SetChecked(value == '1');
        O.db.show_enemy = value == '1';

        O.GetPanel('Visibility').show_enemy_minions:SetEnabled(O.db.show_enemy);
        O.GetPanel('Visibility').show_enemy_guardians:SetEnabled(O.db.show_enemy);
        O.GetPanel('Visibility').show_enemy_minus:SetEnabled(O.db.show_enemy);
        O.GetPanel('Visibility').show_enemy_pets:SetEnabled(O.db.show_enemy);
        O.GetPanel('Visibility').show_enemy_totems:SetEnabled(O.db.show_enemy);
    end,

    ['nameplateShowFriends'] = function(value)
        O.GetPanel('Visibility').show_friendly:SetChecked(value == '1');
        O.db.show_friendly = value == '1';

        O.GetPanel('Visibility').show_friendly_minions:SetEnabled(O.db.show_friendly);
        O.GetPanel('Visibility').show_friendly_guardians:SetEnabled(O.db.show_friendly);
        O.GetPanel('Visibility').show_friendly_npcs:SetEnabled(O.db.show_friendly);
        O.GetPanel('Visibility').show_friendly_pets:SetEnabled(O.db.show_friendly);
        O.GetPanel('Visibility').show_friendly_totems:SetEnabled(O.db.show_friendly);
    end,

    ['nameplateShowSelf'] = function(value)
        O.GetPanel('Visibility').show_personal:SetChecked(value == '1');
        O.db.show_personal = value == '1';
    end,

    ['nameplateShowEnemyMinions'] = function(value)
        O.GetPanel('Visibility').show_enemy_minions:SetChecked(value == '1');
        O.db.show_enemy_minions = value == '1';
    end,

    ['nameplateShowEnemyGuardians'] = function(value)
        O.GetPanel('Visibility').show_enemy_guardians:SetChecked(value == '1');
        O.db.show_enemy_guardians = value == '1';
    end,

    ['nameplateShowEnemyMinus'] = function(value)
        O.GetPanel('Visibility').show_enemy_minus:SetChecked(value == '1');
        O.db.show_enemy_minus = value == '1';
    end,

    ['nameplateShowEnemyPets'] = function(value)
        O.GetPanel('Visibility').show_enemy_pets:SetChecked(value == '1');
        O.db.show_enemy_pets = value == '1';
    end,

    ['nameplateShowEnemyTotems'] = function(value)
        O.GetPanel('Visibility').show_enemy_totems:SetChecked(value == '1');
        O.db.show_enemy_totems = value == '1';
    end,

    ['nameplateShowFriendlyMinions'] = function(value)
        O.GetPanel('Visibility').show_friendly_minions:SetChecked(value == '1');
        O.db.show_friendly_minions = value == '1';
    end,

    ['nameplateShowFriendlyGuardians'] = function(value)
        O.GetPanel('Visibility').show_friendly_guardians:SetChecked(value == '1');
        O.db.show_friendly_guardians = value == '1';
    end,

    ['nameplateShowFriendlyNPCs'] = function(value)
        O.GetPanel('Visibility').show_friendly_npcs:SetChecked(value == '1');
        O.db.show_friendly_npcs = value == '1';
    end,

    ['nameplateShowFriendlyPets'] = function(value)
        O.GetPanel('Visibility').show_friendly_pets:SetChecked(value == '1');
        O.db.show_friendly_pets = value == '1';
    end,

    ['nameplateShowFriendlyTotems'] = function(value)
        O.GetPanel('Visibility').show_friendly_totems:SetChecked(value == '1');
        O.db.show_friendly_totems = value == '1';
    end,

    ['NameplatePersonalShowAlways'] = function(value)
        O.GetPanel('Visibility').show_personal_always:SetChecked(value == '1');
        O.db.show_personal_always = value == '1';
    end,

    ['nameplateResourceOnTarget'] = function(value)
        O.GetPanel('Visibility').show_personal_resource_ontarget:SetChecked(value == '1');
        O.db.show_personal_resource_ontarget = value == '1';
    end,

    ['nameplateShowDebuffsOnFriendly'] = function(value)
        O.GetPanel('Auras').auras_show_debuffs_on_friendly:SetChecked(value == '1');
        O.db.auras_show_debuffs_on_friendly = value == '1';
    end,

    ['nameplateLargerScale'] = function(value)
        O.GetPanel('Sizes').scale_large:SetValue(tonumber(value));
        O.db.scale_large = tonumber(value);
    end,

    ['nameplateGlobalScale'] = function(value)
        O.GetPanel('Sizes').scale_global:SetValue(tonumber(value));
        O.db.scale_global = tonumber(value);
    end,

    ['nameplateSelectedScale'] = function(value)
        O.GetPanel('Sizes').scale_selected:SetValue(tonumber(value));
        O.db.scale_selected = tonumber(value);
    end,

    ['nameplateSelfScale'] = function(value)
        O.GetPanel('Sizes').scale_self:SetValue(tonumber(value));
        O.db.scale_self = tonumber(value);
    end,

    ['nameplateLargeTopInset'] = function(value)
        O.GetPanel('Sizes').large_top_inset:SetValue(tonumber(value));
        O.db.large_top_inset = tonumber(value);
    end,

    ['nameplateLargeBottomInset'] = function(value)
        O.GetPanel('Sizes').large_bottom_inset:SetValue(tonumber(value));
        O.db.large_bottom_inset = tonumber(value);
    end,

    ['nameplateOtherTopInset'] = function(value)
        O.GetPanel('Sizes').other_top_inset:SetValue(tonumber(value));
        O.db.other_top_inset = tonumber(value);
    end,

    ['nameplateOtherBottomInset'] = function(value)
        O.GetPanel('Sizes').other_bottom_inset:SetValue(tonumber(value));
        O.db.other_bottom_inset = tonumber(value);
    end,

    ['nameplateSelfTopInset'] = function(value)
        O.GetPanel('Sizes').self_top_inset:SetValue(tonumber(value));
        O.db.self_top_inset = tonumber(value);
    end,

    ['nameplateSelfBottomInset'] = function(value)
        O.GetPanel('Sizes').self_bottom_inset:SetValue(tonumber(value));
        O.db.self_bottom_inset = tonumber(value);
    end,

    ['nameplateShowOnlyNames'] = function(value)
        O.GetPanel('Visibility').name_only_friendly_mode:SetValue(value == '1' and 1 or 2);
        O.db.name_only_friendly_mode = value == '1' and 1 or 2;
    end,

    ['NameplatePersonalClickThrough'] = function(value)
        O.GetPanel('Sizes').size_self_click_through:SetChecked(value == '1');
        O.db.size_self_click_through = value == '1';
    end,

    ['nameplateSelectedAlpha'] = function(value)
        O.GetPanel('Visibility').selected_alpha:SetValue(tonumber(value));
        O.db.selected_alpha = tonumber(value);
    end,

    ['nameplateMaxAlpha'] = function(value)
        O.GetPanel('Visibility').max_alpha:SetValue(tonumber(value));
        O.db.max_alpha = tonumber(value);
    end,

    ['nameplateMaxAlphaDistance'] = function(value)
        O.GetPanel('Visibility').max_alpha_distance:SetValue(tonumber(value));
        O.db.max_alpha_distance = tonumber(value);
    end,

    ['nameplateMinAlpha'] = function(value)
        O.GetPanel('Visibility').min_alpha:SetValue(tonumber(value));
        O.db.min_alpha = tonumber(value);
    end,

    ['nameplateMinAlphaDistance'] = function(value)
        O.GetPanel('Visibility').min_alpha_distance:SetValue(tonumber(value));
        O.db.min_alpha_distance = tonumber(value);
    end,

    ['nameplateOccludedAlphaMult'] = function(value)
        O.GetPanel('Visibility').occluded_alpha_mult:SetValue(tonumber(value));
        O.db.occluded_alpha_mult = tonumber(value);
    end,

    ['NamePlateVerticalScale'] = function(value)
        C_Timer.After(0.25, function()
            UpdateSizesSafe();
        end);
    end,

    ['NamePlateHorizontalScale'] = function(value)
        C_Timer.After(0.25, function()
            UpdateSizesSafe();
        end);
    end,
}

local function HookSetCVar(name, value)
    if usedCVars[name] then
        usedCVars[name](tostring(value));
    end
end

local function ResetNameplateData(unitframe)
    unitframe.data.unit      = nil;
    unitframe.data.unitGUID  = nil;

    unitframe.data.isPersonal = nil;

    unitframe.data.healthCurrent = 0;

    unitframe.data.reaction = nil;

    unitframe.data.unitType = nil;
    unitframe.data.commonUnitType = nil;
    unitframe.data.commonReaction = nil;

    unitframe.data.npcId = 0;
    unitframe.data.creatureType = nil;

    unitframe.data.guild = nil;
    unitframe.data.realm = nil;

    unitframe.data.className = nil;

    unitframe.data.nameAbbr = nil;
    unitframe.data.nameCut = nil;
    unitframe.data.nameFirst = nil;
    unitframe.data.namePVP = nil;
    unitframe.data.nameWoRealm = nil;
    unitframe.data.nameTranslit        = nil;
    unitframe.data.nameTranslitWoRealm = nil;
    unitframe.data.nameTranslitPVP     = nil;

    unitframe.data.level = nil;

    unitframe.data.targetName = nil;

    unitframe.data.inCombatWithPlayer = nil;

    unitframe.data.isTarget = nil;
    unitframe.data.isFocus  = nil;

    unitframe.data.isUnimportantUnit = nil;
end

function Stripes:NAME_PLATE_UNIT_ADDED(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);
    local unitframe = nameplate and nameplate.UnitFrame;

    if not nameplate then
        return;
    end

    NP[nameplate] = unitframe;

    unitframe.data = unitframe.data or {};

    unitframe.data.unit      = unit;
    unitframe.data.unitGUID  = UnitGUID(unit);

    UpdateStatus(unitframe);
    UpdateClassName(unitframe);
    UpdateWidgetStatus(unitframe);
    UpdateNpcId(unitframe);
    UpdateUnitColor(unitframe);
    UpdateHealth(unitframe);
    UpdateAbsorbs(unitframe)
    UpdateClassification(unitframe);
    UpdateConnection(unitframe);
    UpdateTarget(unitframe);
    UpdateFocus(unitframe);

    unitframe.data.isPersonal = unitframe.data.unitType == 'SELF';

    unitframe.data.creatureType = not unitframe.data.isPlayer and UnitCreatureType(unit) or nil;
    unitframe.data.minus = UnitClassification(unit) == 'minus';
    unitframe.data.targetName = UnitName(unit .. 'target');

    if unitframe.data.widgetsOnly then
        unitframe.data.previousType = nil;
    else
        unitframe.data.previousType = unitframe.data.unitType;
        unitframe:UnregisterEvent('UNIT_AURA');
    end

    unitframe.isActive = true;
    S:ForAllNameplateModules('UnitAdded', unitframe);

    if Stripes.UnimportantUnits[unitframe.data.npcId] then
        unitframe.data.isUnimportantUnit = true;
    end

    if unitframe.data.widgetsOnly then
        unitframe.isActive = false;
        ResetNameplateData(unitframe);
        S:ForAllNameplateModules('UnitRemoved', unitframe);
    end
end

function Stripes:NAME_PLATE_UNIT_REMOVED(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    local unitframe = NP[nameplate];

    unitframe.isActive = false;
    ResetNameplateData(unitframe);
    S:ForAllNameplateModules('UnitRemoved', unitframe);
end

function Stripes:UNIT_AURA(unit, unitAuraUpdateInfo)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    local unitframe = NP[nameplate];

    S:ForAllNameplateModules('UnitAura', unitframe, unitAuraUpdateInfo);
end

function Stripes:PLAYER_TARGET_CHANGED()
    local nameplate = C_NamePlate_GetNamePlateForUnit('target');

    if not nameplate or not NP[nameplate] then
        return;
    end

    local unitframe = NP[nameplate];

    S:ForAllNameplateModules('UnitAura', unitframe);
end

function Stripes:UNIT_LEVEL(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    local unitframe = NP[nameplate];

    UpdateLevel(unitframe);
end

function Stripes:UNIT_FACTION(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    local unitframe = NP[nameplate];

    UpdateLevel(unitframe);
end

function Stripes:PLAYER_FOCUS_CHANGED()
    for _, unitframe in pairs(NP) do
        if unitframe.isActive and unitframe:IsShown() then
            UpdateFocus(unitframe);
        end
    end
end

function Stripes:PLAYER_LOGIN()
    CVarsUpdate();
end

function Stripes:PLAYER_ENTERING_WORLD()
    C_Timer.After(0.1, function()
        UpdateSizesSafe();
        self:UpdateAll();
    end);
end

function Stripes:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent('PLAYER_REGEN_ENABLED');

    UpdateSizesSafe();
end

function Stripes:UpdateLocalConfig()
    NAME_TEXT_ENABLED               = O.db.name_text_enabled;
    NAME_ONLY_FRIENDLY_ENABLED      = O.db.name_only_friendly_enabled;
    NAME_ONLY_FRIENDLY_PLAYERS_ONLY = O.db.name_only_friendly_players_only;
    NAME_ONLY_MODE                  = O.db.name_only_friendly_mode;

    NAME_TRANSLIT           = O.db.name_text_translit;
    NAME_REPLACE_DIACRITICS = O.db.name_text_replace_diacritics;
    NAME_CUT_ENABLED = O.db.target_name_cut_enabled;
    NAME_CUT_NUMBER  = O.db.target_name_cut_number;

    Stripes.Updater:SetShown(Stripes.Updater.GetElementsCount() > 0);
end

function Stripes:StartUp()
    self:UpdateLocalConfig();

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', UpdateHealth);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealPrediction', UpdateAbsorbs);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', UpdateStatus);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateWidgetsOnlyMode', UpdateWidgetStatus);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateClassificationIndicator', UpdateClassification);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateStatusText', UpdateConnection);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdateTarget);

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_ENTERING_WORLD');
    self:RegisterEvent('NAME_PLATE_UNIT_ADDED');
    self:RegisterEvent('NAME_PLATE_UNIT_REMOVED');
    self:RegisterEvent('UNIT_AURA');
    self:RegisterEvent('PLAYER_TARGET_CHANGED');
    self:RegisterEvent('UNIT_LEVEL');
    self:RegisterEvent('UNIT_FACTION');
    self:RegisterEvent('PLAYER_FOCUS_CHANGED');

    hooksecurefunc(C_CVar, 'SetCVar', HookSetCVar);

    self:UpdateAll();
end
