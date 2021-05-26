local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_MythicPlus');

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

local StripesAurasMythicPlusCooldownFont = CreateFont('StripesAurasMythicPlusCooldownFont');
local StripesAurasMythicPlusCountFont    = CreateFont('StripesAurasMythicPlusCountFont');

local whitelist = {
    [226510] = true, -- Mythic Plus Affix: Sanguine
    [209859] = true, -- Mythic Plus Affix: Bolstering
    [343502] = true, -- Mythic Plus Affix: Inspiring
    [228318] = true, -- Mythic Plus Affix: Raging

    [323059] = true, -- Mists of Tirna Scithe (Droman's Wrath)
};

local PlayerState = D.Player.State;
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local filter = 'HELPFUL';
local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';

local function CreateAnchor(uniframe)
    if uniframe.AurasMythicPlus then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasMythicPlus', uniframe);
    frame:SetPoint('RIGHT', uniframe.healthBar, 'RIGHT', 0, 0);
    frame:SetHeight(14);

    frame.buffList = {};
    frame.buffCompact = {};

    uniframe.AurasMythicPlus = frame;
end

local function UpdateAnchor(unitframe)
    local unit = unitframe.data.unit;
    local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;

    if unit and ShouldShowName(unitframe) then
        local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + NAME_TEXT_OFFSET_Y + showMechanicOnTarget) or showMechanicOnTarget;
        PixelUtil.SetPoint(unitframe.AurasMythicPlus, 'BOTTOM', unitframe.healthBar, 'TOP', 1, 2 + offset);
    else
        local offset = unitframe.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
        PixelUtil.SetPoint(unitframe.AurasMythicPlus, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset);
    end
end

local function Update(unitframe)
    if not ENABLED or not PlayerState.inMythic or not unitframe.data.unit or unitframe.data.unitType == 'SELF' then
        unitframe.AurasMythicPlus:SetShown(false);
        return;
    end

    unitframe.AurasMythicPlus.unit   = unitframe.data.unit;
    unitframe.AurasMythicPlus.filter = filter;

    table_wipe(unitframe.AurasMythicPlus.buffCompact);

    local buffIndex = 1;
    local index = 1;

    local _, buffName, texture, count, duration, expirationTime, spellId;
    AuraUtil_ForEachAura(unitframe.AurasMythicPlus.unit, unitframe.AurasMythicPlus.filter, BUFF_MAX_DISPLAY, function(...)
        buffName, texture, count, _, duration, expirationTime, _, _, _, spellId = ...;

        if whitelist[spellId] then
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

            aura.Cooldown:GetRegions():ClearAllPoints();
            aura.Cooldown:GetRegions():SetPoint('TOPLEFT', -2, 4);
            aura.Cooldown:GetRegions():SetFontObject(StripesAurasMythicPlusCooldownFont);

            aura.CountFrame.Count:SetFontObject(StripesAurasMythicPlusCountFont);

            aura.Border:SetColorTexture(0.81, 0.05, 0.05, 1);

            unitframe.AurasMythicPlus.buffList[buffIndex] = aura;
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

function Module:UnitAdded(unitframe)
    CreateAnchor(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasMythicPlus then
        unitframe.AurasMythicPlus:SetShown(false);
    end
end

function Module:UnitAura(unitframe)
    Update(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED              = O.db.auras_mythicplus_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_mythicplus_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;

    UpdateFontObject(StripesAurasMythicPlusCooldownFont, O.db.auras_mythicplus_cooldown_font_value, O.db.auras_mythicplus_cooldown_font_size, O.db.auras_mythicplus_cooldown_font_flag, O.db.auras_mythicplus_cooldown_font_shadow);
    UpdateFontObject(StripesAurasMythicPlusCountFont, O.db.auras_mythicplus_count_font_value, O.db.auras_mythicplus_count_font_size, O.db.auras_mythicplus_count_font_flag, O.db.auras_mythicplus_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end