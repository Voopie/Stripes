local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Handler');

-- Lua API
local string_find, string_lower, math_ceil, math_max = string.find, string.lower, math.ceil, math.max;

-- WoW API
local UnitIsUnit, UnitName, GetUnitName, UnitFactionGroup, UnitIsPlayer, UnitIsEnemy, UnitClassification, UnitReaction, UnitIsPVPSanctuary, UnitNameplateShowsWidgetsOnly =
      UnitIsUnit, UnitName, GetUnitName, UnitFactionGroup, UnitIsPlayer, UnitIsEnemy, UnitClassification, UnitReaction, UnitIsPVPSanctuary, UnitNameplateShowsWidgetsOnly;
local UnitGUID, UnitHealth, UnitHealthMax, UnitGetTotalAbsorbs, UnitCreatureType, UnitPVPName, UnitCanAttack = UnitGUID, UnitHealth, UnitHealthMax, UnitGetTotalAbsorbs, UnitCreatureType, UnitPVPName, UnitCanAttack;
local UnitInGuild = U.UnitInGuild;
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;

local UNKNOWN = UNKNOWN;

-- Stripes API
local GetNpcIDByGUID, GetUnitLevel, GetUnitColor, GetNpcSubLabelByID = U.GetNpcIDByGUID, U.GetUnitLevel, U.GetUnitColor, U.GetNpcSubLabelByID;

-- Libraries
local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_FONT = LSM.MediaType.FONT;
local LIST_FONT_FLAGS = O.Lists.font_flags;

local LT = S.Libraries.LT;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local NAME_TEXT_ENABLED, NAME_ONLY_FRIENDLY_ENABLED, NAME_ONLY_FRIENDLY_PLAYERS_ONLY;

local PLAYER_UNIT = 'player';

local NAME_ONLY_FRIENDLY_UNIT_TYPES = {
    ['FRIENDLY_PLAYER'] = true,
    ['FRIENDLY_NPC']    = true,
};

Module.UpdateAll = function()
    S:ForAllNameplateModules('UpdateLocalConfig');

    for _, unitframe in pairs(NP) do
        if unitframe.unit and UnitExists(unitframe.unit) then
            CompactUnitFrame_UpdateMaxHealth(unitframe);
            CompactUnitFrame_UpdateHealth(unitframe);
            CompactUnitFrame_UpdateHealthColor(unitframe);
            CompactUnitFrame_UpdateName(unitframe);
            CompactUnitFrame_UpdateSelectionHighlight(unitframe);
            CompactUnitFrame_UpdateHealthBorder(unitframe);
            CompactUnitFrame_UpdateHealPrediction(unitframe);
            CompactUnitFrame_UpdateWidgetsOnlyMode(unitframe);
        end

        S:ForAllNameplateModules('Update', unitframe);
    end
end

Module.UpdateFontObject = function(fontObject, fontValue, fontSize, fontFlag, fontShadow)
    fontObject:SetFont(LSM:Fetch(LSM_MEDIATYPE_FONT, fontValue), fontSize, LIST_FONT_FLAGS[fontFlag]);
    fontObject:SetShadowOffset(fontShadow and 1 or 0, fontShadow and -1 or 0);
    fontObject:SetShadowColor(0, 0, 0);
end

local SSN = _G.ShouldShowName;
local function ShouldShowName(unitframe)
    return NAME_TEXT_ENABLED and (unitframe.unit and SSN(unitframe));
end

Module.ShouldShowName = ShouldShowName;

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
        return NAME_ONLY_FRIENDLY_UNIT_TYPES[unitType];
    end
end

Module.IsNameOnlyMode            = IsNameOnlyMode;
Module.IsNameOnlyModeAndFriendly = IsNameOnlyModeAndFriendly;

