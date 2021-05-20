local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Level');

-- Stripes API
local RGB2CFFHEX = U.RGB2CFFHEX;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, USE_DIFF_COLOR, CUSTOM_COLOR_ENABLED, CUSTOM_COLOR;

local CLOSE_COLOR = '|r';
local LIST_FRAME_POSITIONS_SIMPLE = O.Lists.frame_positions_simple;

local StripesLevelTextFont = CreateFont('StripesLevelTextFont');

local function Create(unitframe)
    if unitframe.LevelText then
        return;
    end

    local frame = CreateFrame('Frame', '$parentLevelText', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'OVERLAY', 'StripesLevelTextFont');
    PixelUtil.SetPoint(frame.text, LIST_FRAME_POSITIONS_SIMPLE[O.db.level_text_anchor], frame, LIST_FRAME_POSITIONS_SIMPLE[O.db.level_text_anchor], O.db.level_text_x_offset, O.db.level_text_y_offset);
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
        unitframe.LevelText.text:SetText(RGB2CFFHEX(CUSTOM_COLOR) .. unitframe.data.level .. unitframe.data.classification .. CLOSE_COLOR);
    else
        unitframe.LevelText.text:SetText(unitframe.data.level .. unitframe.data.classification);
    end
end

local function UpdateShow(unitframe)
    unitframe.LevelText:SetShown((ENABLED and unitframe.data.unitType ~= 'SELF'));
end

local function UpdateStyle(unitframe)
    unitframe.LevelText.text:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.LevelText.text, LIST_FRAME_POSITIONS_SIMPLE[O.db.level_text_anchor], unitframe.LevelText, LIST_FRAME_POSITIONS_SIMPLE[O.db.level_text_anchor], O.db.level_text_x_offset, O.db.level_text_y_offset);
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    UpdateShow(unitframe);
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
    USE_DIFF_COLOR = O.db.level_text_use_diff_color;

    CUSTOM_COLOR_ENABLED    = O.db.level_text_custom_color_enabled;

    CUSTOM_COLOR            = CUSTOM_COLOR or {};
    CUSTOM_COLOR[1]         = O.db.level_text_custom_color[1];
    CUSTOM_COLOR[2]         = O.db.level_text_custom_color[2];
    CUSTOM_COLOR[3]         = O.db.level_text_custom_color[3];
    CUSTOM_COLOR[4]         = O.db.level_text_custom_color[4] or 1;

    UpdateFontObject(StripesLevelTextFont, O.db.level_text_font_value, O.db.level_text_font_size, O.db.level_text_font_flag, O.db.level_text_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateMaxHealth', Update);
end