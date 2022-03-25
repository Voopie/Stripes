local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Custom');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local pairs, table_wipe, math_max = pairs, wipe, math.max;

-- WoW API
local CooldownFrame_Set, GetCVarBool, UnitIsUnit, AuraUtil_ForEachAura, AuraUtil_ShouldSkipAuraUpdate = CooldownFrame_Set, GetCVarBool, UnitIsUnit, AuraUtil.ForEachAura, AuraUtil.ShouldSkipAuraUpdate;

-- Stripes API
local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SCALE, SQUARE, OFFSET_X, OFFSET_Y, BUFFFRAME_OFFSET_Y;
local BORDER_HIDE, BORDER_COLOR;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SPACING_X;
local DRAW_EDGE, DRAW_SWIPE;
local AURAS_DIRECTION, AURAS_MAX_DISPLAY;

local StripesAurasCustomCooldownFont = CreateFont('StripesAurasCustomCooldownFont');
local StripesAurasCustomCountFont    = CreateFont('StripesAurasCustomCountFont');

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';
local filterHelpful = 'HELPFUL';
local filterHarmful = 'HARMFUL';

local playerUnits = {
    ['player']  = true,
    ['pet']     = true,
    ['vehicle'] = true,
};

local MAX_OFFSET_Y = -9;

local function CreateAnchor(unitframe)
    if unitframe.AurasCustom then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasCustom', unitframe);
    frame:SetPoint('RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
    frame:SetHeight(14);

    frame.buffList = {};
    frame.buffCompact = {};

    unitframe.AurasCustom = frame;
end

local function UpdateAnchor(unitframe)
    unitframe.AurasCustom:ClearAllPoints();

    if unitframe.AurasMythicPlus and unitframe.AurasMythicPlus:IsShown() then
        PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.AurasMythicPlus, 'TOP', 0, 4);
    else
        local unit = unitframe.data.unit;

        if unit and ShouldShowName(unitframe) then
            local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;
            local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y) + showMechanicOnTarget) or showMechanicOnTarget;
            PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
        else
            local offset = unitframe.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
            PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
        end
    end

    PixelUtil.SetPoint(unitframe.AurasCustom, AURAS_DIRECTION == 1 and 'LEFT' or 'RIGHT', unitframe.healthBar, AURAS_DIRECTION == 1 and 'LEFT' or 'RIGHT', OFFSET_X, 0);
end

local function FilterShouldShowBuff(name, spellId, caster)
    local spellData = O.db.auras_custom_data[spellId] or O.db.auras_custom_data[name];

    if spellData and spellData.enabled and (not spellData.own_only or (playerUnits[caster] and spellData.own_only)) then
        return true;
    end

    return false;
end

local function AuraCouldDisplayAsBuff(auraInfo)
    return FilterShouldShowBuff(auraInfo.name, auraInfo.spellId, auraInfo.sourceUnit);
end

