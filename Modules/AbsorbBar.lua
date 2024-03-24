local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('AbsorbBar');

-- Stripes API
local S_UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;
local S_ShortValue = U.ShortValue;

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

    local texture = absorbBar:CreateTexture(nil, 'ARTWORK');
    texture:SetTexture('Interface\\RaidFrame\\Shield-Fill', 'REPEAT', 'REPEAT');
    texture:SetAlpha(0.65);
    texture:SetHorizTile(true);
    texture:SetVertTile(true);

    local overlay = absorbBar:CreateTexture(nil, 'OVERLAY');
    overlay:SetAllPoints(texture);
    overlay:SetTexture('Interface\\RaidFrame\\Shield-Overlay', 'REPEAT', 'REPEAT');
    overlay:SetHorizTile(true);
    overlay:SetVertTile(true);
    overlay.tileSize = 32;

    if AT_TOP then
        absorbBar:ClearAllPoints();
        PixelUtil.SetPoint(absorbBar, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', -0.5, 0);
        PixelUtil.SetPoint(absorbBar, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0.5, 0);
        absorbBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        PixelUtil.SetHeight(absorbBar, 2);
    end

    absorbBar:SetStatusBarTexture(texture);
    absorbBar:SetValue(0);
    absorbBar:Hide();

    local absorbText = CreateFrame('Frame', '$parentAbsorbText', unitframe.healthBar);
    absorbText:SetAllPoints(unitframe.healthBar);
    absorbText.text = absorbText:CreateFontString(nil, 'OVERLAY', 'StripesAbsorbTextFont');
    PixelUtil.SetPoint(absorbText.text, ABSORB_TEXT_ANCHOR, absorbText, ABSORB_TEXT_ANCHOR, ABSORB_TEXT_X_OFFSET, ABSORB_TEXT_Y_OFFSET);
    absorbText.text:SetTextColor(ABSORB_TEXT_COLOR[1], ABSORB_TEXT_COLOR[2], ABSORB_TEXT_COLOR[3], ABSORB_TEXT_COLOR[4]);
    absorbText:Hide();

    absorbBar.texture = texture;
    absorbBar.overlay = overlay;

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

    local absorbAmount  = unitframe.data.absorbAmount;
    local healthMax     = unitframe.data.healthMax;
    local healthCurrent = unitframe.data.healthCurrent;

    local absorbBar    = unitframe.AbsorbBar;
    local absorbText   = unitframe.AbsorbText;

    if healthMax > 0 and absorbAmount > 0 then
        absorbBar:SetMinMaxValues(0, healthMax);
        absorbBar:SetValue(absorbAmount);
        absorbBar:Show();

        if not AT_TOP then
            absorbBar:ClearAllPoints();

            if (healthMax - healthCurrent) >= absorbAmount then
                absorbBar:SetAllPoints(unitframe.totalAbsorb);
                absorbBar.texture:SetAlpha(0.85);
            else
                absorbBar:SetAllPoints(unitframe.healthBar);
                absorbBar.texture:SetAlpha(0.65);
            end
        end

        if ABSORB_TEXT_ENABLED then
            absorbText.text:SetText(S_ShortValue(absorbAmount));
            absorbText:Show();
        else
            absorbText:Hide();
        end
    else
        absorbBar:SetValue(0);
        absorbBar:Hide();
        absorbText:Hide();
    end
end

local function UpdateShow(unitframe)
    local shouldShow = unitframe.AbsorbBar:GetValue() ~= 0 and not unitframe.data.isPersonal;

    unitframe.AbsorbBar:SetShown(ENABLED and shouldShow);
    unitframe.AbsorbText:SetShown(ABSORB_TEXT_ENABLED and shouldShow);
end

local function UpdateStyle(unitframe)
    local absorbBar  = unitframe.AbsorbBar;
    local absorbText = unitframe.AbsorbText;

    absorbBar:ClearAllPoints();

    if not AT_TOP then
        absorbBar:SetAllPoints(unitframe.healthBar);
        absorbBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0);
    else
        PixelUtil.SetPoint(absorbBar, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', -0.5, 0);
        PixelUtil.SetPoint(absorbBar, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0.5, 0);
        absorbBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        PixelUtil.SetHeight(absorbBar, 2);
    end

    absorbText.text:ClearAllPoints();
    PixelUtil.SetPoint(absorbText.text, ABSORB_TEXT_ANCHOR, absorbText, ABSORB_TEXT_ANCHOR, ABSORB_TEXT_X_OFFSET, ABSORB_TEXT_Y_OFFSET);
    absorbText.text:SetTextColor(ABSORB_TEXT_COLOR[1], ABSORB_TEXT_COLOR[2], ABSORB_TEXT_COLOR[3], ABSORB_TEXT_COLOR[4]);
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

    S_UpdateFontObject(StripesAbsorbTextFont, O.db.absorb_text_font_value, O.db.absorb_text_font_size, O.db.absorb_text_font_flag, O.db.absorb_text_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealPrediction', Update);
end