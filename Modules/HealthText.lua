local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('HealthText');

-- Stripes API
local ShortValue = U.ShortValue;
local LargeNumberFormat = U.LargeNumberFormat;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

local FRAME_POINTS_SIMPLE = O.Lists.frame_points_simple;

-- Local Config
local ENABLED, HIDE_FULL, DISPLAY_MODE, CUSTOM_COLOR_ENABLED, CUSTOM_COLOR;
local TEXT_ANCHOR, TEXT_X_OFFSET, TEXT_Y_OFFSET;
local BLOCK_1_TEXT_ANCHOR, BLOCK_1_TEXT_X_OFFSET, BLOCK_1_TEXT_Y_OFFSET, BLOCK_2_TEXT_ANCHOR, BLOCK_2_TEXT_X_OFFSET, BLOCK_2_TEXT_Y_OFFSET;
local IS_DOUBLE, DISPLAY_MODE_BLOCK_1, DISPLAY_MODE_BLOCK_2;

local StripesHealthTextFont = CreateFont('StripesHealthTextFont');

local function Create(unitframe)
    if unitframe.HealthText then
        return;
    end

    local frame = CreateFrame('Frame', '$parentHealthText', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'OVERLAY', 'StripesHealthTextFont');
    frame.LeftText = frame:CreateFontString(nil, 'OVERLAY', 'StripesHealthTextFont');
    frame.RightText = frame:CreateFontString(nil, 'OVERLAY', 'StripesHealthTextFont');

    frame:SetShown(false);

    unitframe.HealthText = frame;
end