local function UpdateSizesSafe()
    if U.PlayerInCombat() then
        Module:RegisterEvent('PLAYER_REGEN_ENABLED');
        return;
    end

    C_NamePlate.SetNamePlateEnemySize(O.db.size_enemy_clickable_width, O.db.size_enemy_clickable_height);

    if IsNameOnlyMode() and O.db.name_only_friendly_stacking then
        C_NamePlate.SetNamePlateFriendlySize(60, 1);
    else
        C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
    end

    C_NamePlate.SetNamePlateSelfSize(O.db.size_self_width, O.db.size_self_height);

    C_NamePlate.SetNamePlateEnemyClickThrough(O.db.size_enemy_click_through);
    C_NamePlate.SetNamePlateFriendlyClickThrough(O.db.size_friendly_click_through);

    C_CVar.SetCVar('NameplatePersonalClickThrough', O.db.size_self_click_through and 1 or 0);
    C_NamePlate.SetNamePlateSelfClickThrough(O.db.size_self_click_through);
end

Module.UpdateSizesSafe = UpdateSizesSafe;

local function UpdateHealth(unitframe)
    unitframe.data.healthCurrent = UnitHealth(unitframe.data.unit) or 0;
    unitframe.data.healthMax     = math_max(UnitHealthMax(unitframe.data.unit) or 1, 1);
    unitframe.data.healthPerF    = 100 * (unitframe.data.healthCurrent / unitframe.data.healthMax)
    unitframe.data.healthPer     = math_ceil(unitframe.data.healthPerF);
end

local function UpdateLevel(unitframe)
    unitframe.data.level, unitframe.data.classification, unitframe.data.diff = GetUnitLevel(unitframe.data.unit);
end

local function UpdateAbsorbs(unitframe)
    unitframe.data.absorbAmount = UnitGetTotalAbsorbs(unitframe.data.unit) or 0;
end

local function UpdateStatus(unitframe)
    local unit = unitframe.data.unit;

    unitframe.data.name         = GetUnitName(unit, true);
    unitframe.data.reaction     = UnitReaction(PLAYER_UNIT, unit);
    unitframe.data.factionGroup = UnitFactionGroup(unit);
    unitframe.data.isPlayer     = UnitIsPlayer(unit);

    unitframe.data.canAttack = UnitCanAttack(PLAYER_UNIT, unit);

    if UnitIsUnit(unit, PLAYER_UNIT) then
        unitframe.data.unitType = 'SELF';
        unitframe.data.commonUnitType = 'SELF';
        unitframe.data.commonReaction = 'FRIENDLY';
    elseif UnitIsPVPSanctuary(unit) then
        unitframe.data.unitType = 'FRIENDLY_PLAYER';
        unitframe.data.commonUnitType = 'PLAYER';
        unitframe.data.commonReaction = 'FRIENDLY';
    elseif not UnitIsEnemy(PLAYER_UNIT, unit) and (not unitframe.data.reaction or unitframe.data.reaction > 4) then
        unitframe.data.unitType = (unitframe.data.isPlayer and 'FRIENDLY_PLAYER') or 'FRIENDLY_NPC';
        unitframe.data.commonUnitType = (unitframe.data.isPlayer and 'PLAYER') or 'NPC';
        unitframe.data.commonReaction = 'FRIENDLY';
    else
        unitframe.data.unitType = (unitframe.data.isPlayer and 'ENEMY_PLAYER') or 'ENEMY_NPC';
        unitframe.data.commonUnitType = (unitframe.data.isPlayer and 'PLAYER') or 'NPC';
        unitframe.data.commonReaction = 'ENEMY';
    end

    if unitframe.data.unitType == 'FRIENDLY_PLAYER' then
        unitframe.data.nameWoRealm, unitframe.data.realm = UnitName(unit);
        unitframe.data.namePVP = UnitPVPName(unit);
    end

    if unitframe.data.unitType == 'ENEMY_PLAYER' then
        unitframe.data.nameWoRealm, unitframe.data.realm = UnitName(unit);
    end

    if unitframe.data.commonUnitType == 'PLAYER' then
        unitframe.data.nameTranslit        = LT:Transliterate(unitframe.data.name);
        unitframe.data.nameTranslitWoRealm = LT:Transliterate(unitframe.data.nameWoRealm);
        unitframe.data.nameTranslitPVP     = LT:Transliterate(unitframe.data.namePVP);
    end
end

local function UpdateWidgetStatus(unitframe)
    unitframe.data.widgetsOnly = UnitNameplateShowsWidgetsOnly(unitframe.data.unit);
end

local function UpdateClassification(unitframe)
    unitframe.data.level, unitframe.data.classification, unitframe.data.diff = GetUnitLevel(unitframe.data.unit);
