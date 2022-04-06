local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Important');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local bit_band, math_max = bit.band, math.max;

-- Wow API
local CooldownFrame_Set, UnitName, AuraUtil_ForEachAura, AuraUtil_ShouldSkipAuraUpdate = CooldownFrame_Set, UnitName, AuraUtil.ForEachAura, AuraUtil.ShouldSkipAuraUpdate;

-- Sripes API
local GetUnitColor = U.GetUnitColor;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;
local GlowStart, GlowStopAll = U.GlowStart, U.GlowStopAll;

-- Libraries
local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local CROWD_CTRL = LPS.constants.CROWD_CTRL;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED, CASTER_NAME_SHOW;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SCALE, SQUARE;
local OFFSET_X, OFFSET_Y;
local BORDER_HIDE;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SPACING_X;
local DRAW_EDGE, DRAW_SWIPE;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y, BUFFFRAME_OFFSET_Y;
local AURAS_MAX_DISPLAY;
local GLOW_ENABLED, GLOW_TYPE, GLOW_COLOR;
local BORDER_COLOR;

local StripesAurasImportantCooldownFont = CreateFont('StripesAurasImportantCooldownFont');
local StripesAurasImportantCountFont    = CreateFont('StripesAurasImportantCountFont');
local StripesAurasImportantCasterFont   = CreateFont('StripesAurasImportantCasterFont');

local MAX_OFFSET_Y = -9;
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local filter = 'HARMFUL';

local additionalAuras = {
    -- Druid
    [81261] = true, -- Solar Beam

    -- Paladin
    [10326] = true, -- Turn Evil

    -- Priest
    [453] = true, -- Mind Soothe

    -- Warlock
    [5484] = true, -- Howl of Terror

    -- Covenant
    [331866] = true, -- Agent of Chaos (Venthyr)
    [332423] = true, -- Sparkling Driftglobe Core (Kyrian)

    -- Other
    [228626] = true, -- Haunted Urn (De Other Side) (Stun)
    [348723] = true, -- Haunted Urn (De Other Side) (Stun) ???
};

local function CreateAnchor(unitframe)
    if unitframe.ImportantAuras then
        return;
    end

    local frame = CreateFrame('Frame', '$parentImportantAuras', unitframe);
    frame:SetSize(14, 14);

    frame.buffList = {};

    unitframe.ImportantAuras = frame;
end

