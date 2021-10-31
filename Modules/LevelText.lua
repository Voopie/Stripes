local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Level');

-- WoW API
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;

-- Stripes API
local RGB2CFFHEX = U.RGB2CFFHEX;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local ENABLED, HIDE_MAX, USE_DIFF_COLOR, CUSTOM_COLOR_ENABLED, CUSTOM_COLOR, CUSTOM_COLOR_TEXT;
local TEXT_ANCHOR, TEXT_X_OFFSET, TEXT_Y_OFFSET;

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

    frame:SetShown(false);

    unitframe.LevelText = frame;
end

local function Update(unitframe)
    if unitframe.data.unitType == 'SELF' then
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

local function UpdateShow(unitframe)
    if HIDE_MAX then
        unitframe.LevelText:SetShown(ENABLED and not (unitframe.data.level == '??' or unitframe.data.level >= D.MaxLevel) and unitframe.data.unitType ~= 'SELF');
    else
        unitframe.LevelText:SetShown(ENABLED and unitframe.data.unitType ~= 'SELF');
    end
end

local function UpdateStyle(unitframe)
    unitframe.LevelText.text:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.LevelText.text, TEXT_ANCHOR, unitframe.LevelText, TEXT_ANCHOR, TEXT_X_OFFSET, TEXT_Y_OFFSET);
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    UpdateShow(unitframe);
    UpdateStyle(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.LevelText then
        unitframe.LevelText:SetShown(false);
    end
end

function Module:Update(unitframe)
    Update(unitframe);
    UpdateShow(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED        = O.db.level_text_enabled;
    HIDE_MAX       = O.db.level_text_hide_max;
    USE_DIFF_COLOR = O.db.level_text_use_diff_color;

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

    UpdateFontObject(StripesLevelTextFont, O.db.level_text_font_value, O.db.level_text_font_size, O.db.level_text_font_flag, O.db.level_text_font_shadow);
end

function Module:UNIT_LEVEL(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    Update(NP[nameplate]);
end

function Module:UNIT_FACTION(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    Update(NP[nameplate]);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('UNIT_LEVEL');
    self:RegisterEvent('UNIT_FACTION');
end