local UpdateHealthTextFormat = {
    [1] = function(unitframe, fontObject)
        fontObject:SetFormattedText(unitframe.data.healthPerF == 100 and '%s  %d%%' or '%s  %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF)
    end,

    [2] = function(unitframe, fontObject)
        fontObject:SetFormattedText(unitframe.data.healthPerF == 100 and '%s | %d%%' or '%s | %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [3] = function(unitframe, fontObject)
        fontObject:SetFormattedText(unitframe.data.healthPerF == 100 and '%s - %d%%' or '%s - %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [4] = function(unitframe, fontObject)
        fontObject:SetFormattedText(unitframe.data.healthPerF == 100 and '%s / %d%%' or '%s / %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [5] = function(unitframe, fontObject)
        fontObject:SetFormattedText(unitframe.data.healthPerF == 100 and '%s [%d%%]' or '%s / [%.1f%%]', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [6] = function(unitframe, fontObject)
        fontObject:SetFormattedText(unitframe.data.healthPerF == 100 and '%s (%d%%)' or '%s / (%.1f%%)', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [7] = function(unitframe, fontObject)
        fontObject:SetFormattedText('%s', ShortValue(unitframe.data.healthCurrent));
    end,

    [8] = function(unitframe, fontObject)
        fontObject:SetFormattedText(unitframe.data.healthPerF == 100 and '%d%%' or '%.1f%%', unitframe.data.healthPerF);
    end,

    [9] = function(unitframe, fontObject)
        fontObject:SetText(unitframe.data.healthCurrent);
    end,

    [10] = function(unitframe, fontObject)
        fontObject:SetText(LargeNumberFormat(unitframe.data.healthCurrent));
    end,
};

local function Update(unitframe)
    if unitframe.data.unitType == 'SELF' or (HIDE_FULL and unitframe.data.healthCurrent == unitframe.data.healthMax) then
        unitframe.HealthText.text:SetText('');
        unitframe.HealthText.LeftText:SetText('');
        unitframe.HealthText.RightText:SetText('');
    else
        if IS_DOUBLE then
            UpdateHealthTextFormat[DISPLAY_MODE_BLOCK_1](unitframe, unitframe.HealthText.LeftText);
            UpdateHealthTextFormat[DISPLAY_MODE_BLOCK_2](unitframe, unitframe.HealthText.RightText);
        else
            UpdateHealthTextFormat[DISPLAY_MODE](unitframe, unitframe.HealthText.text);
        end
    end
end

local function UpdateShow(unitframe)
    unitframe.HealthText:SetShown((ENABLED and unitframe.data.unitType ~= 'SELF'));

    unitframe.HealthText.text:SetShown(not IS_DOUBLE);
    unitframe.HealthText.LeftText:SetShown(IS_DOUBLE);
    unitframe.HealthText.RightText:SetShown(IS_DOUBLE);
end

local function UpdateStyle(unitframe)
    unitframe.HealthText.text:ClearAllPoints();
    unitframe.HealthText.LeftText:ClearAllPoints();
    unitframe.HealthText.RightText:ClearAllPoints();

    PixelUtil.SetPoint(unitframe.HealthText.text, TEXT_ANCHOR, unitframe.HealthText, TEXT_ANCHOR, TEXT_X_OFFSET, TEXT_Y_OFFSET);
    PixelUtil.SetPoint(unitframe.HealthText.LeftText, BLOCK_1_TEXT_ANCHOR, unitframe.HealthText, BLOCK_1_TEXT_ANCHOR, BLOCK_1_TEXT_X_OFFSET, BLOCK_1_TEXT_Y_OFFSET);
    PixelUtil.SetPoint(unitframe.HealthText.RightText, BLOCK_2_TEXT_ANCHOR, unitframe.HealthText, BLOCK_2_TEXT_ANCHOR, BLOCK_2_TEXT_X_OFFSET, BLOCK_2_TEXT_Y_OFFSET);

    if CUSTOM_COLOR_ENABLED then
        unitframe.HealthText.text:SetTextColor(unpack(CUSTOM_COLOR));
        unitframe.HealthText.LeftText:SetTextColor(unpack(CUSTOM_COLOR));
        unitframe.HealthText.RightText:SetTextColor(unpack(CUSTOM_COLOR));
    else
        unitframe.HealthText.text:SetTextColor(1, 1, 1, 1);
        unitframe.HealthText.LeftText:SetTextColor(1, 1, 1, 1);
        unitframe.HealthText.RightText:SetTextColor(1, 1, 1, 1);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    UpdateShow(unitframe);
    UpdateStyle(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.HealthText then
        unitframe.HealthText:SetShown(false);
    end
end

function Module:Update(unitframe)
    Update(unitframe);
    UpdateShow(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED      = O.db.health_text_enabled;
    HIDE_FULL    = O.db.health_text_hide_full;
    DISPLAY_MODE = math.max(math.min(O.db.health_text_display_mode, #UpdateHealthTextFormat), 1);

    TEXT_ANCHOR   = FRAME_POINTS_SIMPLE[O.db.health_text_anchor];
    TEXT_X_OFFSET = O.db.health_text_x_offset;
    TEXT_Y_OFFSET = O.db.health_text_y_offset;

    CUSTOM_COLOR_ENABLED    = O.db.health_text_custom_color_enabled;

    CUSTOM_COLOR            = CUSTOM_COLOR or {};
    CUSTOM_COLOR[1]         = O.db.health_text_custom_color[1];
    CUSTOM_COLOR[2]         = O.db.health_text_custom_color[2];
    CUSTOM_COLOR[3]         = O.db.health_text_custom_color[3];
    CUSTOM_COLOR[4]         = O.db.health_text_custom_color[4] or 1;

    IS_DOUBLE = O.db.health_text_block_mode == 2;
    DISPLAY_MODE_BLOCK_1 = math.max(math.min(O.db.health_text_block_1_display_mode, #UpdateHealthTextFormat), 1);
    DISPLAY_MODE_BLOCK_2 = math.max(math.min(O.db.health_text_block_2_display_mode, #UpdateHealthTextFormat), 1);

    BLOCK_1_TEXT_ANCHOR   = FRAME_POINTS_SIMPLE[O.db.health_text_block_1_anchor];
    BLOCK_1_TEXT_X_OFFSET = O.db.health_text_block_1_x_offset;
    BLOCK_1_TEXT_Y_OFFSET = O.db.health_text_block_1_y_offset;
    BLOCK_2_TEXT_ANCHOR   = FRAME_POINTS_SIMPLE[O.db.health_text_block_2_anchor];
    BLOCK_2_TEXT_X_OFFSET = O.db.health_text_block_2_x_offset;
    BLOCK_2_TEXT_Y_OFFSET = O.db.health_text_block_2_y_offset;

    UpdateFontObject(StripesHealthTextFont, O.db.health_text_font_value, O.db.health_text_font_size, O.db.health_text_font_flag, O.db.health_text_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', Update);
end