local function Update(unitframe)
    if not ENABLED or unitframe.data.unitType == 'SELF' then
        unitframe.AurasCustom:SetShown(false);
        return;
    end

    unitframe.AurasCustom.unit   = unitframe.data.unit;
    unitframe.AurasCustom.filter = filterHarmful;

    table_wipe(unitframe.AurasCustom.buffCompact);

    local buffIndex = 1;
    local index = 1;

    local _, buffName, texture, count, duration, expirationTime, spellId, source;
    AuraUtil_ForEachAura(unitframe.AurasCustom.unit, filterHelpful, BUFF_MAX_DISPLAY, function(...)
        buffName, texture, count, _, duration, expirationTime, source, _, _, spellId = ...;

        if FilterShouldShowBuff(buffName, spellId, source) then
            local cCount = count == 0 and 1 or count;

            if not unitframe.AurasCustom.buffCompact[spellId] then
                unitframe.AurasCustom.buffCompact[spellId] = {
                    index          = index,
                    buffName       = buffName,
                    texture        = texture,
                    count          = cCount,
                    duration       = duration,
                    expirationTime = expirationTime,
                };
            else
                unitframe.AurasCustom.buffCompact[spellId].count          = unitframe.AurasCustom.buffCompact[spellId].count + cCount;
                unitframe.AurasCustom.buffCompact[spellId].duration       = duration;
                unitframe.AurasCustom.buffCompact[spellId].expirationTime = expirationTime;
            end
        end

        index = index + 1;

        return index > BUFF_MAX_DISPLAY;
    end);

    AuraUtil_ForEachAura(unitframe.AurasCustom.unit, filterHarmful, BUFF_MAX_DISPLAY, function(...)
        buffName, texture, count, _, duration, expirationTime, source, _, _, spellId = ...;

        if FilterShouldShowBuff(buffName, spellId, source) then
            local cCount = count == 0 and 1 or count;

            if not unitframe.AurasCustom.buffCompact[spellId] then
                unitframe.AurasCustom.buffCompact[spellId] = {
                    index          = index,
                    buffName       = buffName,
                    texture        = texture,
                    count          = cCount,
                    duration       = duration,
                    expirationTime = expirationTime,
                };
            else
                unitframe.AurasCustom.buffCompact[spellId].count          = unitframe.AurasCustom.buffCompact[spellId].count + cCount;
                unitframe.AurasCustom.buffCompact[spellId].duration       = duration;
                unitframe.AurasCustom.buffCompact[spellId].expirationTime = expirationTime;
            end
        end

        index = index + 1;

        return index > BUFF_MAX_DISPLAY;
    end);

    local aura;
    for _, spell in pairs(unitframe.AurasCustom.buffCompact) do
        aura = unitframe.AurasCustom.buffList[buffIndex];

        if not aura then
            aura = CreateFrame('Frame', nil, unitframe.AurasCustom, 'NameplateBuffButtonTemplate');
            aura:SetMouseClickEnabled(false);
            aura.layoutIndex = buffIndex;

            aura:SetScale(SCALE);

            if SQUARE then
                aura:SetSize(20, 20);
                aura.Icon:SetSize(18, 18);
                aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
            end

            aura.Cooldown:SetDrawEdge(DRAW_EDGE);
            aura.Cooldown:SetDrawSwipe(DRAW_SWIPE);
            aura.Cooldown:SetCountdownFont('StripesAurasCustomCooldownFont');
            aura.Cooldown:GetRegions():ClearAllPoints();
            aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
            aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
            aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

            aura.CountFrame.Count:ClearAllPoints();
            aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
            aura.CountFrame.Count:SetFontObject(StripesAurasCustomCountFont);
            aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

            aura.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
            aura.Border:SetShown(not BORDER_HIDE);

            if MASQUE_SUPPORT and Stripes.Masque then
                Stripes.MasqueAurasCustomGroup:RemoveButton(aura);
                Stripes.MasqueAurasCustomGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
            end

            unitframe.AurasCustom.buffList[buffIndex] = aura;
        end

        aura:ClearAllPoints();

        if AURAS_DIRECTION == 1 then
            aura:SetPoint('TOPLEFT', (buffIndex - 1) * (20 + SPACING_X), 0);
        else
            aura:SetPoint('TOPRIGHT', -((buffIndex - 1) * (20 + SPACING_X)), 0);
        end

        aura:SetID(spell.index);

        aura.Icon:SetTexture(spell.texture);

        if spell.count > 1 then
            aura.CountFrame.Count:SetText(spell.count);
            aura.CountFrame.Count:SetShown(true);
        else
            aura.CountFrame.Count:SetShown(false);
        end

        CooldownFrame_Set(aura.Cooldown, spell.expirationTime - spell.duration, spell.duration, spell.duration > 0, DRAW_EDGE);

        aura:SetShown(true);

        buffIndex = buffIndex + 1;

        if buffIndex > AURAS_MAX_DISPLAY then
            break;
        end
    end

    for i = buffIndex, BUFF_MAX_DISPLAY do
        if unitframe.AurasCustom.buffList[i] then
            unitframe.AurasCustom.buffList[i]:SetShown(false);
        else
            break;
        end
    end

    if buffIndex > 1 then
        if not unitframe.AurasCustom:IsShown() then
            unitframe.AurasCustom:SetShown(true);
        end

        UpdateAnchor(unitframe);
    else
        if unitframe.AurasCustom:IsShown() then
            unitframe.AurasCustom:SetShown(false);
        end
    end
