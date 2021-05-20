local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('HealthText');

-- Stripes API
local ShortValue = U.ShortValue;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

local LIST_FRAME_POSITIONS_SIMPLE = O.Lists.frame_positions_simple;

-- Local Config
local ENABLED, HIDE_FULL, DISPLAY_MODE, CUSTOM_COLOR_ENABLED, CUSTOM_COLOR;

local StripesHealthTextFont = CreateFont('StripesHealthTextFont');

local function Create(unitframe)
    if unitframe.HealthText then
        return;
    end

    local frame = CreateFrame('Frame', '$parentHealthText', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'OVERLAY', 'StripesHealthTextFont');
    PixelUtil.SetPoint(frame.text, LIST_FRAME_POSITIONS_SIMPLE[O.db.health_text_anchor], frame, LIST_FRAME_POSITIONS_SIMPLE[O.db.health_text_anchor], O.db.health_text_x_offset, O.db.health_text_y_offset);

    if CUSTOM_COLOR_ENABLED then
        frame.text:SetTextColor(unpack(CUSTOM_COLOR));
    else
        frame.text:SetTextColor(1, 1, 1, 1);
    end

    frame:SetShown(false);

    unitframe.HealthText = frame;
end

local UpdateHealthTextFormat = {
    [1] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText(unitframe.data.healthPerF == 100 and '%s  %d%%' or '%s  %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF)
    end,

    [2] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText(unitframe.data.healthPerF == 100 and '%s | %d%%' or '%s | %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [3] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText(unitframe.data.healthPerF == 100 and '%s - %d%%' or '%s - %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [4] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText(unitframe.data.healthPerF == 100 and '%s / %d%%' or '%s / %.1f%%', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [5] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText(unitframe.data.healthPerF == 100 and '%s [%d%%]' or '%s / [%.1f%%]', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [6] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText(unitframe.data.healthPerF == 100 and '%s (%d%%)' or '%s / (%.1f%%)', ShortValue(unitframe.data.healthCurrent), unitframe.data.healthPerF);
    end,

    [7] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText('%s', ShortValue(unitframe.data.healthCurrent));
    end,

    [8] = function(unitframe)
        unitframe.HealthText.text:SetFormattedText(unitframe.data.healthPerF == 100 and '%d%%' or '%.1f%%', unitframe.data.healthPerF);
    end,
};

local function Update(unitframe)
    if unitframe.data.unitType == 'SELF' or (HIDE_FULL and unitframe.data.healthCurrent == unitframe.data.healthMax) then
        unitframe.HealthText.text:SetText('');
    else
        UpdateHealthTextFormat[DISPLAY_MODE](unitframe);
    end
end

local function UpdateShow(unitframe)
    unitframe.HealthText:SetShown((ENABLED and unitframe.data.unitType ~= 'SELF'));
end

local function UpdateStyle(unitframe)
    unitframe.HealthText.text:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.HealthText.text, LIST_FRAME_POSITIONS_SIMPLE[O.db.health_text_anchor], unitframe.HealthText, LIST_FRAME_POSITIONS_SIMPLE[O.db.health_text_anchor], O.db.health_text_x_offset, O.db.health_text_y_offset);

    if CUSTOM_COLOR_ENABLED then
        unitframe.HealthText.text:SetTextColor(unpack(CUSTOM_COLOR));
    else
        unitframe.HealthText.text:SetTextColor(1, 1, 1, 1);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    UpdateShow(unitframe);
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

    CUSTOM_COLOR_ENABLED    = O.db.health_text_custom_color_enabled;

    CUSTOM_COLOR            = CUSTOM_COLOR or {};
    CUSTOM_COLOR[1]         = O.db.health_text_custom_color[1];
    CUSTOM_COLOR[2]         = O.db.health_text_custom_color[2];
    CUSTOM_COLOR[3]         = O.db.health_text_custom_color[3];
    CUSTOM_COLOR[4]         = O.db.health_text_custom_color[4] or 1;

    UpdateFontObject(StripesHealthTextFont, O.db.health_text_font_value, O.db.health_text_font_size, O.db.health_text_font_flag, O.db.health_text_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', Update);
end