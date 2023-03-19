local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('AbsorbBar');

-- Stripes API
local ShortValue = U.ShortValue;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, AT_TOP;
local ABSORB_TEXT_ENABLED, ABSORB_TEXT_COLOR, ABSORB_TEXT_ANCHOR, ABSORB_TEXT_X_OFFSET, ABSORB_TEXT_Y_OFFSET;

local BACKDROP = {
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    insets = { top = 1, left = 1, bottom = 1, right = 1 },
    edgeSize = 1,
};

local FRAME_POINTS_SIMPLE = O.Lists.frame_points_simple;

local StripesAbsorbTextFont = CreateFont('StripesAbsorbTextFont');

local function Create(unitframe)
    if unitframe.AbsorbBar then
        return;
    end

    local absorbBar = CreateFrame('StatusBar', '$parentAbsorbBar', unitframe.healthBar, 'BackdropTemplate');
    absorbBar:SetAllPoints(unitframe.healthBar);
    absorbBar:SetBackdrop(BACKDROP);
    absorbBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0);

    absorbBar.t = absorbBar:CreateTexture(nil, 'ARTWORK');
    absorbBar.t:SetTexture('Interface\\RaidFrame\\Shield-Fill', 'REPEAT', 'REPEAT');
    absorbBar.t:SetAlpha(0.65);
    absorbBar.t:SetHorizTile(true);
    absorbBar.t:SetVertTile(true);

    absorbBar.overlay = absorbBar:CreateTexture(nil, 'OVERLAY');
    absorbBar.overlay:SetAllPoints(absorbBar.t);
    absorbBar.overlay:SetTexture('Interface\\RaidFrame\\Shield-Overlay', 'REPEAT', 'REPEAT');
    absorbBar.overlay:SetHorizTile(true);
    absorbBar.overlay:SetVertTile(true);
    absorbBar.overlay.tileSize = 32;

    if AT_TOP then
        absorbBar:ClearAllPoints();
        PixelUtil.SetPoint(absorbBar, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', -0.5, 0);
        PixelUtil.SetPoint(absorbBar, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0.5, 0);
        absorbBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        PixelUtil.SetHeight(absorbBar, 2);
    end

    absorbBar:SetStatusBarTexture(absorbBar.t);
    absorbBar:SetValue(0);
    absorbBar:Hide();

    local absorbText = CreateFrame('Frame', '$parentAbsorbText', unitframe.healthBar);
    absorbText:SetAllPoints(unitframe.healthBar);
    absorbText.text = absorbText:CreateFontString(nil, 'OVERLAY', 'StripesAbsorbTextFont');
    PixelUtil.SetPoint(absorbText.text, ABSORB_TEXT_ANCHOR, absorbText, ABSORB_TEXT_ANCHOR, ABSORB_TEXT_X_OFFSET, ABSORB_TEXT_Y_OFFSET);
    absorbText.text:SetTextColor(ABSORB_TEXT_COLOR[1], ABSORB_TEXT_COLOR[2], ABSORB_TEXT_COLOR[3], ABSORB_TEXT_COLOR[4]);
    absorbText:Hide();

    unitframe.AbsorbBar = absorbBar;
    unitframe.AbsorbText = absorbText;
end

local function Update(unitframe)
    if not unitframe:IsShown() then
        return;
    end

    if unitframe.data.isPersonal then
        unitframe.AbsorbBar:Hide();
        return;
    end

    if not ENABLED then
        return;
    end

    unitframe.overAbsorbGlow:Hide();
    unitframe.totalAbsorb:Hide();
    unitframe.totalAbsorbOverlay:Hide();

    local absorbAmount = unitframe.data.absorbAmount;

    if unitframe.data.healthMax > 0 and absorbAmount > 0 then
        unitframe.AbsorbBar:SetMinMaxValues(0, unitframe.data.healthMax);
        unitframe.AbsorbBar:SetValue(absorbAmount);
        unitframe.AbsorbBar:Show();

        if not AT_TOP then
            unitframe.AbsorbBar:ClearAllPoints();

            if (unitframe.data.healthMax - unitframe.data.healthCurrent) >= absorbAmount then
                unitframe.AbsorbBar:SetAllPoints(unitframe.totalAbsorb);
                unitframe.AbsorbBar.t:SetAlpha(0.85);
            else
                unitframe.AbsorbBar:SetAllPoints(unitframe.healthBar);
                unitframe.AbsorbBar.t:SetAlpha(0.65);
            end
        end

        if ABSORB_TEXT_ENABLED then
            unitframe.AbsorbText.text:SetText(ShortValue(absorbAmount));
            unitframe.AbsorbText:Show();
        else
            unitframe.AbsorbText:Hide();
        end
    else
        unitframe.AbsorbBar:SetValue(0);
        unitframe.AbsorbBar:Hide();
        unitframe.AbsorbText:Hide();
    end
end

local function UpdateShow(unitframe)
    unitframe.AbsorbBar:SetShown(ENABLED and unitframe.AbsorbBar:GetValue() ~= 0 and not unitframe.data.isPersonal);
    unitframe.AbsorbText:SetShown(ABSORB_TEXT_ENABLED and unitframe.AbsorbBar:GetValue() ~= 0 and not unitframe.data.isPersonal);
end

local function UpdateStyle(unitframe)
    unitframe.AbsorbBar:ClearAllPoints();

    if not AT_TOP then
        unitframe.AbsorbBar:SetAllPoints(unitframe.healthBar);
        unitframe.AbsorbBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0);
    else
        PixelUtil.SetPoint(unitframe.AbsorbBar, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', -0.5, 0);
        PixelUtil.SetPoint(unitframe.AbsorbBar, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0.5, 0);
        unitframe.AbsorbBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        PixelUtil.SetHeight(unitframe.AbsorbBar, 2);
    end

    unitframe.AbsorbText.text:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.AbsorbText.text, ABSORB_TEXT_ANCHOR, unitframe.AbsorbText, ABSORB_TEXT_ANCHOR, ABSORB_TEXT_X_OFFSET, ABSORB_TEXT_Y_OFFSET);
    unitframe.AbsorbText.text:SetTextColor(ABSORB_TEXT_COLOR[1], ABSORB_TEXT_COLOR[2], ABSORB_TEXT_COLOR[3], ABSORB_TEXT_COLOR[4]);
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.AbsorbBar then
        unitframe.AbsorbBar:Hide();
    end