end

local function CVarsReset()
    C_CVar.SetCVar('nameplateShowOnlyNames', GetCVarDefault('nameplateShowOnlyNames'));

    C_CVar.SetCVar('nameplateMotion', GetCVarDefault('nameplateMotion'));
    C_CVar.SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'));

    C_CVar.SetCVar('ShowClassColorInFriendlyNameplate', GetCVarDefault('ShowClassColorInFriendlyNameplate'));
    C_CVar.SetCVar('ShowClassColorInNameplate', GetCVarDefault('ShowClassColorInNameplate'));

    C_CVar.SetCVar('nameplateOverlapH', GetCVarDefault('nameplateOverlapH'));
    C_CVar.SetCVar('nameplateOverlapV', GetCVarDefault('nameplateOverlapV'));

    C_CVar.SetCVar('nameplateShowFriends', GetCVarDefault('nameplateShowFriends'));
    C_CVar.SetCVar('nameplateShowEnemies', GetCVarDefault('nameplateShowEnemies'));

    C_CVar.SetCVar('nameplateShowSelf', 0);
    C_CVar.SetCVar('NameplatePersonalShowAlways', 0);
    C_CVar.SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'));

    C_CVar.SetCVar('nameplateShowDebuffsOnFriendly', GetCVarDefault('nameplateShowDebuffsOnFriendly'));

    -- Scales
    C_CVar.SetCVar('nameplateLargerScale', GetCVarDefault('nameplateLargerScale'));
    C_CVar.SetCVar('nameplateGlobalScale', GetCVarDefault('nameplateGlobalScale'));
    C_CVar.SetCVar('nameplateSelectedScale', GetCVarDefault('nameplateSelectedScale'));
    C_CVar.SetCVar('nameplateSelfScale', GetCVarDefault('nameplateSelfScale'));

    -- Insets
    C_CVar.SetCVar('nameplateLargeTopInset', GetCVarDefault('nameplateLargeTopInset'));
    C_CVar.SetCVar('nameplateLargeBottomInset', GetCVarDefault('nameplateLargeBottomInset'));
    C_CVar.SetCVar('nameplateOtherTopInset', GetCVarDefault('nameplateOtherTopInset'));
    C_CVar.SetCVar('nameplateOtherBottomInset', GetCVarDefault('nameplateOtherBottomInset'));
    C_CVar.SetCVar('nameplateSelfTopInset', GetCVarDefault('nameplateSelfTopInset'));
    C_CVar.SetCVar('nameplateSelfBottomInset', GetCVarDefault('nameplateSelfBottomInset'));

    C_CVar.SetCVar('nameplateShowEnemyMinions', GetCVarDefault('nameplateShowEnemyMinions'));
    C_CVar.SetCVar('nameplateShowEnemyGuardians', GetCVarDefault('nameplateShowEnemyGuardians'));
    C_CVar.SetCVar('nameplateShowEnemyMinus', GetCVarDefault('nameplateShowEnemyMinus'));
    C_CVar.SetCVar('nameplateShowEnemyPets', GetCVarDefault('nameplateShowEnemyPets'));
    C_CVar.SetCVar('nameplateShowEnemyTotems', GetCVarDefault('nameplateShowEnemyTotems'));
    C_CVar.SetCVar('nameplateShowFriendlyMinions', GetCVarDefault('nameplateShowFriendlyMinions'));
    C_CVar.SetCVar('nameplateShowFriendlyGuardians', GetCVarDefault('nameplateShowFriendlyGuardians'));
    C_CVar.SetCVar('nameplateShowFriendlyNPCs', GetCVarDefault('nameplateShowFriendlyNPCs'));
    C_CVar.SetCVar('nameplateShowFriendlyPets', GetCVarDefault('nameplateShowFriendlyPets'));
    C_CVar.SetCVar('nameplateShowFriendlyTotems', GetCVarDefault('nameplateShowFriendlyTotems'));

    C_CVar.SetCVar('NameplatePersonalClickThrough', GetCVarDefault('NameplatePersonalClickThrough'));

    -- Alpha
    C_CVar.SetCVar('nameplateSelectedAlpha', GetCVarDefault('nameplateSelectedAlpha'));
    C_CVar.SetCVar('nameplateMaxAlpha', GetCVarDefault('nameplateMaxAlpha'));
    C_CVar.SetCVar('nameplateMaxAlphaDistance', GetCVarDefault('nameplateMaxAlphaDistance'));
    C_CVar.SetCVar('nameplateMinAlpha', GetCVarDefault('nameplateMinAlpha'));
    C_CVar.SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'));
    C_CVar.SetCVar('nameplateOccludedAlphaMult', GetCVarDefault('nameplateOccludedAlphaMult'));