end

local function OnUnitAuraUpdate(unitframe, isFullUpdate, updatedAuraInfos)
    if AuraUtil_ShouldSkipAuraUpdate(isFullUpdate, updatedAuraInfos, AuraCouldDisplayAsBuff) then
        return;
    end

    Update(unitframe);
end

local function UpdateStyle(unitframe)
    for _, aura in ipairs(unitframe.AurasCustom.buffList) do
        if Stripes.Masque then
            if MASQUE_SUPPORT then
                Stripes.MasqueAurasCustomGroup:RemoveButton(aura);
                Stripes.MasqueAurasCustomGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);

                aura.Border:SetDrawLayer('BACKGROUND');
            else
                Stripes.MasqueAurasCustomGroup:RemoveButton(aura);

                aura.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
                aura.Border:SetDrawLayer('BACKGROUND');

                aura.Icon:SetDrawLayer('ARTWORK');

                aura.Cooldown:ClearAllPoints();
                aura.Cooldown:SetAllPoints();
            end
        end

        aura:SetScale(SCALE);

        if SQUARE then
            aura:SetSize(20, 20);
            aura.Icon:SetSize(18, 18);
            aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
        else
            aura:SetSize(20, 14);
            aura.Icon:SetSize(18, 12);
            aura.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6);
        end

        aura.Border:SetShown(not BORDER_HIDE);
        aura.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);

        aura.Cooldown:SetDrawEdge(DRAW_EDGE);
        aura.Cooldown:SetDrawSwipe(DRAW_SWIPE);
        aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
        aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

        aura.Cooldown:GetRegions():ClearAllPoints();
        aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
        aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);

        aura.CountFrame.Count:ClearAllPoints();
        aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
        aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);
    end
end

function Module:UnitAdded(unitframe)
    CreateAnchor(unitframe);
    OnUnitAuraUpdate(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasCustom then
        unitframe.AurasCustom:SetShown(false);
    end
end

function Module:UnitAura(unitframe, isFullUpdate, updatedAuraInfos)
    OnUnitAuraUpdate(unitframe, isFullUpdate, updatedAuraInfos);
end

function Module:Update(unitframe)
    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasCustomGroup:ReSkin();
    end

    Update(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    MASQUE_SUPPORT = O.db.auras_masque_support;

    ENABLED              = O.db.auras_custom_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_custom_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    BORDER_HIDE     = O.db.auras_border_hide;
    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_custom_border_color[1];
    BORDER_COLOR[2] = O.db.auras_custom_border_color[2];
    BORDER_COLOR[3] = O.db.auras_custom_border_color[3];
    BORDER_COLOR[4] = O.db.auras_custom_border_color[4] or 1;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_custom_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_custom_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_custom_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_custom_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_custom_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_custom_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_custom_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_custom_count_offset_y;

    SCALE  = O.db.auras_custom_scale;
    SQUARE = O.db.auras_square;
    OFFSET_X = O.db.auras_custom_offset_x;
    OFFSET_Y = O.db.auras_custom_offset_y;
    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_custom_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_custom_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_custom_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_custom_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_custom_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_custom_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_custom_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_custom_count_color[4] or 1;

    SPACING_X = O.db.auras_custom_spacing_x or 2;

    DRAW_EDGE  = O.db.auras_custom_draw_edge;
    DRAW_SWIPE = O.db.auras_custom_draw_swipe;

    AURAS_DIRECTION = O.db.auras_custom_direction;
    AURAS_MAX_DISPLAY = O.db.auras_custom_max_display;

    UpdateFontObject(StripesAurasCustomCooldownFont, O.db.auras_custom_cooldown_font_value, O.db.auras_custom_cooldown_font_size, O.db.auras_custom_cooldown_font_flag, O.db.auras_custom_cooldown_font_shadow);
    UpdateFontObject(StripesAurasCustomCountFont, O.db.auras_custom_count_font_value, O.db.auras_custom_count_font_size, O.db.auras_custom_count_font_flag, O.db.auras_custom_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdateAnchor);
end