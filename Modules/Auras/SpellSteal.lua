local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_SpellSteal');

-- WoW API
local CooldownFrame_Set, GetCVarBool, UnitIsUnit, GetTime, AuraUtil_ForEachAura = CooldownFrame_Set, GetCVarBool, UnitIsUnit, GetTime, AuraUtil.ForEachAura;

-- Stripes API
local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;

local StripesAurasSpellStealCooldownFont = CreateFont('StripesAurasSpellStealCooldownFont');
local StripesAurasSpellStealCountFont    = CreateFont('StripesAurasSpellStealCountFont');


local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local filter = 'HELPFUL';
local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';

local function CreateAnchor(unitframe)
    if unitframe.AurasSpellSteal then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasSpellSteal', unitframe);
    frame:SetPoint('LEFT', unitframe.healthBar, 'LEFT', -1, 0);
    frame:SetPoint('BOTTOM', unitframe.BuffFrame, 'TOP', 0, 4);
    frame:SetHeight(14);

    frame.buffList = {};

    unitframe.AurasSpellSteal = frame;
end

local function UpdateAnchor(unitframe)
    if not unitframe.BuffFrame.buffList[1] or not unitframe.BuffFrame.buffList[1]:IsShown() then
        local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;

        if ShouldShowName(unitframe) then
            local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + NAME_TEXT_OFFSET_Y + showMechanicOnTarget) or showMechanicOnTarget;
            PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'BOTTOM', unitframe.healthBar, 'TOP', 1, 2 + offset);
        else
            local offset = unitframe.BuffFrame:GetBaseYOffset() + (UnitIsUnit(unitframe.data.unit, 'target') and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
            PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset);
        end
    else
        unitframe.AurasSpellSteal:SetPoint('BOTTOM', unitframe.BuffFrame, 'TOP', 0, 4);
    end
end

local function Update(unitframe)
    if not ENABLED or not unitframe.data.unit or unitframe.data.unitType == 'SELF' then
        unitframe.AurasSpellSteal:SetShown(false);
        return;
    end

    unitframe.AurasSpellSteal.unit   = unitframe.data.unit;
    unitframe.AurasSpellSteal.filter = filter;

    local buffIndex = 1;
    local index = 1;

    local _, texture, count, duration, expirationTime, isStealable;
    local aura;

    AuraUtil_ForEachAura(unitframe.AurasSpellSteal.unit, unitframe.AurasSpellSteal.filter, BUFF_MAX_DISPLAY, function(...)
        _, texture, count, _, duration, expirationTime, _, isStealable = ...;

        if isStealable then
            aura = unitframe.AurasSpellSteal.buffList[buffIndex];

            if not aura then
                aura = CreateFrame('Frame', nil, unitframe.AurasSpellSteal, 'NameplateBuffButtonTemplate');
                aura:SetMouseClickEnabled(false);
                aura.layoutIndex = buffIndex;

                aura.Cooldown:GetRegions():ClearAllPoints();
                aura.Cooldown:GetRegions():SetPoint('TOPLEFT', -2, 4);
                aura.Cooldown:GetRegions():SetFontObject(StripesAurasSpellStealCooldownFont);

                aura.CountFrame.Count:SetFontObject(StripesAurasSpellStealCountFont);

                aura.Border:SetColorTexture(unpack(O.db.auras_spellsteal_color));

                unitframe.AurasSpellSteal.buffList[buffIndex] = aura;
            end

            aura:ClearAllPoints();
            aura:SetPoint('TOPLEFT', (buffIndex - 1) * 22, 0);

            aura:SetID(index);

            aura.Icon:SetTexture(texture);

            if count > 1 then
                aura.CountFrame.Count:SetText(count);
                aura.CountFrame.Count:SetShown(true);
            else
                aura.CountFrame.Count:SetShown(false);
            end

            CooldownFrame_Set(aura.Cooldown, expirationTime - duration, duration, duration > 0, true);

            if expirationTime - GetTime() >= 3600 then
                aura.Cooldown:SetHideCountdownNumbers(true);
            else
                aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            end

            aura:SetShown(true);

            buffIndex = buffIndex + 1;
        end

        index = index + 1;

        return buffIndex > BUFF_MAX_DISPLAY;
    end);

    for i = buffIndex, BUFF_MAX_DISPLAY do
        if unitframe.AurasSpellSteal.buffList[i] then
            unitframe.AurasSpellSteal.buffList[i]:SetShown(false);
        else
            break;
        end
    end

    if buffIndex > 1 then
        if not unitframe.AurasSpellSteal:IsShown() then
            unitframe.AurasSpellSteal:SetShown(true);
        end

        UpdateAnchor(unitframe);
    else
        if unitframe.AurasSpellSteal:IsShown() then
            unitframe.AurasSpellSteal:SetShown(false);
        end
    end
end

local function UpdateStyle(unitframe)
    for _, buff in ipairs(unitframe.AurasSpellSteal.buffList) do
        buff.Border:SetColorTexture(unpack(O.db.auras_spellsteal_color));
    end
end

function Module:UnitAdded(unitframe)
    CreateAnchor(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasSpellSteal then
        unitframe.AurasSpellSteal:SetShown(false);
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
    ENABLED              = O.db.auras_spellsteal_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_spellsteal_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;

    UpdateFontObject(StripesAurasSpellStealCooldownFont, O.db.auras_spellsteal_cooldown_font_value, O.db.auras_spellsteal_cooldown_font_size, O.db.auras_spellsteal_cooldown_font_flag, O.db.auras_spellsteal_cooldown_font_shadow);
    UpdateFontObject(StripesAurasSpellStealCountFont, O.db.auras_spellsteal_count_font_value, O.db.auras_spellsteal_count_font_size, O.db.auras_spellsteal_count_font_flag, O.db.auras_spellsteal_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end