end

Module.CVarsReset = CVarsReset;

local function CVarsUpdate()
    C_CVar.SetCVar('nameplateShowOnlyNames', O.db.name_only_friendly_enabled and 1 or 0);

    C_CVar.SetCVar('nameplateMotion', O.db.motion - 1);
    C_CVar.SetCVar('nameplateMotionSpeed', O.db.motion_speed);

    C_CVar.SetCVar('ShowClassColorInFriendlyNameplate', O.db.health_bar_class_color_friendly and 1 or 0);
    C_CVar.SetCVar('ShowClassColorInNameplate', O.db.health_bar_class_color_enemy and 1 or 0);

    C_CVar.SetCVar('nameplateOverlapH', O.db.overlap_h);
    C_CVar.SetCVar('nameplateOverlapV', O.db.overlap_v);

    C_CVar.SetCVar('nameplateShowFriends', O.db.show_friendly and 1 or 0);
    C_CVar.SetCVar('nameplateShowEnemies', O.db.show_enemy and 1 or 0);

    C_CVar.SetCVar('nameplateShowSelf', O.db.show_personal and 1 or 0);
    C_CVar.SetCVar('NameplatePersonalShowAlways', O.db.show_personal_always and 1 or 0);
    C_CVar.SetCVar('nameplateResourceOnTarget', O.db.show_personal_resource_ontarget and 1 or 0);

    C_CVar.SetCVar('nameplateShowDebuffsOnFriendly', O.db.auras_show_debuffs_on_friendly and 1 or 0);

    -- Scales
    C_CVar.SetCVar('nameplateLargerScale', O.db.scale_large);
    C_CVar.SetCVar('nameplateGlobalScale', O.db.scale_global);
    C_CVar.SetCVar('nameplateSelectedScale', O.db.scale_selected);
    C_CVar.SetCVar('nameplateSelfScale', O.db.scale_self);

    -- Insets
    C_CVar.SetCVar('nameplateLargeTopInset', O.db.large_top_inset);
    C_CVar.SetCVar('nameplateLargeBottomInset', O.db.large_bottom_inset);
    C_CVar.SetCVar('nameplateOtherTopInset', O.db.other_top_inset);
    C_CVar.SetCVar('nameplateOtherBottomInset', O.db.other_bottom_inset);
    C_CVar.SetCVar('nameplateSelfTopInset', O.db.self_top_inset);
    C_CVar.SetCVar('nameplateSelfBottomInset', O.db.self_bottom_inset);

    C_CVar.SetCVar('nameplateShowEnemyMinions', O.db.show_enemy_minions and 1 or 0);
    C_CVar.SetCVar('nameplateShowEnemyGuardians', O.db.show_enemy_guardians and 1 or 0);
    C_CVar.SetCVar('nameplateShowEnemyMinus', O.db.show_enemy_minus and 1 or 0);
    C_CVar.SetCVar('nameplateShowEnemyPets', O.db.show_enemy_pets and 1 or 0);
    C_CVar.SetCVar('nameplateShowEnemyTotems', O.db.show_enemy_totems and 1 or 0);
    C_CVar.SetCVar('nameplateShowFriendlyMinions', O.db.show_friendly_minions and 1 or 0);
    C_CVar.SetCVar('nameplateShowFriendlyGuardians', O.db.show_friendly_guardians and 1 or 0);
    C_CVar.SetCVar('nameplateShowFriendlyNPCs', O.db.show_friendly_npcs and 1 or 0);
    C_CVar.SetCVar('nameplateShowFriendlyPets', O.db.show_friendly_pets and 1 or 0);
    C_CVar.SetCVar('nameplateShowFriendlyTotems', O.db.show_friendly_totems and 1 or 0);

    C_CVar.SetCVar('NameplatePersonalClickThrough', O.db.size_self_click_through and 1 or 0);

    -- Alpha
    C_CVar.SetCVar('nameplateSelectedAlpha', O.db.selected_alpha);
    C_CVar.SetCVar('nameplateMaxAlpha', O.db.max_alpha);
    C_CVar.SetCVar('nameplateMaxAlphaDistance', O.db.max_alpha_distance);
    C_CVar.SetCVar('nameplateMinAlpha', O.db.min_alpha);
    C_CVar.SetCVar('nameplateMinAlphaDistance', O.db.min_alpha_distance);
    C_CVar.SetCVar('nameplateOccludedAlphaMult', O.db.occluded_alpha_mult);
