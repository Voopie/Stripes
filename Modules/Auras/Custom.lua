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

local StripesAurasCustomCooldownFont = CreateFont('StripesAurasCustomCooldownFont');
local StripesAurasCustomCountFont    = CreateFont('StripesAurasCustomCountFont');

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';
local filterHelpful = 'HELPFUL';
local filterHarmful = 'HARMFUL';

local function CreateAnchor(uniframe)
    if uniframe.AurasCustom then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasCustom', uniframe);
    frame:SetPoint('RIGHT', uniframe.healthBar, 'RIGHT', 0, 0);
    frame:SetHeight(14);

    frame.buffList = {};
    frame.buffCompact = {};

    uniframe.AurasCustom = frame;
end

local function UpdateAnchor(unitframe)
    local unit = unitframe.data.unit;
    local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;

    if unitframe.AurasMythicPlus and unitframe.AurasMythicPlus:IsShown() then
        PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.AurasMythicPlus, 'TOP', 0, 4);
    else
        if unit and ShouldShowName(unitframe) then
            local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + NAME_TEXT_OFFSET_Y + showMechanicOnTarget) or showMechanicOnTarget;
            PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.healthBar, 'TOP', 1, 2 + offset);
        else
            local offset = unitframe.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
            PixelUtil.SetPoint(unitframe.AurasCustom, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset);
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

    local _, buffName, texture, count, duration, expirationTime, spellId;
    AuraUtil_ForEachAura(unitframe.AurasCustom.unit, filterHelpful, BUFF_MAX_DISPLAY, function(...)
        buffName, texture, count, _, duration, expirationTime, _, _, _, spellId = ...;

        if O.db.auras_custom_data[spellId] and O.db.auras_custom_data[spellId].enabled then
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
        buffName, texture, count, _, duration, expirationTime, _, _, _, spellId = ...;

        if O.db.auras_custom_data[spellId] and O.db.auras_custom_data[spellId].enabled then
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

            aura.Cooldown:GetRegions():ClearAllPoints();
            aura.Cooldown:GetRegions():SetPoint('TOPLEFT', -2, 4);
            aura.Cooldown:GetRegions():SetFontObject(StripesAurasCustomCooldownFont);

            aura.CountFrame.Count:SetFontObject(StripesAurasCustomCountFont);

            aura.Border:SetColorTexture(0.80, 0.05, 0.05, 1);

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
        aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);

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
end

function Module:UpdateLocalConfig()
    ENABLED              = O.db.auras_custom_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_custom_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;

    UpdateFontObject(StripesAurasCustomCooldownFont, O.db.auras_custom_cooldown_font_value, O.db.auras_custom_cooldown_font_size, O.db.auras_custom_cooldown_font_flag, O.db.auras_custom_cooldown_font_shadow);
    UpdateFontObject(StripesAurasCustomCountFont, O.db.auras_custom_count_font_value, O.db.auras_custom_count_font_size, O.db.auras_custom_count_font_flag, O.db.auras_custom_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end