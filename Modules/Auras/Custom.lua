local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Custom');

-- Lua API
local pairs, table_wipe = pairs, wipe;

-- WoW API
local CooldownFrame_Set, GetCVarBool, UnitIsUnit, AuraUtil_ForEachAura = CooldownFrame_Set, GetCVarBool, UnitIsUnit, AuraUtil.ForEachAura;

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

local StripesAurasCustomCooldownFont = CreateFont('StripesAurasCustomCooldownFont');
local StripesAurasCustomCountFont    = CreateFont('StripesAurasCustomCountFont');

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';
local filterHelpful = 'HELPFUL';
local filterHarmful = 'HARMFUL';

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
    if unitframe.AurasMythicPlus and unitframe.AurasMythicPlus:IsShown() then
        PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.AurasMythicPlus, 'TOP', 0, 4);
    else
        local unit = unitframe.data.unit;

        if unit and ShouldShowName(unitframe) then
            local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;
            local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + NAME_TEXT_OFFSET_Y + showMechanicOnTarget) or showMechanicOnTarget;
            PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.healthBar, 'TOP', 1, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y);
        else
            local offset = unitframe.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
            PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y);
        end
    end
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

    local _, buffName, texture, count, duration, expirationTime, spellId, castByPlayer;
    AuraUtil_ForEachAura(unitframe.AurasCustom.unit, filterHelpful, BUFF_MAX_DISPLAY, function(...)
        buffName, texture, count, _, duration, expirationTime, _, _, _, spellId, _, _, castByPlayer = ...;

        if O.db.auras_custom_data[spellId] and O.db.auras_custom_data[spellId].enabled and (not O.db.auras_custom_data[spellId].own_only or (castByPlayer and O.db.auras_custom_data[spellId].own_only)) then
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
        buffName, texture, count, _, duration, expirationTime, _, _, _, spellId, _, _, castByPlayer = ...;

        if O.db.auras_custom_data[spellId] and O.db.auras_custom_data[spellId].enabled and (not O.db.auras_custom_data[spellId].own_only or (castByPlayer and O.db.auras_custom_data[spellId].own_only)) then
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

            aura.Cooldown:GetRegions():ClearAllPoints();
            aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
            aura.Cooldown:GetRegions():SetFontObject(StripesAurasCustomCooldownFont);
            aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

            aura.CountFrame.Count:ClearAllPoints();
            aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
            aura.CountFrame.Count:SetFontObject(StripesAurasCustomCountFont);

            aura.Border:SetColorTexture(unpack(O.db.auras_custom_border_color));

            unitframe.AurasCustom.buffList[buffIndex] = aura;
        end

        aura:ClearAllPoints();
        aura:SetPoint('TOPRIGHT', -((buffIndex-1)*22), 0);

        aura:SetID(spell.index);

        aura.Icon:SetTexture(spell.texture);

        if spell.count > 1 then
            aura.CountFrame.Count:SetText(spell.count);
            aura.CountFrame.Count:SetShown(true);
        else
            aura.CountFrame.Count:SetShown(false);
        end

        CooldownFrame_Set(aura.Cooldown, spell.expirationTime - spell.duration, spell.duration, spell.duration > 0, true);

        aura:SetShown(true);

        buffIndex = buffIndex + 1;
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

local function UpdateStyle(unitframe)
    for _, aura in ipairs(unitframe.AurasCustom.buffList) do
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

        aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
        aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;
        aura.Border:SetColorTexture(unpack(O.db.auras_custom_border_color));

        aura.Cooldown:GetRegions():ClearAllPoints();
        aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);

        aura.CountFrame.Count:ClearAllPoints();
        aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
    end
end

function Module:UnitAdded(unitframe)
    CreateAnchor(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasCustom then
        unitframe.AurasCustom:SetShown(false);
    end
end

function Module:UnitAura(unitframe)
    Update(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED              = O.db.auras_custom_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_custom_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_custom_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_custom_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_custom_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_custom_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_custom_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_custom_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_custom_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_custom_count_offset_y;

    SCALE  = O.db.auras_scale;
    SQUARE = O.db.auras_square;

    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    UpdateFontObject(StripesAurasCustomCooldownFont, O.db.auras_custom_cooldown_font_value, O.db.auras_custom_cooldown_font_size, O.db.auras_custom_cooldown_font_flag, O.db.auras_custom_cooldown_font_shadow);
    UpdateFontObject(StripesAurasCustomCountFont, O.db.auras_custom_count_font_value, O.db.auras_custom_count_font_size, O.db.auras_custom_count_font_flag, O.db.auras_custom_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end