end

function Module:Update(unitframe)
    Update(unitframe);
    UpdateStyle(unitframe);
    UpdateShow(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.absorb_bar_enabled;
    AT_TOP  = O.db.absorb_bar_at_top;

    ABSORB_TEXT_ENABLED  = O.db.absorb_text_enabled;
    ABSORB_TEXT_ANCHOR   = FRAME_POINTS_SIMPLE[O.db.absorb_text_anchor];
    ABSORB_TEXT_X_OFFSET = O.db.absorb_text_x_offset;
    ABSORB_TEXT_Y_OFFSET = O.db.absorb_text_y_offset;
    ABSORB_TEXT_COLOR    = ABSORB_TEXT_COLOR or {};
    ABSORB_TEXT_COLOR[1] = O.db.absorb_text_color[1];
    ABSORB_TEXT_COLOR[2] = O.db.absorb_text_color[2];
    ABSORB_TEXT_COLOR[3] = O.db.absorb_text_color[3];
    ABSORB_TEXT_COLOR[4] = O.db.absorb_text_color[4] or 1;
    UpdateFontObject(StripesAbsorbTextFont, O.db.absorb_text_font_value, O.db.absorb_text_font_size, O.db.absorb_text_font_flag, O.db.absorb_text_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealPrediction', Update);
end