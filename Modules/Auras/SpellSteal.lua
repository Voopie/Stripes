local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_SpellSteal');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local math_max = math.max;

-- WoW API
local CooldownFrame_Set, GetCVarBool, UnitIsUnit, GetTime, AuraUtil_ForEachAura = CooldownFrame_Set, GetCVarBool, UnitIsUnit, GetTime, AuraUtil.ForEachAura;

-- Stripes API
local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED;
local BORDER_COLOR;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SCALE, SQUARE, BUFFFRAME_OFFSET_Y;
local STATIC_POSITION, OFFSET_X, OFFSET_Y;
local GLOW_ENABLED, GLOW_TYPE, GLOW_COLOR;
local BORDER_HIDE;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;

-- Libraries
local LCG = S.Libraries.LCG;

local StripesAurasSpellStealCooldownFont = CreateFont('StripesAurasSpellStealCooldownFont');
local StripesAurasSpellStealCountFont    = CreateFont('StripesAurasSpellStealCountFont');

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY;
local filter = 'HELPFUL';
local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';

local MAX_OFFSET_Y = -9;

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
        if ShouldShowName(unitframe) then
            if STATIC_POSITION then
                PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'BOTTOM', unitframe.healthBar, 'TOP', 1 + OFFSET_X, 2 + (SQUARE and 6 or 0) + OFFSET_Y);
            else
                local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;
                local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y) + showMechanicOnTarget) or showMechanicOnTarget;    
                PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'BOTTOM', unitframe.healthBar, 'TOP', 1 + OFFSET_X, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
            end
        else
            if STATIC_POSITION then
                PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'BOTTOM', unitframe.healthBar, 'TOP', 1 + OFFSET_X, 2 + (SQUARE and 6 or 0) + OFFSET_Y);
            else
                local offset = unitframe.BuffFrame:GetBaseYOffset() + (UnitIsUnit(unitframe.data.unit, 'target') and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
                PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'BOTTOM', unitframe.healthBar, 'TOP', OFFSET_X, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
            end
        end

        PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'LEFT', unitframe.healthBar, 'LEFT', -1 + OFFSET_X, 0);
    else
        if STATIC_POSITION then
            PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'BOTTOM', unitframe.healthBar, 'TOP', 1 + OFFSET_X, 2 + (SQUARE and 6 or 0) + OFFSET_Y);
        else
            unitframe.AurasSpellSteal:SetPoint('BOTTOM', unitframe.BuffFrame, 'TOP', OFFSET_X, 4 + OFFSET_Y);
        end

        PixelUtil.SetPoint(unitframe.AurasSpellSteal, 'LEFT', unitframe.healthBar, 'LEFT', -1 + OFFSET_X, 0);
    end
end

local function UpdateGlow(aura)
    if not GLOW_ENABLED then
        return;
    end

    if GLOW_TYPE == 1 then
        LCG.PixelGlow_Start(aura, GLOW_COLOR);
    elseif GLOW_TYPE == 2 then
        LCG.AutoCastGlow_Start(aura, GLOW_COLOR);
    elseif GLOW_TYPE == 3 then
        LCG.ButtonGlow_Start(aura, GLOW_COLOR);
    end
end

local function StopGlow(aura)
    LCG.PixelGlow_Stop(aura);
    LCG.AutoCastGlow_Stop(aura);
    LCG.ButtonGlow_Stop(aura);
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

                aura:SetScale(SCALE);

                if SQUARE then
                    aura:SetSize(20, 20);
                    aura.Icon:SetSize(18, 18);
                    aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
                end

                aura.Cooldown:SetFrameStrata('HIGH');
                aura.Cooldown:GetRegions():ClearAllPoints();
                aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
                aura.Cooldown:GetRegions():SetFontObject(StripesAurasSpellStealCooldownFont);
                aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
                aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

                aura.CountFrame:SetFrameStrata('HIGH');
                aura.CountFrame.Count:ClearAllPoints();
                aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
                aura.CountFrame.Count:SetFontObject(StripesAurasSpellStealCountFont);
                aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

                aura.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
                aura.Border:SetShown(not BORDER_HIDE);

                UpdateGlow(aura);

                if MASQUE_SUPPORT and Stripes.Masque then
                    Stripes.MasqueAurasSpellstealGroup:RemoveButton(aura);
                    Stripes.MasqueAurasSpellstealGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
                end

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
    for _, aura in ipairs(unitframe.AurasSpellSteal.buffList) do
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

        aura.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
        aura.Border:SetShown(not BORDER_HIDE);

        aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

        aura.Cooldown:GetRegions():ClearAllPoints();
        aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
        aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);

        aura.CountFrame.Count:ClearAllPoints();
        aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
        aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

        StopGlow(aura);
        UpdateGlow(aura);

        if Stripes.Masque then
            if MASQUE_SUPPORT then
                Stripes.MasqueAurasSpellstealGroup:RemoveButton(aura);
                Stripes.MasqueAurasSpellstealGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
            else
                Stripes.MasqueAurasSpellstealGroup:RemoveButton(aura);
            end
        end
    end

    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasSpellstealGroup:ReSkin();
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
    MASQUE_SUPPORT = O.db.auras_masque_support;

    ENABLED              = O.db.auras_spellsteal_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_spellsteal_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    BORDER_HIDE = O.db.auras_border_hide;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_spellsteal_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_spellsteal_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_spellsteal_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_spellsteal_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_spellsteal_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_spellsteal_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_spellsteal_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_spellsteal_count_offset_y;

    SCALE  = O.db.auras_spellsteal_scale;
    SQUARE = O.db.auras_square;

    STATIC_POSITION = O.db.auras_spellsteal_static_position;
    OFFSET_X = O.db.auras_spellsteal_offset_x;
    OFFSET_Y = O.db.auras_spellsteal_offset_y;

    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    GLOW_ENABLED = O.db.auras_spellsteal_glow_enabled;
    GLOW_TYPE    = O.db.auras_spellsteal_glow_type;
    GLOW_COLOR    = GLOW_COLOR or {};
    GLOW_COLOR[1] = O.db.auras_spellsteal_glow_color[1];
    GLOW_COLOR[2] = O.db.auras_spellsteal_glow_color[2];
    GLOW_COLOR[3] = O.db.auras_spellsteal_glow_color[3];
    GLOW_COLOR[4] = O.db.auras_spellsteal_glow_color[4] or 1;

    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_spellsteal_color[1];
    BORDER_COLOR[2] = O.db.auras_spellsteal_color[2];
    BORDER_COLOR[3] = O.db.auras_spellsteal_color[3];
    BORDER_COLOR[4] = O.db.auras_spellsteal_color[4] or 1;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_spellsteal_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_spellsteal_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_spellsteal_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_spellsteal_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_spellsteal_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_spellsteal_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_spellsteal_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_spellsteal_count_color[4] or 1;

    UpdateFontObject(StripesAurasSpellStealCooldownFont, O.db.auras_spellsteal_cooldown_font_value, O.db.auras_spellsteal_cooldown_font_size, O.db.auras_spellsteal_cooldown_font_flag, O.db.auras_spellsteal_cooldown_font_shadow);
    UpdateFontObject(StripesAurasSpellStealCountFont, O.db.auras_spellsteal_count_font_value, O.db.auras_spellsteal_count_font_size, O.db.auras_spellsteal_count_font_flag, O.db.auras_spellsteal_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end