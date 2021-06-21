local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Mod');

-- Lua API
local select, ipairs = select, ipairs;

-- WoW API
local UnitAura, UnitIsUnit, GetCVarBool = UnitAura, UnitIsUnit, GetCVarBool;

-- Stripes API
local CanAccessObject = U.CanAccessObject;
local ShouldShowName   = S:GetNameplateModule('Handler').ShouldShowName;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local BORDER_COLOR_ENABLED, COUNTDOWN_ENABLED;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;
local SUPPRESS_OMNICC;

local DebuffTypeColor = DebuffTypeColor;

local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';

local StripesAurasModCooldownFont = CreateFont('StripesAurasModCooldownFont');
local StripesAurasModCountFont    = CreateFont('StripesAurasModCountFont');

local function UpdateBuffs(unitframe)
    local debuffType;

    for _, buff in ipairs(unitframe.BuffFrame.buffList) do
        if BORDER_COLOR_ENABLED then
            debuffType = select(4, UnitAura(unitframe.BuffFrame.unit, buff:GetID(), unitframe.BuffFrame.filter));
            if debuffType then
                buff.Border:SetColorTexture(DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b, 1);
            else
                buff.Border:SetColorTexture(0, 0, 0, 1);
            end
        else
            buff.Border:SetColorTexture(0, 0, 0, 1);
        end

        if not buff.Cooldown.__styled then
            buff.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            buff.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

            buff.Cooldown:GetRegions():ClearAllPoints();
            buff.Cooldown:GetRegions():SetPoint('TOPLEFT', -2, 4);
            buff.Cooldown:GetRegions():SetFontObject(StripesAurasModCooldownFont);

            buff.CountFrame.Count:SetFontObject(StripesAurasModCountFont);

            buff.Cooldown.__styled = true;
        end
    end
end

local function UpdateAnchor(unitframe)
    local unit = unitframe.unit;
    local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;

    if unit and ShouldShowName(unitframe) then
        local offset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + NAME_TEXT_OFFSET_Y + showMechanicOnTarget) or showMechanicOnTarget;
        PixelUtil.SetPoint(unitframe.BuffFrame, 'BOTTOM', unitframe.healthBar, 'TOP', 1, 2 + offset);
    else
        local offset = unitframe.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and unitframe.BuffFrame:GetTargetYOffset() or 0.0);
        PixelUtil.SetPoint(unitframe.BuffFrame, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + offset);
    end
end

local function UpdateStyle(unitframe)
    for _, aura in ipairs(unitframe.BuffFrame.buffList) do
        aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
        aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;
    end
end

function Module:UnitAdded(unitframe)
    UpdateBuffs(unitframe);
    UpdateAnchor(unitframe);
end

function Module:UnitRemoved(unitframe)
    UpdateStyle(unitframe);
end

function Module:UnitAura(unitframe)
    UpdateBuffs(unitframe);
end

function Module:Update(unitframe)
    UpdateBuffs(unitframe);
    UpdateAnchor(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    BORDER_COLOR_ENABLED = O.db.auras_border_color_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    UpdateFontObject(StripesAurasModCooldownFont, O.db.auras_cooldown_font_value, O.db.auras_cooldown_font_size, O.db.auras_cooldown_font_flag, O.db.auras_cooldown_font_shadow);
    UpdateFontObject(StripesAurasModCountFont, O.db.auras_count_font_value, O.db.auras_count_font_size, O.db.auras_count_font_flag, O.db.auras_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:SecureHook('NameplateBuffContainerMixin', {
        ['UpdateAnchor'] = function(buffContainer)
            if not CanAccessObject(buffContainer) then
                return;
            end

            if not self:CheckUnitFrame(buffContainer:GetParent()) then
                return;
            end

            UpdateAnchor(buffContainer:GetParent());
        end,
    });
end