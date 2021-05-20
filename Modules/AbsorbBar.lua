local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('AbsorbBar');

-- Local config
local ENABLED, AT_TOP;

local BACKDROP = {
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    insets = { top = 1, left = 1, bottom = 1, right = 1 },
    edgeSize = 1,
};

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
    absorbBar:SetShown(false);

    unitframe.AbsorbBar = absorbBar;
end

local function Update(unitframe)
    if not unitframe:IsShown() then
        return;
    end

    if unitframe.data.unitType == 'SELF' then
        unitframe.AbsorbBar:SetShown(false);
        return;
    end

    if not ENABLED then
        return;
    end

    unitframe.overAbsorbGlow:SetShown(false);
    unitframe.totalAbsorb:SetShown(false);
    unitframe.totalAbsorbOverlay:SetShown(false);

    local absorbAmount = unitframe.data.absorbAmount;

    if unitframe.data.healthMax > 0 and absorbAmount > 0 then
        unitframe.AbsorbBar:SetMinMaxValues(0, unitframe.data.healthMax);
        unitframe.AbsorbBar:SetValue(absorbAmount);
        unitframe.AbsorbBar:SetShown(true);

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
    else
        unitframe.AbsorbBar:SetValue(0);
        unitframe.AbsorbBar:SetShown(false);
    end
end

local function UpdateShow(unitframe)
    unitframe.AbsorbBar:SetShown(ENABLED and unitframe.AbsorbBar:GetValue() ~= 0 and unitframe.data.unitType ~= 'SELF');
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
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.AbsorbBar then
        unitframe.AbsorbBar:SetShown(false);
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
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealPrediction', Update);
end