local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_MythicPlus');
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
local SCALE, SQUARE, BUFFFRAME_OFFSET_Y;
local OFFSET_X, OFFSET_Y;
local BORDER_HIDE, BORDER_COLOR;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SPACING_X;
local DRAW_EDGE, DRAW_SWIPE;
local AURAS_DIRECTION, AURAS_MAX_DISPLAY;

local StripesAurasMythicPlusCooldownFont = CreateFont('StripesAurasMythicPlusCooldownFont');
local StripesAurasMythicPlusCountFont    = CreateFont('StripesAurasMythicPlusCountFont');

local HelpfulList = {
    [226510] = true, -- Mythic Plus Affix: Sanguine
    [209859] = true, -- Mythic Plus Affix: Bolstering
    [343502] = true, -- Mythic Plus Affix: Inspiring
    [228318] = true, -- Mythic Plus Affix: Raging

    -- Shadowlands
    [324085] = true, -- Theater of Pain (Enrage)
    [333241] = true, -- Theater of Pain (Raging Tantrum)
    [331510] = true, -- Theater of Pain (Death Wish)
    [333227] = true, -- De Other Side (Undying Rage)
    [334800] = true, -- De Other Side (Enrage)
    [321220] = true, -- Sanguine Depths (Frenzy)
    [322569] = true, -- Mists of Tirna Scithe (Hand of Thros)
    [326450] = true, -- Halls of Atonement (Loyal Beasts)
    [328015] = true, -- Plaguefall (Wonder Grow)
    [343470] = true, -- The Necrotic Wake (Skeletal Marauder)
};

