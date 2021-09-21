local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Important');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local bit_band = bit.band;

-- Wow API
local CooldownFrame_Set, UnitName, AuraUtil_ForEachAura = CooldownFrame_Set, UnitName, AuraUtil.ForEachAura;

-- Sripes API
local GetUnitColor = U.GetUnitColor;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Libraries
local LCG = S.Libraries.LCG;

local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local CROWD_CTRL = LPS.constants.CROWD_CTRL;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED, CASTER_NAME_SHOW;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SQUARE;
local OFFSET_Y;
local BORDER_HIDE;
local MASQUE_SUPPORT;

local StripesAurasImportantCooldownFont = CreateFont('StripesAurasImportantCooldownFont');
local StripesAurasImportantCountFont    = CreateFont('StripesAurasImportantCountFont');
local StripesAurasImportantCasterFont   = CreateFont('StripesAurasImportantCasterFont');

local MAX_AURAS = 3;
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local filter = 'HARMFUL';
local pixelGlowColor = { 1, 0.3, 0, 1 };

local additionalAuras = {
    -- Druid
    [81261] = true, -- Solar Beam
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
    unitframe.ImportantAuras:SetPoint('BOTTOMLEFT', unitframe.BuffFrame, 'TOPLEFT', 0, 4 + (SQUARE and 6 or 0) + OFFSET_Y);
    unitframe.ImportantAuras:SetWidth(unitframe.healthBar:GetWidth());
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

    local spellFound;
    local buffIndex = 1;
    local index = 1;

    local _, texture, count, duration, expirationTime, source, spellId;
    AuraUtil_ForEachAura(unitframe.ImportantAuras.unit, unitframe.ImportantAuras.filter, BUFF_MAX_DISPLAY, function(...)
        _, texture, count, _, duration, expirationTime, source, _, _, spellId = ...;

        spellFound = false;
        if additionalAuras[spellId] then
            spellFound = true;
        else
            local flags, _, _, cc = LPS_GetSpellInfo(LPS, spellId);
            if flags and cc and bit_band(flags, CROWD_CTRL) > 0 and bit_band(cc, CC_TYPES) > 0 then
                spellFound = true;
            end
        end

        if spellFound then
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

                aura:SetScale(O.db.auras_important_scale);

                aura.Border:SetShown(not BORDER_HIDE);

                aura.Cooldown:SetFrameStrata('HIGH');
                aura.Cooldown:GetRegions():ClearAllPoints();
                aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
                aura.Cooldown:GetRegions():SetFontObject(StripesAurasImportantCooldownFont);
                aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
                aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

                aura.CountFrame:SetFrameStrata('HIGH');
                aura.CountFrame.Count:ClearAllPoints();
                aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
                aura.CountFrame.Count:SetFontObject(StripesAurasImportantCountFont);

                aura.CasterName = aura:CreateFontString(nil, 'ARTWORK');
                PixelUtil.SetPoint(aura.CasterName, 'BOTTOM', aura, 'TOP', 0, 2);
                aura.CasterName:SetFontObject(StripesAurasImportantCasterFont);

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
                aura:SetPoint('LEFT', unitframe.ImportantAuras.buffList[buffIndex - 1], 'RIGHT', 2, 0);
            end

            aura:SetID(index);

            aura.Icon:SetTexture(texture);

            if count > 1 then
                aura.CountFrame.Count:SetText(count);
                aura.CountFrame.Count:SetShown(true);
            else
                aura.CountFrame.Count:SetShown(false);
            end

            CooldownFrame_Set(aura.Cooldown, expirationTime - duration, duration, duration > 0, true);

            LCG.PixelGlow_Stop(aura);
            LCG.PixelGlow_Start(aura, pixelGlowColor);

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

        return buffIndex >= MAX_AURAS;
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

local function UpdateStyle(unitframe)
    for _, aura in ipairs(unitframe.ImportantAuras.buffList) do
        aura:SetScale(O.db.auras_important_scale);

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
                Stripes.MasqueAurasImportantGroup:RemoveButton(aura);
                Stripes.MasqueAurasImportantGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
            else
                Stripes.MasqueAurasImportantGroup:RemoveButton(aura);
            end
        end
    end

    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasImportantGroup:ReSkin();
    end
end

function Module:UnitAdded(unitframe)
    CreateAnchor(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.ImportantAuras then
        unitframe.ImportantAuras:SetShown(false);
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

    OFFSET_Y = O.db.auras_important_offset_y;

    UpdateFontObject(StripesAurasImportantCooldownFont, O.db.auras_important_cooldown_font_value, O.db.auras_important_cooldown_font_size, O.db.auras_important_cooldown_font_flag, O.db.auras_important_cooldown_font_shadow);
    UpdateFontObject(StripesAurasImportantCountFont, O.db.auras_important_count_font_value, O.db.auras_important_count_font_size, O.db.auras_important_count_font_flag, O.db.auras_important_count_font_shadow);
    UpdateFontObject(StripesAurasImportantCasterFont, O.db.auras_important_castername_font_value, O.db.auras_important_castername_font_size, O.db.auras_important_castername_font_flag, O.db.auras_important_castername_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end