end

Module.CVarsUpdate = CVarsUpdate;

local neededStr = 'nameplate';
local function HookSetCVar(name, value)
    if not string_find(string_lower(name), neededStr) then
        return;
    end

    value = tostring(value);

    if name == 'ShowClassColorInFriendlyNameplate' then
        O.frame.Right.HealthBar.health_bar_class_color_friendly:SetChecked(value == '1');
        O.db.health_bar_class_color_friendly = value == '1';
    elseif name == 'ShowClassColorInNameplate' then
        O.frame.Right.HealthBar.health_bar_class_color_enemy:SetChecked(value == '1');
        O.db.health_bar_class_color_enemy = value == '1';
    elseif name == 'nameplateOverlapH' then
        O.frame.Right.Sizes.overlap_h:SetValue(tonumber(value));
        O.db.overlap_h = tonumber(value);
    elseif name == 'nameplateOverlapV' then
        O.frame.Right.Sizes.overlap_v:SetValue(tonumber(value));
        O.db.overlap_v = tonumber(value);
    elseif name == 'nameplateMotion' then
        O.frame.Right.Visibility.motion:SetValue(tonumber(value) + 1);
        O.db.motion = tonumber(value) + 1;
    elseif name == 'nameplateMotionSpeed' then
        O.frame.Right.Visibility.motion_speed:SetValue(tonumber(value));
        O.db.motion_speed = tonumber(value);
    elseif name == 'nameplateShowEnemies' then
        O.frame.Right.Visibility.show_enemy:SetChecked(value == '1');
        O.db.show_enemy = value == '1';
    elseif name == 'nameplateShowFriends' then
        O.frame.Right.Visibility.show_friendly:SetChecked(value == '1');
        O.db.show_friendly = value == '1';
    elseif name == 'nameplateShowSelf' then
        O.frame.Right.Visibility.show_personal:SetChecked(value == '1');
        O.db.show_personal = value == '1';
    elseif name == 'nameplateShowEnemyMinions' then
        O.frame.Right.Visibility.show_enemy_minions:SetChecked(value == '1');
        O.db.show_enemy_minions = value == '1';
    elseif name == 'nameplateShowEnemyGuardians' then
        O.frame.Right.Visibility.show_enemy_guardians:SetChecked(value == '1');
        O.db.show_enemy_guardians = value == '1';
    elseif name == 'nameplateShowEnemyMinus' then
        O.frame.Right.Visibility.show_enemy_minus:SetChecked(value == '1');
        O.db.show_enemy_minus = value == '1';
    elseif name == 'nameplateShowEnemyPets' then
        O.frame.Right.Visibility.show_enemy_pets:SetChecked(value == '1');
        O.db.show_enemy_pets = value == '1';
    elseif name == 'nameplateShowEnemyTotems' then
        O.frame.Right.Visibility.show_enemy_totems:SetChecked(value == '1');
        O.db.show_enemy_totems = value == '1';
    elseif name == 'nameplateShowFriendlyMinions' then
        O.frame.Right.Visibility.show_friendly_minions:SetChecked(value == '1');
        O.db.show_friendly_minions = value == '1';
    elseif name == 'nameplateShowFriendlyGuardians' then
        O.frame.Right.Visibility.show_friendly_guardians:SetChecked(value == '1');
        O.db.show_friendly_guardians = value == '1';
    elseif name == 'nameplateShowFriendlyNPCs' then
        O.frame.Right.Visibility.show_friendly_npcs:SetChecked(value == '1');
        O.db.show_friendly_npcs = value == '1';
    elseif name == 'nameplateShowFriendlyPets' then
        O.frame.Right.Visibility.show_friendly_pets:SetChecked(value == '1');
        O.db.show_friendly_pets = value == '1';
    elseif name == 'nameplateShowFriendlyTotems' then
        O.frame.Right.Visibility.show_friendly_totems:SetChecked(value == '1');
        O.db.show_friendly_totems = value == '1';
    elseif name == 'NameplatePersonalShowAlways' then
        O.frame.Right.Visibility.show_personal_always:SetChecked(value == '1');
        O.db.show_personal_always = value == '1';
    elseif name == 'nameplateResourceOnTarget' then
        O.frame.Right.Visibility.show_personal_resource_ontarget:SetChecked(value == '1');
        O.db.show_personal_resource_ontarget = value == '1';
    elseif name == 'nameplateShowDebuffsOnFriendly' then
        O.frame.Right.Auras.auras_show_debuffs_on_friendly:SetChecked(value == '1');
        O.db.auras_show_debuffs_on_friendly = value == '1';
    elseif name == 'nameplateLargerScale' then
        O.frame.Right.Sizes.scale_large:SetValue(tonumber(value));
        O.db.scale_large = tonumber(value);
    elseif name == 'nameplateGlobalScale' then
        O.frame.Right.Sizes.scale_global:SetValue(tonumber(value));
        O.db.scale_global = tonumber(value);
    elseif name == 'nameplateSelectedScale' then
        O.frame.Right.Sizes.scale_selected:SetValue(tonumber(value));
        O.db.scale_selected = tonumber(value);
    elseif name == 'nameplateSelfScale' then
        O.frame.Right.Sizes.scale_self:SetValue(tonumber(value));
        O.db.scale_self = tonumber(value);
    elseif name == 'nameplateLargeTopInset' then
        O.frame.Right.Sizes.large_top_inset:SetValue(tonumber(value));
        O.db.large_top_inset = tonumber(value);
    elseif name == 'nameplateLargeBottomInset' then
        O.frame.Right.Sizes.large_bottom_inset:SetValue(tonumber(value));
        O.db.large_bottom_inset = tonumber(value);
    elseif name == 'nameplateOtherTopInset' then
        O.frame.Right.Sizes.other_top_inset:SetValue(tonumber(value));
        O.db.other_top_inset = tonumber(value);
    elseif name == 'nameplateOtherBottomInset' then
        O.frame.Right.Sizes.other_bottom_inset:SetValue(tonumber(value));
        O.db.other_bottom_inset = tonumber(value);
    elseif name == 'nameplateSelfTopInset' then
        O.frame.Right.Sizes.self_top_inset:SetValue(tonumber(value));
        O.db.self_top_inset = tonumber(value);
    elseif name == 'nameplateSelfBottomInset' then
        O.frame.Right.Sizes.self_bottom_inset:SetValue(tonumber(value));
        O.db.self_bottom_inset = tonumber(value);
    elseif name == 'nameplateShowOnlyNames' then
        O.frame.Right.Visibility.name_only_friendly_enabled:SetChecked(value == '1');
        O.db.name_only_friendly_enabled = value == '1';
    elseif name == 'NameplatePersonalClickThrough' then
        O.frame.Right.Sizes.size_self_click_through:SetChecked(value == '1');
        O.db.size_self_click_through = value == '1';
    elseif name == 'nameplateSelectedAlpha' then
        O.frame.Right.Visibility.selected_alpha:SetValue(tonumber(value));
        O.db.selected_alpha = tonumber(value);
    elseif name == 'nameplateMaxAlpha' then
        O.frame.Right.Visibility.max_alpha:SetValue(tonumber(value));
        O.db.max_alpha = tonumber(value);
    elseif name == 'nameplateMaxAlphaDistance' then
        O.frame.Right.Visibility.max_alpha_distance:SetValue(tonumber(value));
        O.db.max_alpha_distance = tonumber(value);
    elseif name == 'nameplateMinAlpha' then
        O.frame.Right.Visibility.min_alpha:SetValue(tonumber(value));
        O.db.min_alpha = tonumber(value);
    elseif name == 'nameplateMinAlphaDistance' then
        O.frame.Right.Visibility.min_alpha_distance:SetValue(tonumber(value));
        O.db.min_alpha_distance = tonumber(value);
    elseif name == 'nameplateOccludedAlphaMult' then
        O.frame.Right.Visibility.occluded_alpha_mult:SetValue(tonumber(value));
        O.db.occluded_alpha_mult = tonumber(value);
    elseif name == 'NamePlateVerticalScale' or name == 'NamePlateHorizontalScale' then
        C_Timer.After(0.25, function()
            UpdateSizesSafe();
        end);
    end