local HarmfulList = {
    [323059] = true, -- Mists of Tirna Scithe (Droman's Wrath)
};

local PlayerState = D.Player.State;
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local filterHelpful = 'HELPFUL';
local filterHarmful = 'HARMFUL';
local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';

local MAX_OFFSET_Y = -9;

local function CreateAnchor(unitframe)
    if unitframe.AurasMythicPlus then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasMythicPlus', unitframe);
    frame:SetPoint('RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
    frame:SetHeight(14);

    frame.buffList = {};
    frame.buffCompact = {};

    unitframe.AurasMythicPlus = frame;
end

local function UpdateAnchor(unitframe)
    local unit = unitframe.data.unit;

    unitframe.AurasMythicPlus:ClearAllPoints();

    if unit and ShouldShowName(unitframe) then
        local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;
        local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y) + showMechanicOnTarget) or showMechanicOnTarget;
        PixelUtil.SetPoint(unitframe.AurasMythicPlus, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
    else
        local offset = unitframe.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
        PixelUtil.SetPoint(unitframe.AurasMythicPlus, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
    end

    PixelUtil.SetPoint(unitframe.AurasMythicPlus, AURAS_DIRECTION == 1 and 'LEFT' or 'RIGHT', unitframe.healthBar, AURAS_DIRECTION == 1 and 'LEFT' or 'RIGHT', OFFSET_X, 0);
end

local function FilterShouldShowBuff(spellId, isHelpful, isHarmful)
    if isHelpful and HelpfulList[spellId] then
        return true;
    elseif isHarmful and HarmfulList[spellId] then
        return true;
    end

    return false;
end

local function AuraCouldDisplayAsBuff(auraInfo)
    return FilterShouldShowBuff(auraInfo.spellId, auraInfo.isHelpful, auraInfo.isHarmful);
end

local function Update(unitframe)
    if not ENABLED or not PlayerState.inMythic or not unitframe.data.unit or unitframe.data.unitType == 'SELF' then
        unitframe.AurasMythicPlus:SetShown(false);
        return;
    end

    unitframe.AurasMythicPlus.unit   = unitframe.data.unit;
    unitframe.AurasMythicPlus.filter = filterHelpful;

    table_wipe(unitframe.AurasMythicPlus.buffCompact);

    local buffIndex = 1;
    local index = 1;

    local _, buffName, texture, count, duration, expirationTime, spellId;
    AuraUtil_ForEachAura(unitframe.AurasMythicPlus.unit, filterHelpful, BUFF_MAX_DISPLAY, function(...)
        buffName, texture, count, _, duration, expirationTime, _, _, _, spellId = ...;

        if FilterShouldShowBuff(spellId, true, false) then
            local cCount = count == 0 and 1 or count;

            if not unitframe.AurasMythicPlus.buffCompact[spellId] then
                unitframe.AurasMythicPlus.buffCompact[spellId] = {
                    index          = index,
                    buffName       = buffName,
                    texture        = texture,
                    count          = cCount,
                    duration       = duration,
                    expirationTime = expirationTime,
                };
            else
                unitframe.AurasMythicPlus.buffCompact[spellId].count          = unitframe.AurasMythicPlus.buffCompact[spellId].count + cCount;
                unitframe.AurasMythicPlus.buffCompact[spellId].duration       = duration;
                unitframe.AurasMythicPlus.buffCompact[spellId].expirationTime = expirationTime;
            end
        end

        index = index + 1;

        return index > BUFF_MAX_DISPLAY;
    end);

    AuraUtil_ForEachAura(unitframe.AurasMythicPlus.unit, filterHarmful, BUFF_MAX_DISPLAY, function(...)
        buffName, texture, count, _, duration, expirationTime, _, _, _, spellId = ...;

        if FilterShouldShowBuff(spellId, false, true) then
            local cCount = count == 0 and 1 or count;

            if not unitframe.AurasMythicPlus.buffCompact[spellId] then
                unitframe.AurasMythicPlus.buffCompact[spellId] = {
                    index          = index,
                    buffName       = buffName,
                    texture        = texture,
                    count          = cCount,
                    duration       = duration,
                    expirationTime = expirationTime,
                };
            else
                unitframe.AurasMythicPlus.buffCompact[spellId].count          = unitframe.AurasMythicPlus.buffCompact[spellId].count + cCount;
                unitframe.AurasMythicPlus.buffCompact[spellId].duration       = duration;
                unitframe.AurasMythicPlus.buffCompact[spellId].expirationTime = expirationTime;
            end
        end

        index = index + 1;

        return index > BUFF_MAX_DISPLAY;
    end);

    local aura;
    for _, spell in pairs(unitframe.AurasMythicPlus.buffCompact) do
        aura = unitframe.AurasMythicPlus.buffList[buffIndex];

        if not aura then
            aura = CreateFrame('Frame', nil, unitframe.AurasMythicPlus, 'NameplateBuffButtonTemplate');
            aura:SetMouseClickEnabled(false);
            aura.layoutIndex = buffIndex;

            aura:SetScale(SCALE);

            if SQUARE then
                aura:SetSize(20, 20);
                aura.Icon:SetSize(18, 18);
                aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
            end

            aura.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
            aura.Border:SetShown(not BORDER_HIDE);

            aura.Cooldown:SetDrawEdge(DRAW_EDGE);
            aura.Cooldown:SetDrawSwipe(DRAW_SWIPE);
            aura.Cooldown:SetCountdownFont('StripesAurasMythicPlusCooldownFont');
            aura.Cooldown:GetRegions():ClearAllPoints();
            aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
            aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
            aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

            aura.CountFrame.Count:ClearAllPoints();
            aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
            aura.CountFrame.Count:SetFontObject(StripesAurasMythicPlusCountFont);
            aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

            if MASQUE_SUPPORT and Stripes.Masque then
                Stripes.MasqueAurasMythicGroup:RemoveButton(aura);
                Stripes.MasqueAurasMythicGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
            end

            unitframe.AurasMythicPlus.buffList[buffIndex] = aura;
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
        if unitframe.AurasMythicPlus.buffList[i] then
            unitframe.AurasMythicPlus.buffList[i]:SetShown(false);
        else
            break;
        end
    end

    if buffIndex > 1 then
        if not unitframe.AurasMythicPlus:IsShown() then
            unitframe.AurasMythicPlus:SetShown(true);
        end

        UpdateAnchor(unitframe);
    else
        if unitframe.AurasMythicPlus:IsShown() then
            unitframe.AurasMythicPlus:SetShown(false);
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
    for _, aura in ipairs(unitframe.AurasMythicPlus.buffList) do
        if Stripes.Masque then
            if MASQUE_SUPPORT then
                Stripes.MasqueAurasMythicGroup:RemoveButton(aura);
                Stripes.MasqueAurasMythicGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);

                aura.Border:SetDrawLayer('BACKGROUND');
            else
                Stripes.MasqueAurasMythicGroup:RemoveButton(aura);

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

    unitframe.AurasMythicPlus.spacing = SPACING_X;

    OnUnitAuraUpdate(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasMythicPlus then
        unitframe.AurasMythicPlus:SetShown(false);
    end
end

function Module:UnitAura(unitframe, isFullUpdate, updatedAuraInfos)
    OnUnitAuraUpdate(unitframe, isFullUpdate, updatedAuraInfos);
end

function Module:Update(unitframe)
    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasMythicGroup:ReSkin();
    end

    unitframe.AurasMythicPlus.spacing = SPACING_X;

    Update(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    MASQUE_SUPPORT = O.db.auras_masque_support;

    ENABLED              = O.db.auras_mythicplus_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_mythicplus_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    BORDER_HIDE = O.db.auras_border_hide;
    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_mythicplus_border_color[1];
    BORDER_COLOR[2] = O.db.auras_mythicplus_border_color[2];
    BORDER_COLOR[3] = O.db.auras_mythicplus_border_color[3];
    BORDER_COLOR[4] = O.db.auras_mythicplus_border_color[4] or 1;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_mythicplus_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_mythicplus_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_mythicplus_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_mythicplus_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_mythicplus_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_mythicplus_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_mythicplus_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_mythicplus_count_offset_y;

    SCALE  = O.db.auras_mythicplus_scale;
    SQUARE = O.db.auras_square;

    OFFSET_X = O.db.auras_mythicplus_offset_x;
    OFFSET_Y = O.db.auras_mythicplus_offset_y;

    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_mythicplus_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_mythicplus_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_mythicplus_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_mythicplus_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_mythicplus_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_mythicplus_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_mythicplus_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_mythicplus_count_color[4] or 1;

    SPACING_X = O.db.auras_mythicplus_spacing_x or 4;

    DRAW_EDGE  = O.db.auras_mythicplus_draw_edge;
    DRAW_SWIPE = O.db.auras_mythicplus_draw_swipe;

    AURAS_DIRECTION = O.db.auras_mythicplus_direction;
    AURAS_MAX_DISPLAY = O.db.auras_mythicplus_max_display;

    UpdateFontObject(StripesAurasMythicPlusCooldownFont, O.db.auras_mythicplus_cooldown_font_value, O.db.auras_mythicplus_cooldown_font_size, O.db.auras_mythicplus_cooldown_font_flag, O.db.auras_mythicplus_cooldown_font_shadow);
    UpdateFontObject(StripesAurasMythicPlusCountFont, O.db.auras_mythicplus_count_font_value, O.db.auras_mythicplus_count_font_size, O.db.auras_mythicplus_count_font_flag, O.db.auras_mythicplus_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdateAnchor);
end