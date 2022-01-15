local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_MythicPlus');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local pairs, table_wipe, math_max = pairs, wipe, math.max;

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
local OFFSET_Y;
local BORDER_HIDE;
local MASQUE_SUPPORT;

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

    if unit and ShouldShowName(unitframe) then
        local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;
        local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y) + showMechanicOnTarget) or showMechanicOnTarget;
        PixelUtil.SetPoint(unitframe.AurasMythicPlus, 'BOTTOM', unitframe.healthBar, 'TOP', 1, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
    else
        local offset = unitframe.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
        PixelUtil.SetPoint(unitframe.AurasMythicPlus, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
    end
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

        if HelpfulList[spellId] then
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

        if HarmfulList[spellId] then
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

            aura.Cooldown:GetRegions():ClearAllPoints();
            aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
            aura.Cooldown:GetRegions():SetFontObject(StripesAurasMythicPlusCooldownFont);
            aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

            aura.CountFrame.Count:ClearAllPoints();
            aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
            aura.CountFrame.Count:SetFontObject(StripesAurasMythicPlusCountFont);

            aura.Border:SetColorTexture(0.80, 0.05, 0.05, 1);
            aura.Border:SetShown(not BORDER_HIDE);

            if MASQUE_SUPPORT and Stripes.Masque then
                Stripes.MasqueAurasMythicGroup:RemoveButton(aura);
                Stripes.MasqueAurasMythicGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
            end

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

local function UpdateStyle(unitframe)
    for _, aura in ipairs(unitframe.ImportantAuras.buffList) do
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

        aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
        aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

        aura.Cooldown:GetRegions():ClearAllPoints();
        aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);

        aura.CountFrame.Count:ClearAllPoints();
        aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);

        if Stripes.Masque then
            if MASQUE_SUPPORT then
                Stripes.MasqueAurasMythicGroup:RemoveButton(aura);
                Stripes.MasqueAurasMythicGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
            else
                Stripes.MasqueAurasMythicGroup:RemoveButton(aura);
            end
        end
    end

    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasMythicGroup:ReSkin();
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

    OFFSET_Y = O.db.auras_mythicplus_offset_y;

    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    UpdateFontObject(StripesAurasMythicPlusCooldownFont, O.db.auras_mythicplus_cooldown_font_value, O.db.auras_mythicplus_cooldown_font_size, O.db.auras_mythicplus_cooldown_font_flag, O.db.auras_mythicplus_cooldown_font_shadow);
    UpdateFontObject(StripesAurasMythicPlusCountFont, O.db.auras_mythicplus_count_font_value, O.db.auras_mythicplus_count_font_size, O.db.auras_mythicplus_count_font_flag, O.db.auras_mythicplus_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end