end

local function ResetNameplateData(unitframe)
    unitframe.data.healthCurrent = 0;

    unitframe.data.reaction = nil;

    unitframe.data.unitType = nil;
    unitframe.data.commonUnitType = nil;
    unitframe.data.commonReaction = nil;

    unitframe.data.npcId = 0;
    unitframe.data.creatureType = nil;

    unitframe.data.subLabel = nil;
    unitframe.data.guild = nil;
    unitframe.data.realm = nil;

    unitframe.data.className = nil;

    unitframe.data.nameAbbr = '';
    unitframe.data.namePVP = nil;
    unitframe.data.nameWoRealm = nil;
    unitframe.data.nameTranslit        = nil;
    unitframe.data.nameTranslitWoRealm = nil;
    unitframe.data.nameTranslitPVP     = nil;
end

function Module:NAME_PLATE_UNIT_ADDED(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);
    local unitframe = nameplate and nameplate.UnitFrame;

    if not nameplate then
        return;
    end

    NP[nameplate] = unitframe;

    NP[nameplate].data = NP[nameplate].data or {};

    NP[nameplate].data.unit      = unit;
    NP[nameplate].data.unitGUID  = UnitGUID(unit);
    NP[nameplate].data.isPlayer  = UnitIsPlayer(unit);
    NP[nameplate].data.className = NP[nameplate].data.isPlayer and UnitClassBase(unit) or nil;

    NP[nameplate].data.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit);

    NP[nameplate].data.npcId    = not NP[nameplate].data.isPlayer and GetNpcIDByGUID(NP[nameplate].data.unitGUID, true) or 0;

    NP[nameplate].data.name     = GetUnitName(unit, true);
    NP[nameplate].data.nameAbbr = '';

    NP[nameplate].data.subLabel = not NP[nameplate].data.isPlayer and GetNpcSubLabelByID(NP[nameplate].data.npcId) or nil;
    if NP[nameplate].data.subLabel == UNKNOWN or string_find(NP[nameplate].data.subLabel or '', '??', 1, true) then
        NP[nameplate].data.subLabel = nil;
    end

    NP[nameplate].data.healthCurrent = UnitHealth(unit) or 0;
    NP[nameplate].data.healthMax     = math_max(UnitHealthMax(unit) or 1, 1);
    NP[nameplate].data.healthPerF    = 100 * (NP[nameplate].data.healthCurrent / NP[nameplate].data.healthMax);
    NP[nameplate].data.healthPer     = math_ceil(NP[nameplate].data.healthPerF);

    NP[nameplate].data.absorbAmount = UnitGetTotalAbsorbs(unit) or 0;

    NP[nameplate].data.level, NP[nameplate].data.classification, NP[nameplate].data.diff = GetUnitLevel(unit);
    NP[nameplate].data.colorR, NP[nameplate].data.colorG, NP[nameplate].data.colorB      = GetUnitColor(unit, 2);

    NP[nameplate].data.reaction     = UnitReaction(PLAYER_UNIT, unit);
    NP[nameplate].data.factionGroup = UnitFactionGroup(unit);

    NP[nameplate].data.minus = UnitClassification(unit) == 'minus';

    NP[nameplate].data.creatureType = not NP[nameplate].data.isPlayer and UnitCreatureType(unit) or nil;

    NP[nameplate].data.canAttack = UnitCanAttack(PLAYER_UNIT, unit);

    if UnitIsUnit(unit, PLAYER_UNIT) then
        NP[nameplate].data.unitType = 'SELF';
        NP[nameplate].data.commonUnitType = 'SELF';
        NP[nameplate].data.commonReaction = 'FRIENDLY';
    elseif UnitIsPVPSanctuary(unit) then
        NP[nameplate].data.unitType = 'FRIENDLY_PLAYER';
        NP[nameplate].data.commonUnitType = 'PLAYER';
        NP[nameplate].data.commonReaction = 'FRIENDLY';
    elseif not UnitIsEnemy(PLAYER_UNIT, unit) and (not NP[nameplate].data.reaction or NP[nameplate].data.reaction > 4) then
        NP[nameplate].data.unitType = (NP[nameplate].data.isPlayer and 'FRIENDLY_PLAYER') or 'FRIENDLY_NPC';
        NP[nameplate].data.commonUnitType = (NP[nameplate].data.isPlayer and 'PLAYER') or 'NPC';
        NP[nameplate].data.commonReaction = 'FRIENDLY';
    else
        NP[nameplate].data.unitType = (NP[nameplate].data.isPlayer and 'ENEMY_PLAYER') or 'ENEMY_NPC';
        NP[nameplate].data.commonUnitType = (NP[nameplate].data.isPlayer and 'PLAYER') or 'NPC';
        NP[nameplate].data.commonReaction = 'ENEMY';
    end

    if NP[nameplate].data.unitType == 'FRIENDLY_PLAYER' then
        NP[nameplate].data.guild   = UnitInGuild(unit);
        NP[nameplate].data.nameWoRealm, NP[nameplate].data.realm = UnitName(unit);
        NP[nameplate].data.namePVP = UnitPVPName(unit);
    end

    if NP[nameplate].data.unitType == 'ENEMY_PLAYER' then
        NP[nameplate].data.nameWoRealm, NP[nameplate].data.realm = UnitName(unit);
    end

    if NP[nameplate].data.commonUnitType == 'PLAYER' then
        NP[nameplate].data.nameTranslit        = LT:Transliterate(NP[nameplate].data.name);
        NP[nameplate].data.nameTranslitWoRealm = LT:Transliterate(NP[nameplate].data.nameWoRealm);
        NP[nameplate].data.nameTranslitPVP     = LT:Transliterate(NP[nameplate].data.namePVP);
    end

    if NP[nameplate].data.widgetsOnly then
        NP[nameplate].data.previousType = nil;
    else
        NP[nameplate].data.previousType = NP[nameplate].data.unitType;
    end

    NP[nameplate].isActive = true;
    S:ForAllNameplateModules('UnitAdded', NP[nameplate]);

    if NP[nameplate].data.widgetsOnly then
        NP[nameplate].isActive = false;
        ResetNameplateData(NP[nameplate]);
        S:ForAllNameplateModules('UnitRemoved', NP[nameplate]);
    end
