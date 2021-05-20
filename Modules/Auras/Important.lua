local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Important');

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

local StripesAurasImportantCooldownFont = CreateFont('StripesAurasImportantCooldownFont');
local StripesAurasImportantCountFont    = CreateFont('StripesAurasImportantCountFont');
local StripesAurasImportantCasterFont   = CreateFont('StripesAurasImportantCasterFont');

local MAX_AURAS = 3;
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local filter = 'HARMFUL';
local pixelGlowColor = { 1, 0.3, 0, 1 };

local additionalAuras = {
    -- Druid
    [81261]  = true, -- Solar Beam
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
    unitframe.ImportantAuras:SetPoint('BOTTOMLEFT', unitframe.BuffFrame, 'TOPLEFT', 0, 4);
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

                aura:SetScale(O.db.auras_important_scale);

                aura.Cooldown:SetFrameStrata('HIGH');
                aura.Cooldown:GetRegions():ClearAllPoints();
                aura.Cooldown:GetRegions():SetPoint('TOPLEFT', -2, 4);
                aura.Cooldown:GetRegions():SetFontObject(StripesAurasImportantCooldownFont);

                aura.CountFrame:SetFrameStrata('HIGH');
                aura.CountFrame.Count:SetFontObject(StripesAurasImportantCountFont);

                aura.CasterName = aura:CreateFontString(nil, 'ARTWORK');
                PixelUtil.SetPoint(aura.CasterName, 'BOTTOM', aura, 'TOP', 0, 2);
                aura.CasterName:SetFontObject(StripesAurasImportantCasterFont);

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
            aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);

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
    for _, buff in ipairs(unitframe.ImportantAuras.buffList) do
        buff:SetScale(O.db.auras_important_scale);
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
    ENABLED           = O.db.auras_important_enabled;
    COUNTDOWN_ENABLED = O.db.auras_important_countdown_enabled;
    CASTER_NAME_SHOW  = O.db.auras_important_castername_show;

    UpdateFontObject(StripesAurasImportantCooldownFont, O.db.auras_important_cooldown_font_value, O.db.auras_important_cooldown_font_size, O.db.auras_important_cooldown_font_flag, O.db.auras_important_cooldown_font_shadow);
    UpdateFontObject(StripesAurasImportantCountFont, O.db.auras_important_count_font_value, O.db.auras_important_count_font_size, O.db.auras_important_count_font_flag, O.db.auras_important_count_font_shadow);
    UpdateFontObject(StripesAurasImportantCasterFont, O.db.auras_important_castername_font_value, O.db.auras_important_castername_font_size, O.db.auras_important_castername_font_flag, O.db.auras_important_castername_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end