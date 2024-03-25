local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Level');

-- Lua API
local string_format = string.format;

-- Stripes API
local S_UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;
local U_RGB2CFFHEX = U.RGB2CFFHEX;

-- Local Config
local ENABLED, TEXT_FRAME_STRATA, HIDE_MAX, USE_DIFF_COLOR, CUSTOM_COLOR_ENABLED, CUSTOM_COLOR_CODE;
local TEXT_ANCHOR, TEXT_X_OFFSET, TEXT_Y_OFFSET;
local SHOW_ONLY_ON_TARGET;

local StripesLevelTextFont = CreateFont('StripesLevelTextFont');

local function Create(unitframe)
    if unitframe.LevelText then
        return;
    end

    local frame = CreateFrame('Frame', '$parentLevelText', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);

    local text = frame:CreateFontString(nil, 'OVERLAY', 'StripesLevelTextFont');
    text:SetTextColor(1, 1, 1);

    frame.text = text;

    frame:Hide();

    unitframe.LevelText = frame;
end

local function Update(unitframe)
    if unitframe.data.isPersonal or not unitframe.data.level or (SHOW_ONLY_ON_TARGET and not unitframe.data.isTarget) then
        unitframe.LevelText.text:SetText('');
        return;
    end

    if USE_DIFF_COLOR then
        unitframe.LevelText.text:SetText(string_format('%s%s%s|r', U_RGB2CFFHEX(unitframe.data.diff), unitframe.data.level, unitframe.data.classification));
    elseif CUSTOM_COLOR_ENABLED then
        unitframe.LevelText.text:SetText(string_format('%s%s%s|r', CUSTOM_COLOR_CODE, unitframe.data.level, unitframe.data.classification));
    else
        unitframe.LevelText.text:SetText(string_format('%s%s', unitframe.data.level, unitframe.data.classification));
    end
end

local function UpdateVisibility(unitframe)
    local level        = unitframe.data.level;
    local enabled      = ENABLED and level and not unitframe.data.isPersonal;
    local levelUnknown = level == '??';
    local levelMaxed   = type(level) == 'number' and level >= D.MaxLevel;

    if not enabled or (HIDE_MAX and (levelUnknown or levelMaxed)) then
        unitframe.LevelText:Hide();
    else
        unitframe.LevelText:Show();
    end
end

local function UpdateStyle(unitframe)
    unitframe.LevelText.text:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.LevelText.text, TEXT_ANCHOR, unitframe.LevelText, TEXT_ANCHOR, TEXT_X_OFFSET, TEXT_Y_OFFSET);
    unitframe.LevelText:SetFrameStrata(TEXT_FRAME_STRATA == 1 and unitframe.LevelText:GetParent():GetFrameStrata() or TEXT_FRAME_STRATA);
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    UpdateVisibility(unitframe);
    UpdateStyle(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.LevelText then
        unitframe.LevelText:Hide();
    end
end

function Module:Update(unitframe)
    Update(unitframe);
    UpdateVisibility(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED        = O.db.level_text_enabled;
    HIDE_MAX       = O.db.level_text_hide_max;
    USE_DIFF_COLOR = O.db.level_text_use_diff_color;

    TEXT_FRAME_STRATA = O.db.level_text_frame_strata ~= 1 and O.Lists.frame_strata[O.db.level_text_frame_strata] or 1;

    TEXT_ANCHOR   = O.Lists.frame_points_simple[O.db.level_text_anchor];
    TEXT_X_OFFSET = O.db.level_text_x_offset;
    TEXT_Y_OFFSET = O.db.level_text_y_offset;

    CUSTOM_COLOR_ENABLED = O.db.level_text_custom_color_enabled;

    CUSTOM_COLOR_CODE = U_RGB2CFFHEX(O.db.level_text_custom_color);

    SHOW_ONLY_ON_TARGET = O.db.level_text_show_only_on_target;

    S_UpdateFontObject(StripesLevelTextFont, O.db.level_text_font_value, O.db.level_text_font_size, O.db.level_text_font_flag, O.db.level_text_font_shadow);

    if ENABLED then
        self:RegisterEvent('UNIT_LEVEL');
        self:RegisterEvent('UNIT_FACTION');
    else
        self:UnregisterEvent('UNIT_LEVEL');
        self:UnregisterEvent('UNIT_FACTION');
    end
end

function Module:UNIT_LEVEL(unit)
    self:ProcessNamePlateForUnit(unit, Update);
end

function Module:UNIT_FACTION(unit)
    self:ProcessNamePlateForUnit(unit, Update);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end