end

function Module:NAME_PLATE_UNIT_REMOVED(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    NP[nameplate].isActive = false;
    ResetNameplateData(NP[nameplate]);
    S:ForAllNameplateModules('UnitRemoved', NP[nameplate]);
end

function Module:UNIT_AURA(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    S:ForAllNameplateModules('UnitAura', NP[nameplate]);
end

function Module:PLAYER_LOGIN()
    CVarsUpdate();

    C_Timer.After(0.25, function()
        UpdateSizesSafe();
        self:UpdateAll();
    end);
end

function Module:PLAYER_ENTERING_WORLD()
    self:UpdateAll();
end

function Module:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent('PLAYER_REGEN_ENABLED');

    UpdateSizesSafe();
end

function Module:UpdateLocalConfig()
    NAME_TEXT_ENABLED               = O.db.name_text_enabled;
    NAME_ONLY_FRIENDLY_ENABLED      = O.db.name_only_friendly_enabled;
    NAME_ONLY_FRIENDLY_PLAYERS_ONLY = O.db.name_only_friendly_players_only;
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', UpdateHealth);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateMaxHealth', UpdateLevel);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealPrediction', UpdateAbsorbs);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', UpdateStatus);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateWidgetsOnlyMode', UpdateWidgetStatus);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateClassificationIndicator', UpdateClassification);

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_ENTERING_WORLD');
    self:RegisterEvent('NAME_PLATE_UNIT_ADDED');
    self:RegisterEvent('NAME_PLATE_UNIT_REMOVED');
    self:RegisterEvent('UNIT_AURA');

    hooksecurefunc(C_CVar, 'SetCVar', HookSetCVar);

    self:UpdateAll();
end