local function UpdateAnchor(unitframe)
    if unitframe.BuffFrame.buffList[1] and unitframe.BuffFrame.buffList[1]:IsShown() then
        unitframe.ImportantAuras:SetPoint('BOTTOMLEFT', unitframe.BuffFrame, 'TOPLEFT', OFFSET_X, 4 + (SQUARE and 6 or 0) + OFFSET_Y);
    else
        if ShouldShowName(unitframe) then
            local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y)) or 0;
            unitframe.ImportantAuras:SetPoint('BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', OFFSET_X, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
        else
            local offset = unitframe.BuffFrame:GetBaseYOffset() + (UnitIsUnit(unitframe.data.unit, 'target') and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
            unitframe.ImportantAuras:SetPoint('BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', OFFSET_X, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
        end
    end

    unitframe.ImportantAuras:SetWidth(unitframe.healthBar:GetWidth());
end

local function FilterShouldShowBuff(spellId)
    local spellFound = false;

    if additionalAuras[spellId] then
        spellFound = true;
    else
        local flags, _, _, cc = LPS_GetSpellInfo(LPS, spellId);
        if flags and cc and bit_band(flags, CROWD_CTRL) > 0 and bit_band(cc, CC_TYPES) > 0 then
            spellFound = true;
        end
    end

    return spellFound;
end

local function AuraCouldDisplayAsBuff(auraInfo)
    return FilterShouldShowBuff(auraInfo.spellId);
end

local function Update(unitframe)
    if not ENABLED or not unitframe.data.unit or unitframe.data.unitType == 'SELF' then
        if unitframe.ImportantAuras:IsShown() then
            unitframe.ImportantAuras:SetShown(false);
        end

        return;
    end

    unitframe.ImportantAuras.unit   = unitframe.data.unit;
    unitframe.ImportantAuras.filter = filter;

    local buffIndex = 1;
    local index = 1;

    local _, texture, count, duration, expirationTime, source, spellId;
    AuraUtil_ForEachAura(unitframe.ImportantAuras.unit, unitframe.ImportantAuras.filter, BUFF_MAX_DISPLAY, function(...)
        _, texture, count, _, duration, expirationTime, source, _, _, spellId = ...;

        if FilterShouldShowBuff(spellId) then
            local aura = unitframe.ImportantAuras.buffList[buffIndex];

            if not aura then
                aura = CreateFrame('Frame', nil, unitframe.ImportantAuras, 'NameplateBuffButtonTemplate');
                aura:SetMouseClickEnabled(false);
                aura.layoutIndex = buffIndex;

                if SQUARE then
                    aura:SetSize(20, 20);
                    aura.Icon:SetSize(18, 18);
                    aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
                end

                aura:SetScale(SCALE);

                aura.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
                aura.Border:SetShown(not BORDER_HIDE);

                aura.Cooldown:SetDrawEdge(DRAW_EDGE);
                aura.Cooldown:SetDrawSwipe(DRAW_SWIPE);
                aura.Cooldown:SetFrameStrata('HIGH');
                aura.Cooldown:SetCountdownFont('StripesAurasImportantCooldownFont');
                aura.Cooldown:GetRegions():ClearAllPoints();
                aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
                aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
                aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
                aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

                aura.CountFrame:SetFrameStrata('HIGH');
                aura.CountFrame.Count:ClearAllPoints();
                aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
                aura.CountFrame.Count:SetFontObject(StripesAurasImportantCountFont);
                aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

                aura.CasterName = aura:CreateFontString(nil, 'ARTWORK');
                PixelUtil.SetPoint(aura.CasterName, 'BOTTOM', aura, 'TOP', 0, 2);
                aura.CasterName:SetFontObject(StripesAurasImportantCasterFont);

                if GLOW_ENABLED then
                    GlowStart(aura, GLOW_TYPE, GLOW_COLOR);
                end

                if MASQUE_SUPPORT and Stripes.Masque then
                    Stripes.MasqueAurasImportantGroup:RemoveButton(aura);
                    Stripes.MasqueAurasImportantGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
                end

                unitframe.ImportantAuras.buffList[buffIndex] = aura;
            end

            unitframe.ImportantAuras.buffList[1]:ClearAllPoints();
            unitframe.ImportantAuras.buffList[1]:SetPoint('CENTER', -(unitframe.ImportantAuras.buffList[1]:GetWidth()/2)*(buffIndex-1), 0);

            if buffIndex > 1 then
                aura:ClearAllPoints();
                aura:SetPoint('LEFT', unitframe.ImportantAuras.buffList[buffIndex - 1], 'RIGHT', SPACING_X, 0);
            end

            aura:SetID(index);

            aura.Icon:SetTexture(texture);

            if count > 1 then
                aura.CountFrame.Count:SetText(count);
                aura.CountFrame.Count:SetShown(true);
            else
                aura.CountFrame.Count:SetShown(false);
            end

            CooldownFrame_Set(aura.Cooldown, expirationTime - duration, duration, duration > 0, DRAW_EDGE);

            if CASTER_NAME_SHOW then
                local unitname = source and UnitName(source);
                if unitname then
                    aura.CasterName:SetText(unitname);
                    aura.CasterName:SetTextColor(GetUnitColor(source, 2));
                    aura.CasterName:SetShown(true);
                else
                    aura.CasterName:SetShown(false);
                end
            else
                aura.CasterName:SetShown(false);
            end

            aura:SetShown(true);

            buffIndex = buffIndex + 1;
        end

        index = index + 1;

        return buffIndex > AURAS_MAX_DISPLAY;
    end);

    for i = buffIndex, BUFF_MAX_DISPLAY do
        if unitframe.ImportantAuras.buffList[i] then
            unitframe.ImportantAuras.buffList[i]:SetShown(false);
        else
            break;
        end
    end

    if buffIndex > 1 then
        if not unitframe.ImportantAuras:IsShown() then
            unitframe.ImportantAuras:SetShown(true);
        end

        UpdateAnchor(unitframe);
    else
        if unitframe.ImportantAuras:IsShown() then
            unitframe.ImportantAuras:SetShown(false);
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
    for _, aura in ipairs(unitframe.ImportantAuras.buffList) do
        if Stripes.Masque then
            if MASQUE_SUPPORT then
                Stripes.MasqueAurasImportantGroup:RemoveButton(aura);
                Stripes.MasqueAurasImportantGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);

                aura.Border:SetDrawLayer('BACKGROUND');
            else
                Stripes.MasqueAurasImportantGroup:RemoveButton(aura);

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

        if GLOW_ENABLED then
            GlowStopAll(aura);
            GlowStart(aura, GLOW_TYPE, GLOW_COLOR);
        else
            GlowStopAll(aura);
        end
    end
end

function Module:UnitAdded(unitframe)
    CreateAnchor(unitframe);
    OnUnitAuraUpdate(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.ImportantAuras then
        unitframe.ImportantAuras:SetShown(false);
    end
end

function Module:UnitAura(unitframe, isFullUpdate, updatedAuraInfos)
    OnUnitAuraUpdate(unitframe, isFullUpdate, updatedAuraInfos);
end

function Module:Update(unitframe)
    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasImportantGroup:ReSkin();
    end

    Update(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    MASQUE_SUPPORT = O.db.auras_masque_support;

    SCALE = O.db.auras_important_scale;

    ENABLED           = O.db.auras_important_enabled;
    COUNTDOWN_ENABLED = O.db.auras_important_countdown_enabled;
    CASTER_NAME_SHOW  = O.db.auras_important_castername_show;
    SUPPRESS_OMNICC   = O.db.auras_omnicc_suppress;

    BORDER_HIDE = O.db.auras_border_hide;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_important_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_important_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_important_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_important_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_important_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_important_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_important_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_important_count_offset_y;

    SQUARE = O.db.auras_square;

    OFFSET_X = O.db.auras_important_offset_x;
    OFFSET_Y = O.db.auras_important_offset_y;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_important_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_important_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_important_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_important_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_important_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_important_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_important_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_important_count_color[4] or 1;

    SPACING_X = O.db.auras_important_spacing_x or 2;

    DRAW_EDGE  = O.db.auras_important_draw_edge;
    DRAW_SWIPE = O.db.auras_important_draw_swipe;

    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    BUFFFRAME_OFFSET_Y   = O.db.auras_offset_y;

    AURAS_MAX_DISPLAY = O.db.auras_important_max_display;

    GLOW_ENABLED = O.db.auras_important_glow_enabled;
    GLOW_TYPE    = O.db.auras_important_glow_type;
    GLOW_COLOR    = GLOW_COLOR or {};
    GLOW_COLOR[1] = O.db.auras_important_glow_color[1];
    GLOW_COLOR[2] = O.db.auras_important_glow_color[2];
    GLOW_COLOR[3] = O.db.auras_important_glow_color[3];
    GLOW_COLOR[4] = O.db.auras_important_glow_color[4] or 1;

    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_important_border_color[1];
    BORDER_COLOR[2] = O.db.auras_important_border_color[2];
    BORDER_COLOR[3] = O.db.auras_important_border_color[3];
    BORDER_COLOR[4] = O.db.auras_important_border_color[4] or 1;

    UpdateFontObject(StripesAurasImportantCooldownFont, O.db.auras_important_cooldown_font_value, O.db.auras_important_cooldown_font_size, O.db.auras_important_cooldown_font_flag, O.db.auras_important_cooldown_font_shadow);
    UpdateFontObject(StripesAurasImportantCountFont, O.db.auras_important_count_font_value, O.db.auras_important_count_font_size, O.db.auras_important_count_font_flag, O.db.auras_important_count_font_shadow);
    UpdateFontObject(StripesAurasImportantCasterFont, O.db.auras_important_castername_font_value, O.db.auras_important_castername_font_size, O.db.auras_important_castername_font_flag, O.db.auras_important_castername_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdateAnchor);
end