local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Level');

-- Stripes API
local RGB2CFFHEX = U.RGB2CFFHEX;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, TEXT_FRAME_STRATA, HIDE_MAX, USE_DIFF_COLOR, CUSTOM_COLOR_ENABLED, CUSTOM_COLOR, CUSTOM_COLOR_TEXT;
local TEXT_ANCHOR, TEXT_X_OFFSET, TEXT_Y_OFFSET;
local SHOW_ONLY_ON_TARGET;

local CLOSE_COLOR = '|r';

local StripesLevelTextFont = CreateFont('StripesLevelTextFont');

local function Create(unitframe)
    if unitframe.LevelText then
        return;
    end

    local frame = CreateFrame('Frame', '$parentLevelText', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'OVERLAY', 'StripesLevelTextFont');
    frame.text:SetTextColor(1, 1, 1);

    frame:Hide();

    unitframe.LevelText = frame;
end

local function Update(unitframe)
    if unitframe.data.isPersonal or not unitframe.data.level or (SHOW_ONLY_ON_TARGET and not unitframe.data.isTarget) then
        unitframe.LevelText.text:SetText('');
        return;
    end

    if USE_DIFF_COLOR then
        unitframe.LevelText.text:SetText(RGB2CFFHEX(unitframe.data.diff) .. unitframe.data.level .. unitframe.data.classification .. CLOSE_COLOR);
    elseif CUSTOM_COLOR_ENABLED then
        unitframe.LevelText.text:SetText(CUSTOM_COLOR_TEXT .. unitframe.data.level .. unitframe.data.classification .. CLOSE_COLOR);
    else
        unitframe.LevelText.text:SetText(unitframe.data.level .. unitframe.data.classification);
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

    if TEXT_FRAME_STRATA == 1 then
        unitframe.LevelText:SetFrameStrata(unitframe.LevelText:GetParent():GetFrameStrata());
    else
        unitframe.LevelText:SetFrameStrata(TEXT_FRAME_STRATA);
    end
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

    CUSTOM_COLOR    = CUSTOM_COLOR or {};
    CUSTOM_COLOR[1] = O.db.level_text_custom_color[1];
    CUSTOM_COLOR[2] = O.db.level_text_custom_color[2];
    CUSTOM_COLOR[3] = O.db.level_text_custom_color[3];
    CUSTOM_COLOR[4] = O.db.level_text_custom_color[4] or 1;
    CUSTOM_COLOR_TEXT = RGB2CFFHEX(CUSTOM_COLOR);

    SHOW_ONLY_ON_TARGET = O.db.level_text_show_only_on_target;

    UpdateFontObject(StripesLevelTextFont, O.db.level_text_font_value, O.db.level_text_font_size, O.db.level_text_font_flag, O.db.level_text_font_shadow);

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